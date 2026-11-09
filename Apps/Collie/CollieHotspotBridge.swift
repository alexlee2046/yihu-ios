import CoreBluetooth
import Foundation
import Observation
#if canImport(UIKit)
import UIKit
#endif

private func hotspotText(_ key: String) -> String {
    NSLocalizedString(key, tableName: "Yihu", comment: "")
}

/// Shared BLE GATT protocol between the Yihu iOS app (Central) and the MacBook hotspot daemon (Peripheral).
enum CollieHotspotBLEProtocol {
    static let serviceUUIDString = "D8A47B10-6C91-4E52-9F01-3B7D8E21C4A0"
    static let statusCharacteristicUUIDString = "D8A47B11-6C91-4E52-9F01-3B7D8E21C4A0"
    static let commandCharacteristicUUIDString = "D8A47B12-6C91-4E52-9F01-3B7D8E21C4A0"
    static let restoreIdentifier = "collie.hotspot.central"

    static let defaultHotspotSSID = "AL IPower"
    static let defaultShortcutName = "WakeHotspot"
    static let defaultMinimumRSSI = -78
    static let wakeCooldownSeconds: TimeInterval = 25

    static var serviceUUID: CBUUID { CBUUID(string: serviceUUIDString) }
    static var statusCharacteristicUUID: CBUUID { CBUUID(string: statusCharacteristicUUIDString) }
    static var commandCharacteristicUUID: CBUUID { CBUUID(string: commandCharacteristicUUIDString) }

    static func isNearby(rssi: Int?, minimumRSSI: Int = defaultMinimumRSSI) -> Bool {
        guard let rssi, rssi != 127, rssi < 0 else { return true }
        return rssi >= minimumRSSI
    }

    static func shouldAutoTriggerWake(
        status: CollieHotspotMacStatus,
        rssi: Int?,
        minimumRSSI: Int = defaultMinimumRSSI,
        lastWakeAt: Date?,
        now: Date = Date(),
        cooldown: TimeInterval = wakeCooldownSeconds
    ) -> Bool {
        guard status.state == .offline else { return false }
        guard isNearby(rssi: rssi, minimumRSSI: minimumRSSI) else { return false }
        if let lastWakeAt, now.timeIntervalSince(lastWakeAt) < cooldown {
            return false
        }
        return true
    }

    static func shortcutURL(named rawName: String) -> URL? {
        let trimmed = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        var components = URLComponents()
        components.scheme = "shortcuts"
        components.host = "run-shortcut"
        components.queryItems = [URLQueryItem(name: "name", value: trimmed)]
        return components.url
    }
}

struct CollieHotspotMacStatus: Codable, Equatable, Sendable {
    enum NetworkState: String, Codable, Sendable {
        case offline
        case connecting
        case online
    }

    var state: NetworkState
    var host: String
    var ssid: String?
    var ts: Double
}

struct CollieHotspotWakeCommand: Codable, Equatable, Sendable {
    enum Action: String, Codable, Sendable {
        case wakeHotspot = "wake-hotspot"
        case wifiReady = "wifi-ready"
        case ping = "ping"
    }

    var action: Action
    var ssid: String
    var ts: Double
}

#if canImport(UIKit)
@MainActor
@Observable
final class CollieHotspotBridge: NSObject {
    static let shared = CollieHotspotBridge()

    static let enabledKey = "collie.hotspot.ble.enabled.v1"
    static let autoShortcutKey = "collie.hotspot.ble.autoShortcut.v1"
    static let shortcutNameKey = "collie.hotspot.ble.shortcutName.v1"
    static let hotspotSSIDKey = "collie.hotspot.ble.ssid.v1"

    enum Phase: Equatable {
        case disabled
        case bluetoothUnavailable(String)
        case scanning
        case connecting(String)
        case monitoring(host: String, state: CollieHotspotMacStatus.NetworkState, rssi: Int?)
        case waking(host: String)
        case recovered(host: String)
    }

    private let defaults: UserDefaults
    var isEnabled: Bool {
        didSet {
            guard isEnabled != oldValue else { return }
            defaults.set(isEnabled, forKey: Self.enabledKey)
            if isEnabled {
                startIfNeeded()
            } else {
                stop()
            }
        }
    }

    var autoRunShortcutInForeground: Bool {
        didSet {
            defaults.set(autoRunShortcutInForeground, forKey: Self.autoShortcutKey)
        }
    }

    var shortcutName: String {
        didSet {
            defaults.set(shortcutName, forKey: Self.shortcutNameKey)
        }
    }

