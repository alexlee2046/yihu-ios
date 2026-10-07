// Derived from soniqo/speech-swift ca4daaf9be7cccf230f691e443cd80b7a0bd8d97 (Apache-2.0).
import Foundation

struct Qwen3ASRTokens: Sendable {
    static let audioStartTokenId = 151669
    static let audioEndTokenId = 151670
    static let imStartTokenId = 151644
    static let imEndTokenId = 151645
    static let asrTextTokenId = 151704
    static let newlineTokenId = 198
    static let systemTokenId = 8948
    static let userTokenId = 872
    static let assistantTokenId = 77091
}
