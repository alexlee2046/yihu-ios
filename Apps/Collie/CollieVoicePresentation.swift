import Foundation
import SwiftUI

/// Presentation-only helpers for the native voice bar. These values never feed back into the controller.
enum CollieVoicePresentation {
    /// Returns a prefix shared by the two strings, measured in Characters rather than UTF-16 units.
    static func commonPrefix(_ old: String, _ new: String) -> String {
        var result = ""
        for (oldCharacter, newCharacter) in zip(old, new) {
            guard oldCharacter == newCharacter else { break }
            result.append(oldCharacter)
        }
        return result
    }
}

/// Shows a cumulative preview while fading only the newly changed suffix.
/// Final, shortened, cleared, and non-recording states are always replaced immediately.
struct CollieTranscriptPreview: View {
    let text: String
    let allowsIncrementalAnimation: Bool

    @State private var renderedText = ""
    @State private var animatedPrefix = ""
    @State private var animatedSuffix = ""
    @State private var showsAnimatedSuffix = true
    @State private var updateID = 0
    @State private var previousAnimationAllowed = false

    var body: some View {
        Group {
            if !animatedSuffix.isEmpty && renderedText == text && allowsIncrementalAnimation {
                Text(verbatim: animatedPrefix)
                    + Text(verbatim: animatedSuffix)
                    .foregroundColor(BenchsideStyle.ink.opacity(showsAnimatedSuffix ? 1 : 0.72))
            } else {
                Text(verbatim: text)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: text))
        .onAppear {
            previousAnimationAllowed = allowsIncrementalAnimation
            replace(text, animate: false)
        }
        .onChange(of: text) { _, newText in
            // A transition into/out of recording is a hard boundary: never fade
            // a pending/final string into a new recording's preview.
            replace(newText, animate: previousAnimationAllowed && allowsIncrementalAnimation)
            previousAnimationAllowed = allowsIncrementalAnimation
        }
        .onChange(of: allowsIncrementalAnimation) { _, allowed in
            previousAnimationAllowed = allowed
            replace(text, animate: false)
        }
    }

    private func replace(_ newText: String, animate: Bool) {
        let oldText = renderedText
        renderedText = newText
        updateID += 1
        let currentID = updateID

        guard animate,
              !oldText.isEmpty,
              !newText.isEmpty,
              oldText != newText
        else {
            animatedPrefix = ""
            animatedSuffix = ""
            showsAnimatedSuffix = true
            return
        }

        let prefix = CollieVoicePresentation.commonPrefix(oldText, newText)
        let suffix = String(newText.dropFirst(prefix.count))
        guard prefix == oldText, !suffix.isEmpty else {
            animatedPrefix = ""
            animatedSuffix = ""
            showsAnimatedSuffix = true
            return
        }

        animatedPrefix = prefix
        animatedSuffix = suffix
        showsAnimatedSuffix = false
        Task { @MainActor in
            await Task.yield()
            guard currentID == updateID else { return }
            withAnimation(.easeOut(duration: 0.16)) {
                showsAnimatedSuffix = true
            }
        }
    }
}
