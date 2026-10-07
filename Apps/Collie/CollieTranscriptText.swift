import Foundation

/// Applies a local Traditional-to-Simplified glyph fallback to transcripts.
///
/// This intentionally does not translate text or replace regional vocabulary.
/// Clearly structured content is kept exactly as received so streaming updates
/// cannot gradually rewrite URLs or identifiers.
enum CollieTranscriptText {
    private static let traditionalToSimplified = StringTransform("Hant-Hans")

    static func simplified(_ text: String) -> String {
        guard !text.isEmpty else { return text }

        var result = ""
        result.reserveCapacity(text.utf8.count)

        // A blank line delimits a paragraph. Keep the separator itself exactly
        // as received, including CRLF and whitespace-only blank lines.
        var paragraphStart = text.startIndex
        var lineStart = text.startIndex
        var cursor = text.startIndex

        while cursor < text.endIndex {
            // A blank line inside a code fence is not a prose paragraph break.
            // Skip the whole protected span before looking for separators.
            if let code = codeRange(at: cursor, in: text[...]) {
                if let newline = text[code].lastIndex(where: isLineBreak) {
                    lineStart = text.index(after: newline)
                }
                cursor = code.upperBound
                continue
            }
            let next = text.index(after: cursor)
            if isLineBreak(text[cursor]) {
                if text[lineStart..<cursor].allSatisfy(isHorizontalWhitespace) {
                    result += simplifyParagraph(text[paragraphStart..<lineStart])
                    result += text[lineStart..<next]
                    paragraphStart = next
                }
                lineStart = next
            }
            cursor = next
        }

        result += simplifyParagraph(text[paragraphStart..<text.endIndex])
        return result
    }

    private static func simplifyParagraph(_ paragraph: Substring) -> String {
        guard !paragraph.isEmpty else { return "" }

        // This is a conservative false-positive guard, not general language
        // detection: a paragraph containing kana is treated as Japanese and is
        // left alone so its shared Han characters are not rewritten.
        guard !containsKana(paragraph) else { return String(paragraph) }

        var result = ""
        result.reserveCapacity(paragraph.utf8.count)
        var plainStart = paragraph.startIndex
        var cursor = paragraph.startIndex

        while cursor < paragraph.endIndex {
            let protectedRange = codeRange(at: cursor, in: paragraph)
                ?? urlRange(at: cursor, in: paragraph)
                ?? emailRange(at: cursor, in: paragraph)
                ?? technicalTokenRange(at: cursor, in: paragraph)

            guard let protectedRange else {
                cursor = paragraph.index(after: cursor)
                continue
            }

            result += transformed(paragraph[plainStart..<protectedRange.lowerBound])
            result += paragraph[protectedRange]
            cursor = protectedRange.upperBound
            plainStart = cursor
        }

        result += transformed(paragraph[plainStart..<paragraph.endIndex])
        return result
    }

    private static func transformed(_ text: Substring) -> String {
        let value = String(text)
        return value.applyingTransform(traditionalToSimplified, reverse: false) ?? value
    }

    private static func codeRange(
        at start: Substring.Index,
        in text: Substring
    ) -> Range<Substring.Index>? {
        guard text[start] == "`" else { return nil }

        var markerEnd = start
        while markerEnd < text.endIndex, text[markerEnd] == "`" {
            markerEnd = text.index(after: markerEnd)
        }

        let marker = text[start..<markerEnd]
        if let closingStart = text.range(
            of: marker,
            range: markerEnd..<text.endIndex
        )?.lowerBound {
            let closingEnd = text.index(closingStart, offsetBy: marker.count)
            return start..<closingEnd
        }

        // A partial transcript can end while inline code or a fence is still
        // open. Protect the remainder now rather than changing it between
        // streaming updates.
        return start..<text.endIndex
    }

    private static func urlRange(
        at start: Substring.Index,
        in text: Substring
    ) -> Range<Substring.Index>? {
        // Avoid scanning every suffix of a long ASCII word for a scheme.
        // A URL may immediately follow Chinese prose without a space.
        guard isTokenBoundary(start, in: text)
                || containsHan(text[text.index(before: start)...text.index(before: start)]) else { return nil }
        guard hasExplicitURLPrefix(at: start, in: text) else { return nil }
        return start..<tokenEnd(from: start, in: text, url: true)
    }

    private static func hasExplicitURLPrefix(
        at start: Substring.Index,
        in text: Substring
    ) -> Bool {
        if hasCaseInsensitivePrefix("www.", at: start, in: text) { return true }
        guard isASCIIAlpha(text[start]) else { return false }

        var cursor = text.index(after: start)
        while cursor < text.endIndex, isURLSchemeCharacter(text[cursor]) {
            cursor = text.index(after: cursor)
        }
        guard cursor < text.endIndex, text[cursor] == ":" else { return false }
        cursor = text.index(after: cursor)
        guard cursor < text.endIndex, text[cursor] == "/" else { return false }
        cursor = text.index(after: cursor)
        return cursor < text.endIndex && text[cursor] == "/"
    }

    private static func hasCaseInsensitivePrefix(
        _ prefix: String,
        at start: Substring.Index,
        in text: Substring
    ) -> Bool {
        guard let end = text.index(start, offsetBy: prefix.count, limitedBy: text.endIndex) else {
            return false
        }
        return String(text[start..<end]).caseInsensitiveCompare(prefix) == .orderedSame
    }

