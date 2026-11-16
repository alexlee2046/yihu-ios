#!/usr/bin/env swift
import CoreBluetooth
import Foundation
import IOBluetooth

enum DaemonLog {
    private static let lock = NSLock()
    static var logFilePath: String = ("~/Library/Logs/yihu-hotspot-ble.log" as NSString).expandingTildeInPath
    private static let maxBytes: UInt64 = 512 * 1024
    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    static func configure(path: String?) {
        lock.lock()
        defer { lock.unlock() }
        if let path, !path.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            logFilePath = (path as NSString).expandingTildeInPath
        }
    }

    static func log(_ message: String) {
        let line = "[\(formatter.string(from: Date()))] [mac-hotspot-ble] \(message)"
        print(line)
        fflush(stdout)

        lock.lock()
        defer { lock.unlock() }
        let fm = FileManager.default
        let url = URL(fileURLWithPath: logFilePath)
        let dir = url.deletingLastPathComponent()
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)

        if let attrs = try? fm.attributesOfItem(atPath: url.path),
           let size = attrs[.size] as? UInt64,
           size > maxBytes {
            let backup = URL(fileURLWithPath: url.path + ".1")
            try? fm.removeItem(at: backup)
            try? fm.moveItem(at: url, to: backup)
        }

        guard let data = (line + "\n").data(using: .utf8) else { return }
        if !fm.fileExists(atPath: url.path) {
            fm.createFile(atPath: url.path, contents: data, attributes: [.posixPermissions: 0o600])
        } else if let handle = try? FileHandle(forWritingTo: url) {
            defer { try? handle.close() }
            _ = try? handle.seekToEnd()
            try? handle.write(contentsOf: data)
            try? fm.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url.path)
        }
    }
}

struct MacHotspotStatus: Codable, Equatable {
    enum NetworkState: String, Codable {
        case offline
        case connecting
        case online
    }

    var state: NetworkState
    var host: String
    var ssid: String?
    var ts: Double
    var onHotspot: Bool? = nil
    var lastWakeResult: String? = nil
}

struct HotspotWakeCommand: Codable, Equatable {
    enum Action: String, Codable {
        case wakeHotspot = "wake-hotspot"
        case wifiReady = "wifi-ready"
        case ping = "ping"
    }

    var action: Action
    var ssid: String
    var ts: Double
}

enum HotspotBLEConstants {
    static var serviceUUID: CBUUID { CBUUID(string: "D8A47B10-6C91-4E52-9F01-3B7D8E21C4A0") }
    static var statusCharacteristicUUID: CBUUID { CBUUID(string: "D8A47B11-6C91-4E52-9F01-3B7D8E21C4A0") }
    static var commandCharacteristicUUID: CBUUID { CBUUID(string: "D8A47B12-6C91-4E52-9F01-3B7D8E21C4A0") }
    static let defaultSSID = "AL IPower"
    static let offlineMarkerPath = ("~/Library/Caches/hotspot-fallback-offline-since" as NSString).expandingTildeInPath
    static let helperAppPath = ("~/Applications/HotspotFallback.app" as NSString).expandingTildeInPath
    static let helperBinaryPath = helperAppPath + "/Contents/MacOS/HotspotFallback"
}

enum MacNetworkActivator {
    static var hostName: String {
        ProcessInfo.processInfo.hostName
            .replacingOccurrences(of: ".local", with: "")
    }

