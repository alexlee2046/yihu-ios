import Foundation

@main
struct WatchVoiceChecks {
    static func main() throws {
        let request = YihuWatchVoiceRequest(requestID: UUID(), workbench: UUID().uuidString,
            task: "synthetic-task", sourceToken: String(repeating: "a", count: 64),
            taskToken: String(repeating: "b", count: 64), audioDigest: String(repeating: "c", count: 64))
        let data = try JSONEncoder().encode(request)
        let decodedRequest = try YihuWatchVoiceRequest.decode(data)
        precondition(decodedRequest == request)
        let ready = YihuWatchVoiceResult(request: request, outcome: .ready, text: "测试草稿，不提交")
        let decodedReady = try YihuWatchVoiceResult.decode(JSONEncoder().encode(ready))
        precondition(decodedReady == ready)
        let busy = YihuWatchVoiceResult(request: request, outcome: .busy)
        let decodedBusy = try YihuWatchVoiceResult.decode(JSONEncoder().encode(busy))
        precondition(decodedBusy == busy)
        func rejectsRequest(_ value: YihuWatchVoiceRequest) {
            precondition((try? YihuWatchVoiceRequest.decode(JSONEncoder().encode(value))) == nil)
        }
        var invalid = request; invalid.version = 2; rejectsRequest(invalid)
        invalid = request; invalid.workbench = "other"; rejectsRequest(invalid)
        invalid = request; invalid.task = ""; rejectsRequest(invalid)
        invalid = request; invalid.task = String(repeating: "x", count: 161); rejectsRequest(invalid)
        invalid = request; invalid.audioDigest = String(repeating: "C", count: 64); rejectsRequest(invalid)
        invalid = request; invalid.sourceToken = ""; rejectsRequest(invalid)
        var object = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        object["version"] = true
        precondition((try? YihuWatchVoiceRequest.decode(JSONSerialization.data(withJSONObject: object))) == nil)
        precondition((try? YihuWatchVoiceRequest.decode(Data(repeating: 0, count: 4097))) == nil)
        for bad in [YihuWatchVoiceResult(request: request, outcome: .ready),
                    YihuWatchVoiceResult(request: request, outcome: .busy, text: "must not carry text"),
                    YihuWatchVoiceResult(request: request, outcome: .ready, text: String(repeating: "x", count: 4001))] {
            precondition((try? YihuWatchVoiceResult.decode(JSONEncoder().encode(bad))) == nil)
        }
        var other = request; other.requestID = UUID(); precondition(other != request)
        other = request; other.taskToken = String(repeating: "d", count: 64); precondition(other != request)
        other = request; other.audioDigest = String(repeating: "d", count: 64); precondition(other != request)
        print("Synthetic Watch voice checks passed: bounded/versioned request, source/task/audio identity, Boolean rejection and result/text bounds")
    }
}