    var hotspotSSID: String {
        didSet {
            defaults.set(hotspotSSID, forKey: Self.hotspotSSIDKey)
        }
    }

    private(set) var phase: Phase = .disabled
    private(set) var lastMacStatus: CollieHotspotMacStatus?
    private(set) var lastRSSI: Int?
    private(set) var lastWakeDate: Date?
    var onMacBecameOnline: (@MainActor () -> Void)?

    @ObservationIgnored private var central: CBCentralManager?
    @ObservationIgnored private var peripheral: CBPeripheral?
    @ObservationIgnored private var statusCharacteristic: CBCharacteristic?
    @ObservationIgnored private var commandCharacteristic: CBCharacteristic?
    @ObservationIgnored private var pendingManualWake = false
    @ObservationIgnored private var awaitingShortcutReturn = false

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.isEnabled = defaults.bool(forKey: Self.enabledKey)
        self.autoRunShortcutInForeground = defaults.bool(forKey: Self.autoShortcutKey)
        let savedShortcut = defaults.string(forKey: Self.shortcutNameKey)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        self.shortcutName = (savedShortcut?.isEmpty == false ? savedShortcut! : CollieHotspotBLEProtocol.defaultShortcutName)
        let savedSSID = defaults.string(forKey: Self.hotspotSSIDKey)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        self.hotspotSSID = (savedSSID?.isEmpty == false ? savedSSID! : CollieHotspotBLEProtocol.defaultHotspotSSID)
        super.init()
        if isEnabled {
            startIfNeeded()
        }
    }

    var statusSummary: String {
        switch phase {
        case .disabled:
            return hotspotText("未启用（开启后可在 Mac 断网且靠近时自动蓝牙唤醒热点）")
        case .bluetoothUnavailable(let reason):
            return reason
        case .scanning:
            return hotspotText("正在通过蓝牙寻找附近的 Mac…")
        case .connecting(let host):
            return String(format: hotspotText("正在蓝牙连接 %@…"), host)
        case .monitoring(let host, let state, let rssi):
            let rssiLabel = rssi.map { " (\($0) dBm)" } ?? ""
            switch state {
            case .online:
                return String(format: hotspotText("%@ 已在线%@"), host, rssiLabel)
            case .connecting:
                return String(format: hotspotText("%@ 正在连接手机热点%@…"), host, rssiLabel)
            case .offline:
                return String(format: hotspotText("检测到 %@ 离线%@，准备唤醒热点"), host, rssiLabel)
            }
        case .waking(let host):
            return String(format: hotspotText("已向 %@ 发送蓝牙热点唤醒指令…"), host)
        case .recovered(let host):
            return String(format: hotspotText("%@ 已连上热点并恢复网络"), host)
        }
    }

    func startIfNeeded() {
        if central == nil {
            var options: [String: Any] = [CBCentralManagerOptionShowPowerAlertKey: true]
            if let modes = Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String],
               modes.contains("bluetooth-central") {
                options[CBCentralManagerOptionRestoreIdentifierKey] = CollieHotspotBLEProtocol.restoreIdentifier
            }
            central = CBCentralManager(delegate: self, queue: .main, options: options)
            return
        }
        handleCentralState()
    }

    func stop() {
        pendingManualWake = false
        awaitingShortcutReturn = false
        if let central {
            if central.isScanning {
                central.stopScan()
            }
            if let peripheral {
                central.cancelPeripheralConnection(peripheral)
            }
        }
        peripheral = nil
        statusCharacteristic = nil
        commandCharacteristic = nil
        phase = .disabled
    }

    /// Manually wakes the nearby MacBook's hotspot connection over BLE and optionally runs the iOS Hotspot Shortcut.
    func triggerManualWake(runShortcut: Bool = false) {
        pendingManualWake = true
        if !isEnabled {
            isEnabled = true
        } else {
            startIfNeeded()
        }
        let targetHost = lastMacStatus?.host ?? peripheral?.name ?? "MacBook"
        phase = .waking(host: targetHost)
        if sendCommand(.wakeHotspot) {
            pendingManualWake = false
            lastWakeDate = Date()
        } else if let peripheral, peripheral.state == .connected {
            peripheral.discoverServices([CollieHotspotBLEProtocol.serviceUUID])
        } else {
            beginScanIfPoweredOn()
        }
        if runShortcut || autoRunShortcutInForeground {
            launchHotspotShortcutIfPossible()
        }
    }

    func applicationDidBecomeActive() {
        guard isEnabled else { return }
        startIfNeeded()
        if awaitingShortcutReturn {
            awaitingShortcutReturn = false
            _ = sendCommand(.wifiReady)
        }
        if let peripheral, peripheral.state == .connected, let statusCharacteristic {
            peripheral.readValue(for: statusCharacteristic)
        }
    }

    private func launchHotspotShortcutIfPossible() {
        guard UIApplication.shared.applicationState == .active,
              let url = CollieHotspotBLEProtocol.shortcutURL(named: shortcutName) else { return }
        awaitingShortcutReturn = true
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func handleCentralState() {
        guard let central else { return }
        switch central.state {
        case .poweredOn:
            if let peripheral, peripheral.state == .connected || peripheral.state == .connecting {
                if peripheral.state == .connected {
                    peripheral.discoverServices([CollieHotspotBLEProtocol.serviceUUID])
                }
                return
            }
            beginScanIfPoweredOn()
        case .poweredOff:
            phase = .bluetoothUnavailable(hotspotText("蓝牙已关闭，请在控制中心开启蓝牙。"))
        case .unauthorized:
            phase = .bluetoothUnavailable(hotspotText("未获得蓝牙权限，请在系统设置中允许“一呼”使用蓝牙。"))
        case .unsupported:
            phase = .bluetoothUnavailable(hotspotText("当前设备不支持蓝牙低功耗 (BLE)。"))
        case .resetting, .unknown:
            phase = .scanning
        @unknown default:
            phase = .scanning
        }
    }

    private func beginScanIfPoweredOn() {
        guard let central, central.state == .poweredOn else { return }
        let connected = central.retrieveConnectedPeripherals(withServices: [CollieHotspotBLEProtocol.serviceUUID])
        if let existing = connected.first {
            connect(to: existing)
            return
        }
        if !central.isScanning {
            central.scanForPeripherals(
                withServices: [CollieHotspotBLEProtocol.serviceUUID],
                options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
            )
        }
        if !pendingManualWake {
            phase = .scanning
        }
    }

    private func connect(to target: CBPeripheral) {
        guard let central else { return }
        if central.isScanning {
            central.stopScan()
        }
        peripheral = target
        target.delegate = self
        let name = target.name ?? "MacBook"
        if !pendingManualWake {
            phase = .connecting(name)
        }
        central.connect(target, options: [
            CBConnectPeripheralOptionNotifyOnConnectionKey: true,
            CBConnectPeripheralOptionNotifyOnDisconnectionKey: true
        ])
    }

    @discardableResult
    private func sendCommand(_ action: CollieHotspotWakeCommand.Action) -> Bool {
        guard let peripheral, peripheral.state == .connected, let commandCharacteristic else { return false }
        let payload = CollieHotspotWakeCommand(
            action: action,
            ssid: hotspotSSID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? CollieHotspotBLEProtocol.defaultHotspotSSID
                : hotspotSSID.trimmingCharacters(in: .whitespacesAndNewlines),
            ts: Date().timeIntervalSince1970
        )
        guard let data = try? JSONEncoder().encode(payload) else { return false }
        let writeType: CBCharacteristicWriteType = commandCharacteristic.properties.contains(.write)
            ? .withResponse
            : .withoutResponse
        peripheral.writeValue(data, for: commandCharacteristic, type: writeType)
        return true
    }

    private func handleStatusPayload(_ data: Data) {
        guard let status = try? JSONDecoder().decode(CollieHotspotMacStatus.self, from: data) else { return }
        let previousState = lastMacStatus?.state
        lastMacStatus = status
        switch status.state {
        case .online:
            if previousState == .offline || previousState == .connecting || isWakingPhase {
                phase = .recovered(host: status.host)
                onMacBecameOnline?()
            } else {
                phase = .monitoring(host: status.host, state: .online, rssi: lastRSSI)
            }
        case .connecting:
            phase = .monitoring(host: status.host, state: .connecting, rssi: lastRSSI)
        case .offline:
            phase = .monitoring(host: status.host, state: .offline, rssi: lastRSSI)
            if pendingManualWake || CollieHotspotBLEProtocol.shouldAutoTriggerWake(
                status: status,
                rssi: lastRSSI,
                lastWakeAt: lastWakeDate
            ) {
                pendingManualWake = false
                lastWakeDate = Date()
                phase = .waking(host: status.host)
                _ = sendCommand(.wakeHotspot)
                if autoRunShortcutInForeground {
                    launchHotspotShortcutIfPossible()
                }
            }
        }
    }

    private var isWakingPhase: Bool {
        if case .waking = phase { return true }
        return false
    }
}

