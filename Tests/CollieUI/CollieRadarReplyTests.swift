import Foundation
import XCTest

/// URLProtocol fixtures in the existing synthetic suite; no service or real ledger.
private final class ReplyCapture: @unchecked Sendable {
    private let lock = NSLock()
    private var values: [Data] = []
    func reset() { lock.withLock { values = [] } }
    func append(_ data: Data) { lock.withLock { values.append(data) } }
    var data: [Data] { lock.withLock { values } }
}

private final class ReplyFixtureProtocol: URLProtocol, @unchecked Sendable {
    static let capture = ReplyCapture()
    private let lock = NSLock()
    private var stopped = false
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func stopLoading() { lock.withLock { stopped = true } }
    override func startLoading() {
        var body = request.httpBody ?? Data()
        if let stream = request.httpBodyStream, body.isEmpty {
            stream.open()
            defer { stream.close() }
            var buffer = [UInt8](repeating: 0, count: 1024)
            while body.count <= 20_000 {
                let count = stream.read(&buffer, maxLength: buffer.count)
                if count <= 0 { break }
                body.append(contentsOf: buffer.prefix(count))
            }
        }
        Self.capture.append(body)
        if request.url?.path == "/delayed" {
            let payload = body
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.15) { self.deliver(payload) }
        } else { deliver(body) }
    }
    private func deliver(_ body: Data) {
        guard !lock.withLock({ stopped }) else { return }
        let payload = (try? JSONSerialization.jsonObject(with: body)) as? [String: Any] ?? [:]
        let operation = payload["operation"] as? String ?? "invalid"
        let path = request.url!.path
        if path == "/offline" {
            client?.urlProtocol(self, didFailWithError: URLError(.notConnectedToInternet))
            return
        }
        let ident = path == "/bad-id" ? "PVTI_other" : (payload["id"] as? String ?? "invalid")
        let target: [String: Any] = ["id": ident, "title": "Synthetic item", "url": "https://fixture.invalid/issues/1",
                                     "eligible": true, "status": "等你决策", "next": "Synthetic next", "epoch": "fixture", "version": "fixture"]
        var status = 200
        var response: [String: Any]
        if path == "/old" { status = 400; response = ["error": "invalid_request"] }
        else if path == "/denied" || (path == "/revoked" && operation == "history" && Self.capture.data.count > 1) {
            status = 403; response = ["error": "forbidden"]
        }
        else if path == "/fails-refresh" && Self.capture.data.count > 1 { status = 503; response = ["error": "unavailable"] }
        else if operation == "submit" { status = 503; response = ["error": "result_unknown"] }
        else if operation == "check" { response = ["outcome": "recorded", "target": target] }
        else if operation == "prepare" { response = ["outcome": "prepared", "target": target] }
        else {
            let total = path == "/empty" ? 0 : path == "/paged" ? 6 : 1
            let loaded = payload["before"] == nil ? 0 : 5
            let end = min(total, loaded + 5)
            var entries: [[String: Any]] = []
            if end > loaded {
                for index in loaded..<end {
                    let position = total - index
                    entries.append(["id": "IC_\(position)", "position": position, "kind": "reply", "text": "Sent fixture \(position)",
                                    "request_id": String(format: "11111111-2222-4333-8444-%012d", position),
                                    "url": "https://fixture.invalid/issues/1#issuecomment-\(position)",
                                    "created_at": 100.0, "updated_at": 100.0, "text_omitted": false, "references": []])
                }
            }
            response = ["outcome": "history", "history_version": 1, "target": target, "entries": entries,
                        "total": total, "start": entries.isEmpty ? 0 : loaded + 1, "end": end, "read_at": 200.0, "draft": false]
            if end < total { response["before"] = "fixture-page" }
        }
        let bytes = try! JSONSerialization.data(withJSONObject: response)
        let http = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: "HTTP/1.1",
                                   headerFields: ["Content-Type": "application/json", "Content-Length": String(bytes.count)])!
        client?.urlProtocol(self, didReceive: http, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: bytes)
        client?.urlProtocolDidFinishLoading(self)
    }
}

extension CollieEnhancementTests {
    private func replyFixture(_ path: String = "/history", id: UUID = UUID(),
                              currentSource: @escaping @MainActor () -> Bool = { true }) -> CollieRadarReplySession {
        let file = CollieRadarPendingReply.file(id)
        addTeardownBlock { if FileManager.default.fileExists(atPath: file.path) { try FileManager.default.removeItem(at: file) } }
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [ReplyFixtureProtocol.self]
        let action = CollieRadarSnapshot.Action(project: "fixture", status: "等你决策", title: "Synthetic item",
                                               next: "Synthetic next", url: "https://fixture.invalid/issues/1", id: "PVTI_fixture")
        return CollieRadarReplySession(workbenchID: id, source: "https://fixture.invalid" + path, selected: action,
                                       configuration: configuration, currentSource: currentSource)
    }
    private var replyRequests: [[String: Any]] {
        ReplyFixtureProtocol.capture.data.compactMap { (try? JSONSerialization.jsonObject(with: $0)) as? [String: Any] }
    }

