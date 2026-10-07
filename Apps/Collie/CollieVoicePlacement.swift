import CoreGraphics
import Foundation

/// Where the floating microphone sits, remembered per workbench origin so it
/// can be moved off each page's own controls (e.g. a send button).
struct CollieVoicePlacement: Codable, Equatable {
    enum Side: String, Codable { case leading, trailing }

    var side: Side = .trailing
    /// Distance from the bottom of the workbench area to the microphone.
    var bottom: CGFloat = 24

    static let defaultsKey = "collie.voice.placement"
    static let minimumBottom: CGFloat = 8
    /// Room kept above the button for its live-text and status cards.
    static let topReserve: CGFloat = 160
    /// Horizontal inset plus half the 76 pt touch target.
    static let centerInset: CGFloat = 16 + 38

    /// Applies a finished drag: crossing the middle flips sides, and the
    /// vertical position is clamped so the button stays fully on screen.
    func moved(by translation: CGSize, in size: CGSize) -> CollieVoicePlacement {
        let startX = side == .trailing ? size.width - Self.centerInset : Self.centerInset
        let endX = startX + translation.width
        let maxBottom = max(Self.minimumBottom, size.height - Self.topReserve)
        return CollieVoicePlacement(
            side: endX < size.width / 2 ? .leading : .trailing,
            bottom: min(max(bottom - translation.height, Self.minimumBottom), maxBottom)
        )
    }

    /// Keeps the live drag inside the same bounds `moved(by:in:)` will commit to.
    func clampedDrag(_ translation: CGSize, in size: CGSize) -> CGSize {
        let travel = max(0, size.width - 2 * Self.centerInset)
        let x = side == .trailing ? min(0, max(-travel, translation.width)) : max(0, min(travel, translation.width))
        let maxBottom = max(Self.minimumBottom, size.height - Self.topReserve)
        let y = min(bottom - Self.minimumBottom, max(bottom - maxBottom, translation.height))
        return CGSize(width: x, height: y)
    }

    func flipped() -> CollieVoicePlacement {
        CollieVoicePlacement(side: side == .trailing ? .leading : .trailing, bottom: bottom)
    }

    static func load(for origin: URL, defaults: UserDefaults = .standard) -> CollieVoicePlacement {
        guard let data = defaults.dictionary(forKey: defaultsKey)?[origin.absoluteString] as? Data,
              let placement = try? JSONDecoder().decode(CollieVoicePlacement.self, from: data)
        else { return CollieVoicePlacement() }
        return placement
    }

    func save(for origin: URL, defaults: UserDefaults = .standard) {
        guard let data = try? JSONEncoder().encode(self) else { return }
        var all = defaults.dictionary(forKey: Self.defaultsKey) ?? [:]
        all[origin.absoluteString] = data
        defaults.set(all, forKey: Self.defaultsKey)
    }
}