extension CollieHotspotBridge: CBCentralManagerDelegate {
    nonisolated func centralManagerDidUpdateState(_ central: CBCentralManager) {
        Task { @MainActor [weak self] in
            self?.handleCentralState()
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
        let restoredIDs: [UUID] = (dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral])?
            .map(\.identifier) ?? []
        Task { @MainActor [weak self] in
            guard let self, self.isEnabled, let central = self.central else { return }
            let peripherals = central.retrievePeripherals(withIdentifiers: restoredIDs)
            if let first = peripherals.first {
                self.peripheral = first
                first.delegate = self
                if first.state == .connected {
                    first.discoverServices([CollieHotspotBLEProtocol.serviceUUID])
                } else if central.state == .poweredOn {
                    central.connect(first, options: nil)
                }
            }
        }
    }

    nonisolated func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        let id = peripheral.identifier
        let rssiValue = RSSI.intValue
        Task { @MainActor [weak self] in
            guard let self, self.isEnabled, let central = self.central else { return }
            if rssiValue != 127 {
                self.lastRSSI = rssiValue
            }
            guard self.pendingManualWake || CollieHotspotBLEProtocol.isNearby(rssi: rssiValue) else { return }
            if let discovered = central.retrievePeripherals(withIdentifiers: [id]).first {
                self.connect(to: discovered)
            }
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let id = peripheral.identifier
        Task { @MainActor [weak self] in
            guard let self, let current = self.peripheral, current.identifier == id else { return }
            current.readRSSI()
            current.discoverServices([CollieHotspotBLEProtocol.serviceUUID])
        }
    }

