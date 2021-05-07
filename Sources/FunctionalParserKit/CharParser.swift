import Foundation

extension Parser {
    public static func char() -> Parser<Substring, Character> {
        Parser<Substring, Character> { input in
            guard !input.isEmpty else { return nil }
            return input.removeFirst()
        }
    }
}