    func testReplyHistoryReopensWithoutTransmittingOrOverwritingDraft() async throws {
        ReplyFixtureProtocol.capture.reset()
        let id = UUID()
        let first = replyFixture(id: id)
        first.text = "Unsent fixture"
        await first.loadHistory()
        XCTAssertEqual(first.history?.entries.first?.text, "Sent fixture 1")
        XCTAssertEqual(first.text, "Unsent fixture")
        XCTAssertTrue(first.preserveDraft())
        let reopened = replyFixture(id: id)
        await reopened.loadHistory()
        XCTAssertEqual(reopened.history?.entries.first?.text, "Sent fixture 1")
        XCTAssertEqual(reopened.text, "Unsent fixture")
        XCTAssertFalse(reopened.pending)
        XCTAssertEqual(replyRequests.count, 2)
        XCTAssertTrue(replyRequests.allSatisfy { ($0["operation"] as? String) == "history" && ($0["text"] as? String) == "" && ($0["confirmed"] as? Bool) == false })
    }

    func testReplyHistoryEmptyUnsupportedDeniedOfflineAndFailureAreDistinct() async throws {
        ReplyFixtureProtocol.capture.reset()
        let empty = replyFixture("/empty")
        await empty.loadHistory()
        XCTAssertEqual(empty.history?.total, 0)
        XCTAssertNil(empty.historyNotice)
        for (path, notice) in [("/old", "不支持"), ("/denied", "无权"), ("/offline", "离线"), ("/bad-id", "读取失败")] {
            let subject = replyFixture(path)
            subject.text = "Preserved fixture"
            await subject.loadHistory()
            XCTAssertNil(subject.history)
            XCTAssertTrue(subject.historyNotice?.contains(notice) == true)
            XCTAssertEqual(subject.text, "Preserved fixture")
        }
        ReplyFixtureProtocol.capture.reset()
        let revoked = replyFixture("/revoked")
        await revoked.loadHistory()
        await revoked.prepare()
        revoked.text = "Preserved fixture"
        XCTAssertTrue(revoked.canSend)
        await revoked.loadHistory()
        XCTAssertNil(revoked.history)
        XCTAssertFalse(revoked.canSend)
        XCTAssertEqual(revoked.text, "Preserved fixture")
    }

    func testReplyHistoryLateSourceAndDismissResponsesDoNotCommit() async throws {
        for changeSource in [true, false] {
            ReplyFixtureProtocol.capture.reset()
            var current = true
            let subject = replyFixture("/delayed", currentSource: { current })
            let operation = Task { await subject.loadHistory() }
            for _ in 0..<100 {
                if !ReplyFixtureProtocol.capture.data.isEmpty { break }
                try await Task.sleep(for: .milliseconds(5))
            }
            XCTAssertEqual(replyRequests.count, 1)
            if changeSource { current = false } else { subject.cancelHistory() }
            await operation.value
            XCTAssertNil(subject.history)
            XCTAssertNil(subject.historyNotice)
            XCTAssertFalse(subject.historyBusy)
        }
    }

    func testReplyHistoryDoesNotResolveOrResendPendingRequest() async throws {
        ReplyFixtureProtocol.capture.reset()
        let id = UUID()
        let subject = replyFixture(id: id)
        await subject.prepare()
        subject.text = "Confirmed synthetic reply"
        await subject.submit()
        XCTAssertTrue(subject.pending)
        let reopened = replyFixture(id: id)
        XCTAssertTrue(reopened.pending)
        await reopened.loadHistory()
        XCTAssertTrue(reopened.pending)
        XCTAssertEqual(reopened.text, "Confirmed synthetic reply")
        await reopened.check()
        XCTAssertTrue(reopened.recorded)
        XCTAssertFalse(reopened.pending)
        let submissions = replyRequests.filter { ($0["operation"] as? String) == "submit" }
        let checks = replyRequests.filter { ($0["operation"] as? String) == "check" }
        XCTAssertEqual(submissions.count, 1)
        XCTAssertEqual(checks.count, 1)
        XCTAssertEqual(submissions.first?["request_id"] as? String, checks.first?["request_id"] as? String)
    }

    func testReplyHistoryPaginationAndRefreshFailurePreserveRecords() async throws {
        ReplyFixtureProtocol.capture.reset()
        let paged = replyFixture("/paged")
        await paged.loadHistory()
        XCTAssertEqual(paged.history?.entries.count, 5)
        await paged.loadHistory(more: true)
        XCTAssertEqual(paged.history?.entries.map(\.position), [6, 5, 4, 3, 2, 1])
        XCTAssertNil(paged.history?.before)
        ReplyFixtureProtocol.capture.reset()
        let failing = replyFixture("/fails-refresh")
        await failing.loadHistory()
        failing.text = "Still editing"
        await failing.loadHistory()
        XCTAssertEqual(failing.history?.entries.count, 1)
        XCTAssertTrue(failing.historyNotice?.contains("读取失败") == true)
        XCTAssertEqual(failing.text, "Still editing")
    }
}