    nonisolated func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: (any Error)?
    ) {
        Task { @MainActor [weak self] in
            guard let self, self.isEnabled else { return }
            self.statusCharacteristic = nil
            self.commandCharacteristic = nil
            self.beginScanIfPoweredOn()
        }
    }

    nonisolated func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: (any Error)?
    ) {
        Task { @MainActor [weak self] in
            guard let self, self.isEnabled else { return }
            self.statusCharacteristic = nil
            self.commandCharacteristic = nil
            // Keep automatic reconnection armed for when the MacBook comes back in BLE range.
            if let current = self.peripheral, let central = self.central, central.state == .poweredOn {
                central.connect(current, options: [
                    CBConnectPeripheralOptionNotifyOnConnectionKey: true,
                    CBConnectPeripheralOptionNotifyOnDisconnectionKey: true
                ])
            } else {
                self.beginScanIfPoweredOn()
            }
        }
    }
}

extension CollieHotspotBridge: CBPeripheralDelegate {
    nonisolated func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: (any Error)?) {
        let value = RSSI.intValue
        Task { @MainActor [weak self] in
            guard let self, error == nil, value != 127 else { return }
            self.lastRSSI = value
        }
    }

    nonisolated func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        Task { @MainActor [weak self] in
            guard let self, error == nil, let current = self.peripheral else { return }
            for service in current.services ?? [] where service.uuid == CollieHotspotBLEProtocol.serviceUUID {
                current.discoverCharacteristics([
                    CollieHotspotBLEProtocol.statusCharacteristicUUID,
                    CollieHotspotBLEProtocol.commandCharacteristicUUID
                ], for: service)
            }
        }
    }

    nonisolated func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: (any Error)?
    ) {
        let hasError = (error != nil)
        Task { @MainActor [weak self] in
            guard let self, !hasError, let current = self.peripheral else { return }
            for discoveredService in current.services ?? []
                where discoveredService.uuid == CollieHotspotBLEProtocol.serviceUUID {
                for characteristic in discoveredService.characteristics ?? [] {
                    if characteristic.uuid == CollieHotspotBLEProtocol.statusCharacteristicUUID {
                        self.statusCharacteristic = characteristic
                        current.setNotifyValue(true, for: characteristic)
                        current.readValue(for: characteristic)
                    } else if characteristic.uuid == CollieHotspotBLEProtocol.commandCharacteristicUUID {
                        self.commandCharacteristic = characteristic
                        if self.pendingManualWake {
                            self.pendingManualWake = false
                            self.lastWakeDate = Date()
                            _ = self.sendCommand(.wakeHotspot)
                        }
                    }
                }
            }
        }
    }

    nonisolated func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: (any Error)?
    ) {
        let hasError = (error != nil)
        let uuidString = characteristic.uuid.uuidString
        let value = characteristic.value
        Task { @MainActor [weak self] in
            guard let self, !hasError,
                  uuidString.caseInsensitiveCompare(CollieHotspotBLEProtocol.statusCharacteristicUUIDString) == .orderedSame,
                  let value else { return }
            self.handleStatusPayload(value)
        }
    }
}
#endif