    static func runProcess(_ executable: String, arguments: [String], timeout: TimeInterval = 12) -> (Int32, String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        do {
            try process.run()
        } catch {
            return (-1, error.localizedDescription)
        }
        let deadline = Date().addingTimeInterval(timeout)
        while process.isRunning && Date() < deadline {
            Thread.sleep(forTimeInterval: 0.05)
        }
        if process.isRunning {
            process.terminate()
            return (-2, "timed out")
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return (process.terminationStatus, output)
    }

    static func isOnHotspot(ssid: String) -> Bool {
        let (routerCode, routerOut) = runProcess("/usr/sbin/ipconfig", arguments: ["getoption", "en0", "router"], timeout: 3)
        if routerCode == 0 && routerOut.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("172.20.10.") {
            return true
        }
        let (wifiCode, wifiOut) = runProcess("/usr/sbin/networksetup", arguments: ["-getairportnetwork", "en0"], timeout: 3)
        if wifiCode == 0, let colonRange = wifiOut.range(of: ": ") {
            let current = wifiOut[colonRange.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
            if !current.isEmpty, current.caseInsensitiveCompare("<redacted>") != .orderedSame {
                let candidates = [ssid, "AL IPower", "AL Ipower"]
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
                if candidates.contains(where: { current.caseInsensitiveCompare($0) == .orderedSame }) {
                    return true
                }
            }
        }
        return false
    }

    private static func systemProxyURL() -> String? {
        let (code, out) = runProcess("/usr/sbin/scutil", arguments: ["--proxy"], timeout: 3)
        guard code == 0 else { return nil }
        var fields: [String: String] = [:]
        for line in out.components(separatedBy: .newlines) {
            let parts = line.split(separator: ":", maxSplits: 1)
            if parts.count == 2 {
                let k = parts[0].trimmingCharacters(in: .whitespaces)
                let v = parts[1].trimmingCharacters(in: .whitespaces)
                fields[k] = v
            }
        }
        for (prefix, scheme) in [("HTTPS", "http"), ("HTTP", "http"), ("SOCKS", "socks5h")] {
            if fields["\(prefix)Enable"] == "1",
               let host = fields["\(prefix)Proxy"], !host.isEmpty,
               let port = fields["\(prefix)Port"], port.allSatisfy(\.isNumber), !port.isEmpty {
                return "\(scheme)://\(host):\(port)"
            }
        }
        return nil
    }

    private static func probeURL(proxyArgs: [String]) -> Bool {
        let probes: [(url: String, status: String, requireSuccessTitle: Bool)] = [
            ("https://captive.apple.com/hotspot-detect.html", "200", true),
            ("https://cp.cloudflare.com/generate_204", "204", false)
        ]
        for probe in probes {
            let args = proxyArgs + ["-fsS", "--max-time", "4", "--max-redirs", "0", "-w", "\n%{http_code}", probe.url]
            let (code, output) = runProcess("/usr/bin/curl", arguments: args, timeout: 6)
            guard code == 0 else { continue }
            let lines = output.components(separatedBy: "\n")
            guard let statusLine = lines.last?.trimmingCharacters(in: .whitespacesAndNewlines),
                  statusLine == probe.status else { continue }
            if probe.requireSuccessTitle {
                let body = lines.dropLast().joined(separator: "\n")
                if body.range(of: "<title>\\s*Success\\s*</title>", options: [.regularExpression, .caseInsensitive]) != nil {
                    return true
                }
            } else {
                return true
            }
        }
        return false
    }

    static func isInternetReachable() -> Bool {
        if probeURL(proxyArgs: ["--noproxy", "*"]) {
            return true
        }
        if let proxy = systemProxyURL(), probeURL(proxyArgs: ["--proxy", proxy, "--noproxy", ""]) {
            return true
        }
        return false
    }

    /// Wakes the Bluetooth baseband / PAN / Continuity channel to the paired iPhone even when the Mac screen is locked.
    static func wakePairedBluetoothDevice(matching targetName: String) -> String {
        guard let devices = IOBluetoothDevice.pairedDevices() as? [IOBluetoothDevice] else {
            return "no-paired-devices"
        }
        let normalized = targetName.lowercased()
        guard let match = devices.first(where: { ($0.name ?? "").lowercased() == normalized })
            ?? devices.first(where: { ($0.name ?? "").lowercased().contains(normalized) }) else {
            return "not-paired:\(targetName)"
        }
        if match.isConnected() {
            return "already-connected:\(match.name ?? targetName)"
        }
        let result = match.openConnection()
        return "openConnection(\(match.name ?? targetName)) status=\(result)"
    }

    private static func tryDirectWifiJoin(candidates: [String], ssid: String) -> Bool {
        for candidate in candidates {
            let (code, output) = runProcess(
                "/usr/sbin/networksetup",
                arguments: ["-setairportnetwork", "en0", candidate],
                timeout: 10
            )
            let lower = output.lowercased()
            let failed = code != 0
                || lower.contains("could not find")
                || lower.contains("failed")
                || lower.contains("error")
            DaemonLog.log("Direct Wi-Fi join '\(candidate)' exit=\(code) output=\(output)")
            if !failed {
                Thread.sleep(forTimeInterval: 2.0)
                if isOnHotspot(ssid: ssid) {
                    return true
                }
            }
        }
        return false
    }

    /// Attempts direct Wi-Fi join + HotspotFallback.app Instant Hotspot activation (under LaunchServices TCC identity).
    static func activateHotspot(ssid rawSSID: String) -> (Bool, String) {
        let ssid = rawSSID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? HotspotBLEConstants.defaultSSID
            : rawSSID.trimmingCharacters(in: .whitespacesAndNewlines)

        if isOnHotspot(ssid: ssid) && isInternetReachable() {
            try? FileManager.default.removeItem(atPath: HotspotBLEConstants.offlineMarkerPath)
            DaemonLog.log("Already on hotspot '\(ssid)' with internet reachable")
            return (true, "already-on-hotspot")
        }

        let btSummary = wakePairedBluetoothDevice(matching: ssid)
        DaemonLog.log("Bluetooth wake: \(btSummary)")

        // Ensure Wi-Fi power is on.
        _ = runProcess("/usr/sbin/networksetup", arguments: ["-setairportpower", "en0", "on"], timeout: 5)

        let candidates = Array(NSOrderedSet(array: [ssid, "AL IPower", "AL Ipower"])).compactMap { $0 as? String }
        if tryDirectWifiJoin(candidates: candidates, ssid: ssid) {
            try? FileManager.default.removeItem(atPath: HotspotBLEConstants.offlineMarkerPath)
            DaemonLog.log("Connected directly via Wi-Fi to hotspot '\(ssid)'")
            return (true, "connected-direct")
        }

        // Trigger macOS Instant Hotspot via LaunchServices so HotspotFallback.app runs under its own TCC Accessibility grant.
        if FileManager.default.fileExists(atPath: HotspotBLEConstants.helperAppPath) {
            let (openCode, openOut) = runProcess(
                "/usr/bin/open",
                arguments: ["-g", "-W", "-a", HotspotBLEConstants.helperAppPath, "--args", "--connect"],
                timeout: 28
            )
            DaemonLog.log("open HotspotFallback.app --connect exit=\(openCode) output=\(openOut)")
            if openCode != 0 && FileManager.default.isExecutableFile(atPath: HotspotBLEConstants.helperBinaryPath) {
                let (binCode, binOut) = runProcess(HotspotBLEConstants.helperBinaryPath, arguments: ["--connect"], timeout: 25)
                DaemonLog.log("Fallback direct HotspotFallback --connect exit=\(binCode) output=\(binOut)")
            }
        } else {
            DaemonLog.log("HotspotFallback.app missing at \(HotspotBLEConstants.helperAppPath)")
        }

        // Wait up to 5s for DHCP / Instant Hotspot interface to settle on 172.20.10.x or hotspot SSID.
        for _ in 0..<5 {
            if isOnHotspot(ssid: ssid) {
                try? FileManager.default.removeItem(atPath: HotspotBLEConstants.offlineMarkerPath)
                DaemonLog.log("Connected via Instant Hotspot helper to '\(ssid)'")
                return (true, "connected-instant-hotspot")
            }
            Thread.sleep(forTimeInterval: 1.0)
        }

        // Retry direct Wi-Fi join once more in case Instant Hotspot woke the iPhone Wi-Fi beacon.
        if tryDirectWifiJoin(candidates: candidates, ssid: ssid) {
            try? FileManager.default.removeItem(atPath: HotspotBLEConstants.offlineMarkerPath)
            DaemonLog.log("Connected via second-pass Wi-Fi join to '\(ssid)'")
            return (true, "connected-instant-hotspot")
        }

        DaemonLog.log("Wake failed: hotspot-not-found for '\(ssid)'")
        return (false, "hotspot-not-found")
    }
}

final class MacHotspotBLEDaemon: NSObject, CBPeripheralManagerDelegate, @unchecked Sendable {
    private var peripheralManager: CBPeripheralManager!
    private var statusCharacteristic: CBMutableCharacteristic?
    private var commandCharacteristic: CBMutableCharacteristic?
    private var currentState: MacHotspotStatus.NetworkState = .online
    private var targetSSID: String = HotspotBLEConstants.defaultSSID
    private var lastWakeResult: String? = nil
    private var pollTimer: Timer?
    private var isWaking = false

    override init() {
        super.init()
        currentState = MacNetworkActivator.isInternetReachable() ? .online : .offline
        peripheralManager = CBPeripheralManager(delegate: self, queue: .main)
        pollTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.refreshNetworkStatus()
        }
    }

    private func currentStatusPayload() -> Data {
        let onHotspot = MacNetworkActivator.isOnHotspot(ssid: targetSSID)
        let status = MacHotspotStatus(
            state: currentState,
            host: MacNetworkActivator.hostName,
            ssid: targetSSID,
            ts: Date().timeIntervalSince1970,
            onHotspot: onHotspot,
            lastWakeResult: lastWakeResult
        )
        return (try? JSONEncoder().encode(status)) ?? Data()
    }

    private func refreshNetworkStatus() {
        guard !isWaking else { return }
        let reachable = MacNetworkActivator.isInternetReachable()
        let nextState: MacHotspotStatus.NetworkState = reachable ? .online : .offline
        if nextState != currentState {
            currentState = nextState
            notifySubscribers()
        }
    }

    private func notifySubscribers() {
        guard let peripheralManager, let statusCharacteristic else { return }
        let payload = currentStatusPayload()
        statusCharacteristic.value = payload
        peripheralManager.updateValue(payload, for: statusCharacteristic, onSubscribedCentrals: nil)
    }

    private func handleWakeCommand(_ command: HotspotWakeCommand) {
        DaemonLog.log("Received BLE command: \(command.action.rawValue) ssid=\(command.ssid)")
        if !command.ssid.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            targetSSID = command.ssid.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if command.action == .ping {
            refreshNetworkStatus()
            notifySubscribers()
            return
        }
        // Only .wakeHotspot and .wifiReady reach here.
        guard !isWaking else {
            DaemonLog.log("Wake already in progress; notifying current connecting state")
            notifySubscribers()
            return
        }
        isWaking = true
        currentState = .connecting
        lastWakeResult = "connecting"
        notifySubscribers()

        let ssid = targetSSID
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let (ok, reason) = MacNetworkActivator.activateHotspot(ssid: ssid)
            let reachable = MacNetworkActivator.isInternetReachable()
            DispatchQueue.main.async {
                guard let self else { return }
                self.isWaking = false
                self.currentState = reachable ? .online : .offline
                self.lastWakeResult = ok ? "connected" : "failed:\(reason)"
                DaemonLog.log("Wake completed: ok=\(ok) reason=\(reason) reachable=\(reachable) onHotspot=\(MacNetworkActivator.isOnHotspot(ssid: ssid))")
                self.notifySubscribers()
            }
        }
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        guard peripheral.state == .poweredOn else {
            DaemonLog.log("Peripheral state: \(peripheral.state.rawValue)")
            return
        }
        let statusChar = CBMutableCharacteristic(
            type: HotspotBLEConstants.statusCharacteristicUUID,
            properties: [.read, .notify],
            value: nil,
            permissions: [.readable]
        )
        let commandChar = CBMutableCharacteristic(
            type: HotspotBLEConstants.commandCharacteristicUUID,
            properties: [.write, .writeWithoutResponse],
            value: nil,
            permissions: [.writeable]
        )
        let service = CBMutableService(type: HotspotBLEConstants.serviceUUID, primary: true)
        service.characteristics = [statusChar, commandChar]
        statusCharacteristic = statusChar
        commandCharacteristic = commandChar
        peripheral.removeAllServices()
        peripheral.add(service)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: (any Error)?) {
        if let error {
            DaemonLog.log("Failed to add service: \(error.localizedDescription)")
            return
        }
        peripheral.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [HotspotBLEConstants.serviceUUID],
            CBAdvertisementDataLocalNameKey: MacNetworkActivator.hostName
        ])
        DaemonLog.log("Advertising BLE service \(HotspotBLEConstants.serviceUUID.uuidString) as \(MacNetworkActivator.hostName)")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        DaemonLog.log("Central subscribed: \(central.identifier.uuidString)")
        refreshNetworkStatus()
        notifySubscribers()
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        guard request.characteristic.uuid == HotspotBLEConstants.statusCharacteristicUUID else {
            peripheral.respond(to: request, withResult: .attributeNotFound)
            return
        }
        refreshNetworkStatus()
        let payload = currentStatusPayload()
        if request.offset > payload.count {
            peripheral.respond(to: request, withResult: .invalidOffset)
            return
        }
        request.value = payload.subdata(in: request.offset..<payload.count)
        peripheral.respond(to: request, withResult: .success)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            guard request.characteristic.uuid == HotspotBLEConstants.commandCharacteristicUUID,
                  let data = request.value,
                  let command = try? JSONDecoder().decode(HotspotWakeCommand.self, from: data) else {
                peripheral.respond(to: request, withResult: .unlikelyError)
                continue
            }
            peripheral.respond(to: request, withResult: .success)
            handleWakeCommand(command)
        }
    }
}

