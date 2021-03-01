import Foundation

extension Parser where Input: Collection,
                       Input.SubSequence == Input,
                       Input.Element: Equatable,
                       Output == Void {
    public static func prefix(_ p: Input.SubSequence) -> Self {
        Self { input in
            guard input.starts(with: p) else { return nil }
            input.removeFirst(p.count)
            return ()
        }
    }
}

extension Parser where Input == Substring, Output == Substring {
    public static func prefix(upTo substring: Substring) -> Self {
        Self { input in
            guard let endIndex = input.range(of: substring)?.lowerBound
            else { return nil }

            let match = input[..<endIndex]

            input = input[endIndex...]

            return match
        }
    }

    public static func prefix(through substring: Substring) -> Self {
        Self { input in
            guard let endIndex = input.range(of: substring)?.upperBound
            else { return nil }

            let match = input[..<endIndex]

            input = input[endIndex...]

            return match
        }
    }
}

extension Parser where Input == Substring, Output == Substring {
    public static let everything = Self { input in
        let match = input
        input = input[input.endIndex...]
        return match
    }
}
