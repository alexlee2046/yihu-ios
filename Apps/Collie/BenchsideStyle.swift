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
}