let args = Array(CommandLine.arguments.dropFirst())
if let logIdx = args.firstIndex(of: "--log"), logIdx + 1 < args.count {
    DaemonLog.configure(path: args[logIdx + 1])
}

if args.contains("--self-test") {
    let status = MacHotspotStatus(
        state: .offline,
        host: MacNetworkActivator.hostName,
        ssid: HotspotBLEConstants.defaultSSID,
        ts: 1_780_000_000,
        onHotspot: false,
        lastWakeResult: "failed:hotspot-not-found"
    )
    let encodedStatus = try JSONEncoder().encode(status)
    let decodedStatus = try JSONDecoder().decode(MacHotspotStatus.self, from: encodedStatus)
    precondition(decodedStatus == status)

    let cmd = HotspotWakeCommand(action: .wakeHotspot, ssid: HotspotBLEConstants.defaultSSID, ts: 1_780_000_001)
    let encodedCmd = try JSONEncoder().encode(cmd)
    let decodedCmd = try JSONDecoder().decode(HotspotWakeCommand.self, from: encodedCmd)
    precondition(decodedCmd == cmd)

    let pairedNames = ((IOBluetoothDevice.pairedDevices() as? [IOBluetoothDevice]) ?? []).compactMap(\.name)
    print("MacHotspotBLEDaemon self-test passed: host=\(MacNetworkActivator.hostName), service=\(HotspotBLEConstants.serviceUUID.uuidString), pairedDevices=\(pairedNames)")
    exit(0)
} else if let idx = args.firstIndex(of: "--wake-once") {
    let ssid = (idx + 1 < args.count && !args[idx + 1].hasPrefix("--")) ? args[idx + 1] : HotspotBLEConstants.defaultSSID
    let (ok, reason) = MacNetworkActivator.activateHotspot(ssid: ssid)
    print("MacHotspotBLEDaemon wake-once(\(ssid)) -> ok=\(ok) reason=\(reason) onHotspot=\(MacNetworkActivator.isOnHotspot(ssid: ssid)) reachable=\(MacNetworkActivator.isInternetReachable())")
    exit(ok ? 0 : 1)
} else {
    DaemonLog.log("Starting YihuHotspotBLE daemon on \(MacNetworkActivator.hostName)")
    let daemon = MacHotspotBLEDaemon()
    withExtendedLifetime(daemon) {
        RunLoop.main.run()
    }
}
