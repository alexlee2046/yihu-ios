import Foundation

/// Standard representation of an external AI Agent task event or progress report.
/// Compatible with ActivityKit Live Activities, Hermes APNs payloads, and MCP tools.
public struct AgentTaskPayload: Codable, Sendable, Equatable {
    public var taskId: String
    public var agentName: String?
    public var step: String?
    public var tool: String?
    public var status: String? // "running", "waiting_approval", "completed", "failed", etc.
    public var progress: Double? // 0.0 ... 1.0
    public var needsApproval: Bool?
    public var details: String?
    public var durationSeconds: Double?
    public var timestamp: Date?

    public init(
        taskId: String,
        agentName: String? = nil,
        step: String? = nil,
        tool: String? = nil,
        status: String? = nil,
        progress: Double? = nil,
        needsApproval: Bool? = nil,
        details: String? = nil,
        durationSeconds: Double? = nil,
        timestamp: Date? = nil
    ) {
        self.taskId = taskId
        self.agentName = agentName
        self.step = step
        self.tool = tool
        self.status = status
        self.progress = progress
        self.needsApproval = needsApproval
        self.details = details
        self.durationSeconds = durationSeconds
        self.timestamp = timestamp
    }

    enum CodingKeys: String, CodingKey {
        case taskId = "task_id"
        case agentName = "agent_name"
        case step
        case tool
        case status
        case progress
        case needsApproval = "needs_approval"
        case details
        case durationSeconds = "duration_seconds"
        case timestamp
    }
}

/// Generic protocol for Agent session abstraction across Collie Web, native Radar, and external relays.
@MainActor
public protocol AgentSessionProtocol: AnyObject {
    var isConnected: Bool { get }
    func sendPrompt(_ text: String) async -> Bool
}