    private static func emailRange(
        at start: Substring.Index,
        in text: Substring
    ) -> Range<Substring.Index>? {
        guard isTokenBoundary(start, in: text) else { return nil }

        let end = tokenEnd(from: start, in: text, url: false)
        let token = text[start..<end]
        guard let at = token.firstIndex(of: "@"),
              at != token.startIndex,
              token.index(after: at) != token.endIndex,
              token[token.index(after: at)...].contains(".") else {
            return nil
        }
        return start..<end
    }

    private static func technicalTokenRange(
        at start: Substring.Index,
        in text: Substring
    ) -> Range<Substring.Index>? {
        guard isTokenBoundary(start, in: text) else { return nil }

        let end = tokenEnd(from: start, in: text, url: false)
        guard end != start else { return nil }
        let token = text[start..<end]
        // Let the URL scanner find an embedded scheme after adjacent prose,
        // rather than treating the whole Chinese sentence prefix as a path.
        guard !token.contains("://") else { return nil }

        let isPath = token.hasPrefix("/")
            || token.hasPrefix("~/")
            || token.hasPrefix("./")
            || token.hasPrefix("../")
            || token.hasPrefix("\\\\")
            || isWindowsDrivePath(token)
            || token.contains("/")
            || token.contains("\\")

        guard containsHan(token) else { return nil }
        if isPath { return start..<end }

        // Chinese identifiers are protected only when they carry a clear code
        // marker. Ordinary adjacent Chinese and English prose is still eligible
        // for glyph conversion.
        let hasIdentifierMarker = token.contains("_")
            || token.contains("::")
            || token.contains("->")
            || token.contains(".")
            || token.hasPrefix("$")
            || token.hasPrefix("#")
        return hasIdentifierMarker ? start..<end : nil
    }

    private static func tokenEnd(
        from start: Substring.Index,
        in text: Substring,
        url: Bool
    ) -> Substring.Index {
        var cursor = start
        var urlBrackets: [Character] = []
        while cursor < text.endIndex {
            let character = text[cursor]
            if url {
                switch character {
                case "(": urlBrackets.append(")")
                case "[": urlBrackets.append("]")
                case "{": urlBrackets.append("}")
                case ")", "]", "}":
                    // Keep balanced brackets within a URL path/query, but let
                    // a prose wrapper close without swallowing following text.
                    guard urlBrackets.last == character else { return cursor }
                    urlBrackets.removeLast()
                default: break
                }
            }
            if isTokenTerminator(character, url: url) { break }
            cursor = text.index(after: cursor)
        }
        return cursor
    }

    private static func isTokenBoundary(
        _ index: Substring.Index,
        in text: Substring
    ) -> Bool {
        guard index != text.startIndex else { return true }
        return isTokenTerminator(text[text.index(before: index)], url: false)
    }

    private static func isTokenTerminator(_ character: Character, url: Bool) -> Bool {
        if character.unicodeScalars.allSatisfy({ CharacterSet.whitespacesAndNewlines.contains($0) }) {
            return true
        }

        // ASCII parentheses, comma, semicolon, apostrophe etc. can be real URL
        // path/query characters. Preserve through them rather than converting a
        // later Chinese segment of the same URL. Prose punctuation still bounds it.
        if url {
            return "`<>\"“”‘’，。！？；：（）【】《》「」『』".contains(character)
        }
        switch character {
        case "`", "<", ">", "\"", "'", "“", "”", "‘", "’",
             ",", ";", "!", "(", ")", "[", "]", "{", "}",
             "，", "。", "！", "？", "；", "：", "、",
             "（", "）", "【", "】", "《", "》", "「", "」", "『", "』":
            return true
        case "=", "*", "|", "?":
            return !url
        default:
            return false
        }
    }

    private static func isURLSchemeCharacter(_ character: Character) -> Bool {
        isASCIIAlpha(character)
            || character.unicodeScalars.allSatisfy { (48...57).contains($0.value) }
            || character == "+" || character == "-" || character == "."
    }

    private static func isASCIIAlpha(_ character: Character) -> Bool {
        character.unicodeScalars.allSatisfy {
            (65...90).contains($0.value) || (97...122).contains($0.value)
        }
    }

    private static func isWindowsDrivePath(_ token: Substring) -> Bool {
        guard token.count >= 3 else { return false }
        let first = token.startIndex
        let colon = token.index(after: first)
        let slash = token.index(after: colon)
        guard token[colon] == ":", token[slash] == "\\" else { return false }
        return token[first].unicodeScalars.allSatisfy {
            (65...90).contains($0.value) || (97...122).contains($0.value)
        }
    }

    private static func containsHan(_ text: Substring) -> Bool {
        text.unicodeScalars.contains { scalar in
            switch scalar.value {
            case 0x3400...0x4DBF, 0x4E00...0x9FFF, 0xF900...0xFAFF,
                 0x20000...0x2FA1F, 0x30000...0x323AF:
                return true
            default:
                return false
            }
        }
    }

    private static func containsKana(_ text: Substring) -> Bool {
        text.unicodeScalars.contains { scalar in
            switch scalar.value {
            case 0x3040...0x30FF, 0x31F0...0x31FF, 0xFF66...0xFF9D,
                 0x1B000...0x1B16F:
                return true
            default:
                return false
            }
        }
    }

    private static func isLineBreak(_ character: Character) -> Bool {
        character == "\n" || character == "\r" || character == "\r\n"
            || character == "\u{2028}" || character == "\u{2029}"
    }

    private static func isHorizontalWhitespace(_ character: Character) -> Bool {
        character.unicodeScalars.allSatisfy { CharacterSet.whitespaces.contains($0) }
    }
}
