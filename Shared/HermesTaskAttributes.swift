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

        var isFinished: Bool { phase != "running" }

        var phaseText: String {
            switch phase {
            case "done": return "已完成"
            case "failed": return "出错了"
            case "interrupted": return "已中断"
            default: return toolName.map { "正在执行：\(Self.toolLabel($0))" } ?? "正在思考…"
            }
        }

        static func toolLabel(_ name: String) -> String {
            switch name {
            case "terminal": return "终端命令"
            case "web_search", "search": return "网页搜索"
            case "read_file", "file_read": return "读取文件"
            case "write_file", "file_write", "patch": return "修改文件"
            case "browser", "browser_navigate": return "浏览网页"
            default: return name
            }
        }
    }

    var sessionId: String
}
