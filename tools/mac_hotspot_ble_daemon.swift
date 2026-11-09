#!/usr/bin/env swift
import CoreBluetooth
import Foundation
import IOBluetooth

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
    static let helperBinaryPath = ("~/Library/Scripts/HotspotFallback.app/Contents/MacOS/HotspotFallback" as NSString).expandingTildeInPath
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
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.05))
        }
        if process.isRunning {
            process.terminate()
            return (-2, "timed out")
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return (process.terminationStatus, output)
    }

    static func isInternetReachable() -> Bool {
        if FileManager.default.fileExists(atPath: HotspotBLEConstants.offlineMarkerPath) {
            // Double-check with a fast probe in case connectivity just recovered.
            let (code, _) = runProcess(
                "/usr/bin/curl",
                arguments: ["-fsSI", "--max-time", "3", "http://captive.apple.com/hotspot-detect.html"],
                timeout: 4
            )
            return code == 0
        }
        let (code, _) = runProcess(
            "/usr/bin/curl",
            arguments: ["-fsSI", "--max-time", "3", "http://captive.apple.com/hotspot-detect.html"],
            timeout: 4
        )
        return code == 0
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

    /// Attempts direct CoreWLAN / networksetup join + HotspotFallback.app Instant Hotspot activation.
    static func activateHotspot(ssid rawSSID: String) -> Bool {
        let ssid = rawSSID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? HotspotBLEConstants.defaultSSID
            : rawSSID.trimmingCharacters(in: .whitespacesAndNewlines)

        let btSummary = wakePairedBluetoothDevice(matching: ssid)
        print("[mac-hotspot-ble] Bluetooth wake: \(btSummary)")

        // Ensure Wi-Fi power is on.
        _ = runProcess("/usr/sbin/networksetup", arguments: ["-setairportpower", "en0", "on"], timeout: 5)

        // Try direct Wi-Fi association first (succeeds immediately if iPhone hotspot beacon is active).
        let candidates = Array(NSOrderedSet(array: [ssid, "AL IPower", "AL Ipower"])).compactMap { $0 as? String }
        for candidate in candidates {
            let (code, output) = runProcess(
                "/usr/sbin/networksetup",
                arguments: ["-setairportnetwork", "en0", candidate],
                timeout: 10
            )
            if code == 0 && !output.lowercased().contains("could not find network") && !output.lowercased().contains("failed") {
                if isInternetReachable() {
                    try? FileManager.default.removeItem(atPath: HotspotBLEConstants.offlineMarkerPath)
                    return true
                }
            }
        }

        // Fall back to HotspotFallback.app (Instant Hotspot / Control Center) without waiting 180s.
        if FileManager.default.isExecutableFile(atPath: HotspotBLEConstants.helperBinaryPath) {
            let (code, output) = runProcess(HotspotBLEConstants.helperBinaryPath, arguments: ["--connect"], timeout: 15)
            print("[mac-hotspot-ble] HotspotFallback --connect exit=\(code) output=\(output)")
        }

        // Retry direct Wi-Fi association once more after Bluetooth/Instant Hotspot beacon wake.
        for candidate in candidates {
            _ = runProcess("/usr/sbin/networksetup", arguments: ["-setairportnetwork", "en0", candidate], timeout: 8)
            if isInternetReachable() {
                try? FileManager.default.removeItem(atPath: HotspotBLEConstants.offlineMarkerPath)
                return true
            }
        }

        return isInternetReachable()
    }
}

final class MacHotspotBLEDaemon: NSObject, CBPeripheralManagerDelegate, @unchecked Sendable {
    private var peripheralManager: CBPeripheralManager!
    private var statusCharacteristic: CBMutableCharacteristic?
    private var commandCharacteristic: CBMutableCharacteristic?
    private var currentState: MacHotspotStatus.NetworkState = .online
    private var targetSSID: String = HotspotBLEConstants.defaultSSID
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
        let status = MacHotspotStatus(
            state: currentState,
            host: MacNetworkActivator.hostName,
            ssid: targetSSID,
            ts: Date().timeIntervalSince1970
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
        if !command.ssid.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            targetSSID = command.ssid.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if command.action == .ping {
            refreshNetworkStatus()
            notifySubscribers()
            return
        }
        guard !isWaking else { return }
        isWaking = true
        currentState = .connecting
        notifySubscribers()

        let ssid = targetSSID
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let connected = MacNetworkActivator.activateHotspot(ssid: ssid)
            DispatchQueue.main.async {
                guard let self else { return }
                self.isWaking = false
                self.currentState = connected ? .online : (MacNetworkActivator.isInternetReachable() ? .online : .offline)
                self.notifySubscribers()
            }
        }
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        guard peripheral.state == .poweredOn else {
            print("[mac-hotspot-ble] Peripheral state: \(peripheral.state.rawValue)")
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
            print("[mac-hotspot-ble] Failed to add service: \(error.localizedDescription)")
            return
        }
        peripheral.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [HotspotBLEConstants.serviceUUID],
            CBAdvertisementDataLocalNameKey: MacNetworkActivator.hostName
        ])
        print("[mac-hotspot-ble] Advertising BLE service \(HotspotBLEConstants.serviceUUID.uuidString) as \(MacNetworkActivator.hostName)")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
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
if args.contains("--self-test") {
    let status = MacHotspotStatus(state: .offline, host: MacNetworkActivator.hostName, ssid: HotspotBLEConstants.defaultSSID, ts: 1_780_000_000)
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
    let ssid = (idx + 1 < args.count) ? args[idx + 1] : HotspotBLEConstants.defaultSSID
    let ok = MacNetworkActivator.activateHotspot(ssid: ssid)
    print("MacHotspotBLEDaemon wake-once(\(ssid)) -> reachable=\(ok)")
    exit(ok ? 0 : 1)
} else {
    let daemon = MacHotspotBLEDaemon()
    withExtendedLifetime(daemon) {
        RunLoop.main.run()
    }
}
