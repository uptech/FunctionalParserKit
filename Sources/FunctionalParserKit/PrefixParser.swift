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

extension Collection where Element: Equatable {
    public func range(of subSequence: SubSequence) -> Range<Index>? {
        guard subSequence.count <= self.count else { return nil }

        var offset = 0
        let subSequenceCount = subSequence.count
        let offsetLimit = self.count - subSequenceCount

        while (offset < offsetLimit) {
            let curRange: Range<Index> = (self.index(self.startIndex, offsetBy: offset)..<self.index(self.startIndex, offsetBy: (subSequenceCount + offset)))
            if self[curRange].elementsEqual(subSequence) {
                return curRange
            }
            offset += 1
        }
        return nil
    }
}

extension Parser where Input: Collection,
                       Input.SubSequence == Input,
                       Input.Element: Equatable,
                       Output == Input.SubSequence {
    
    public static func prefix(upTo subSequence: Input.SubSequence) -> Self {
        Self { input in
            guard let endIndex = input.range(of: subSequence)?.lowerBound
            else { return nil }

            let match = input[..<endIndex]

            input = input[endIndex...]

            return match
        }
    }

    public static func prefix(through subSequence: Input.SubSequence) -> Self {
        Self { input in
            guard let endIndex = input.range(of: subSequence)?.upperBound
            else { return nil }

            let match = input[..<endIndex]

            input = input[endIndex...]

            return match
        }
    }
}

extension Parser where Input: Collection,
                       Input.SubSequence == Input,
                       Output == Input.SubSequence {
    public static func everything() -> Self {
        Self { input in
            let match = input
            input = input[input.endIndex...]
            return match
        }
    }
}
