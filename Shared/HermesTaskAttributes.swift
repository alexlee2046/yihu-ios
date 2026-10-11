import ActivityKit
import Foundation

/// Universal Agent Task alias, maintaining complete backward compatibility with the APNs runtime contract.
typealias AgentTaskAttributes = HermesTaskAttributes

/// Live Activity for an Agent long task (Hermes, Claude Code, OpenHands, etc.).
/// The type name and field names are the push contract with your separately configured
/// server relay (attributes-type "HermesTaskAttributes").
struct HermesTaskAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        /// running | done | failed | interrupted
        var phase: String
        var toolName: String?
        /// Epoch seconds.
        var startedAt: Double
        var sessionId: String
        var status: String?
        var updatedAt: Double?
        /// Optional agent display name (e.g. "Claude", "OpenHands", "Hermes").
        var agentName: String? = nil

        var isFinished: Bool { phase != "running" }

        var displayTitle: String {
            guard let name = agentName?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
                return "Hermes"
            }
            return name
        }

        var phaseText: String {
            switch phase {
            case "done": return "已完成"
            case "failed": return "出错了"
            case "interrupted": return "已中断"
            default: return toolName.map { "正在执行：\(Self.toolLabel($0))" } ?? "正在思考…"
            }
        }

        static func toolLabel(_ name: String) -> String {
            let lower = name.lowercased()
            switch lower {
            case "terminal", "bash", "sh", "execute_command", "command", "run_command":
                return "终端命令"
            case "web_search", "search", "search_web", "google_search", "bing_search":
                return "网页搜索"
            case "read_file", "file_read", "view_file", "read_resource", "open_file":
                return "读取文件"
            case "write_file", "file_write", "patch", "replace_file_content", "edit_file", "apply_patch":
                return "修改文件"
            case "browser", "browser_navigate", "read_browser_page", "browse":
                return "浏览网页"
            case "git", "git_status", "git_diff", "git_commit", "git_push":
                return "版本管理"
            case "test", "test_runner", "pytest", "cargo_test", "run_tests":
                return "运行测试"
            case "database", "query", "sql_query", "db_query":
                return "查询数据库"
            case "build", "compile", "xcodebuild", "cargo_build":
                return "编译构建"
            case let mcp where mcp.starts(with: "mcp_"):
                let trimmed = String(mcp.dropFirst(4)).replacingOccurrences(of: "_", with: " ")
                return "MCP: \(trimmed)"
            default:
                return name
            }
        }
    }

    var sessionId: String
}

extension HermesTaskAttributes.ContentState {
    init(from payload: AgentTaskPayload) {
        self.init(
            phase: payload.status ?? "running",
            toolName: payload.tool,
            startedAt: payload.timestamp?.timeIntervalSince1970 ?? Date().timeIntervalSince1970,
            sessionId: payload.taskId,
            status: payload.details,
            updatedAt: Date().timeIntervalSince1970,
            agentName: payload.agentName
        )
    }

    func toPayload() -> AgentTaskPayload {
        AgentTaskPayload(
            taskId: sessionId,
            agentName: agentName,
            step: nil,
            tool: toolName,
            status: phase,
            progress: nil,
            needsApproval: nil,
            details: status,
            durationSeconds: updatedAt.map { $0 - startedAt },
            timestamp: Date(timeIntervalSince1970: startedAt)
        )
    }
}
