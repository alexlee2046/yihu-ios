import SwiftUI

struct CollieCreditsView: View {
    private static let bundledNotices = loadNotices(from: .main)
    private let notices: String

    init() {
        // Bundle resources are small and immutable; cache the decoded text so
        // reopening the sheet does not perform repeated main-actor disk I/O.
        self.notices = Self.bundledNotices
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                LabeledContent {
                    Text(Self.versionLabel)
                } label: {
                    Text("版本", tableName: "Yihu")
                }
                    .font(.subheadline)
                    .accessibilityIdentifier("collie-app-version")

                Text("一呼使用的第三方源码、模型与历史图标许可。远端工作台仍称 Collie。", tableName: "Yihu")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(notices)
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)

            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .tint(BenchsideStyle.accent)
        .background(BenchsideStyle.canvas.ignoresSafeArea())
        .navigationTitle(Text("开源许可与致谢", tableName: "Yihu"))
        .navigationBarTitleDisplayMode(.inline)
    }

    static var versionLabel: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "—"
        guard let build = info?["CFBundleVersion"] as? String, build != version else { return version }
        return "\(version)（\(build)）"
    }

    private static func loadNotices(from bundle: Bundle) -> String {
        let files = [
            "ThirdPartyNotices.txt",
            "CAMPlus-ATTRIBUTION.txt",
            "CAMPlus-LICENSE.txt",
            "NOTICE.txt",
            "LICENSE.txt"
        ]
        var missingFiles: [String] = []
        let sections = files.compactMap { fileName -> String? in
            guard
                let url = bundle.url(forResource: fileName, withExtension: nil),
                let contents = try? String(contentsOf: url, encoding: .utf8)
            else {
                missingFiles.append(fileName)
                return nil
            }
            return "----- \(fileName) -----\n\n\(contents)"
        }

        if !missingFiles.isEmpty {
            let available = sections.joined(separator: "\n\n")
            let format = String(localized: "声明文件不完整，缺少：%@。请重新安装此 App。", table: "Yihu", bundle: bundle)
            let warning = String(format: format, missingFiles.joined(separator: "、"))
            return [available, warning].filter { !$0.isEmpty }.joined(separator: "\n\n")
        }
        return sections.joined(separator: "\n\n")
    }
}
