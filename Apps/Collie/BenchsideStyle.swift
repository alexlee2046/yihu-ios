import SwiftUI
import UIKit

// Stitch direction: a portable precision recorder translated to native SwiftUI.
// System surfaces and a single cool-teal action color keep state legible without Web-style effects.
enum BenchsideStyle {
    static let canvas = Color(uiColor: .systemGroupedBackground)
    static let surface = Color(uiColor: .systemBackground)
    static let surfaceRaised = Color(uiColor: .secondarySystemGroupedBackground)
    static let surfaceMuted = Color(uiColor: .tertiarySystemGroupedBackground)
    static let ink = Color(uiColor: .label)
    static let secondary = Color(uiColor: .secondaryLabel)
    static let border = Color(uiColor: .separator)
    static let accent = Color(uiColor: UIColor { traits in
        if traits.userInterfaceStyle == .dark {
            return UIColor(red: 0.40, green: 0.83, blue: 0.81, alpha: 1)
        }
        return UIColor(red: 0.0, green: 0.37, blue: 0.38, alpha: 1)
    })
    static let onAccent = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark ? .black : .white
    })
    static let accentSoft = accent.opacity(0.12)
    static let accentBorder = accent.opacity(0.28)

    @ViewBuilder
    static func chromeIcon(_ systemName: String, active: Bool = false) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(active ? accent : ink)
            .frame(width: 32, height: 32)
            .background(
                Circle()
                    .fill(active ? accentSoft : surfaceRaised)
            )
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
    }

    @ViewBuilder
    static func rowBadge(_ systemName: String, tint: Color = accent) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: 28, height: 28)
            .background(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(tint.opacity(0.12))
            )
    }
}
