import ActivityKit
import Foundation

/// Live Activity for a Hermes long task. The type name and field names are the
/// push contract with the your separately configured server relay (attributes-type "HermesTaskAttributes").
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
        /// Optional display-only label; old payloads still default to Hermes.
        var agentName: String? = nil

        var displayTitle: String {
            let name = agentName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return name.isEmpty ? "Hermes" : String(name.prefix(80))
        }

        var isFinished: Bool { phase != "running" }

        var phaseText: String {
            switch phase {
            case "done": return NSLocalizedString("已完成", tableName: "Yihu", comment: "")
            case "failed": return NSLocalizedString("出错了", tableName: "Yihu", comment: "")
            case "interrupted": return NSLocalizedString("已中断", tableName: "Yihu", comment: "")
            default:
                if let toolName {
                    return String(format: NSLocalizedString("正在执行：%@", tableName: "Yihu", comment: ""), Self.toolLabel(toolName))
                }
                return NSLocalizedString("正在思考…", tableName: "Yihu", comment: "")
            }
        }

        static func toolLabel(_ name: String) -> String {
            switch name {
            case "terminal": return NSLocalizedString("终端命令", tableName: "Yihu", comment: "")
            case "web_search", "search": return NSLocalizedString("网页搜索", tableName: "Yihu", comment: "")
            case "read_file", "file_read": return NSLocalizedString("读取文件", tableName: "Yihu", comment: "")
            case "write_file", "file_write", "patch": return NSLocalizedString("修改文件", tableName: "Yihu", comment: "")
            case "browser", "browser_navigate": return NSLocalizedString("浏览网页", tableName: "Yihu", comment: "")
            default: return name
            }
        }
    }

    var sessionId: String
}
