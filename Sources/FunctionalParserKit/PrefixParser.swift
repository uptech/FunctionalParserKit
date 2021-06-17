import Foundation

extension Parser {
    public static func prefix<I>(_ p: I.SubSequence) -> Parser<I, Void> where I: Collection,
                                                                              I.SubSequence == I,
                                                                              I.Element: Equatable {
        Parser<I, Void> { input in
            guard input.starts(with: p) else { return nil }
            input.removeFirst(p.count)
            return ()
        }
    }

    public static func prefixE<I>(_ p: I.Element) -> Parser<I, Void> where I:Collection,
                                                                           I.SubSequence == I,
                                                                           I.Element: Equatable {
        Parser<I, Void> { input in
            guard let first = input.first else { return nil }
            guard first == p else { return nil }
            input.removeFirst(1)
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

        while (offset <= offsetLimit) {
            let curRange: Range<Index> = (self.index(self.startIndex, offsetBy: offset)..<self.index(self.startIndex, offsetBy: (subSequenceCount + offset)))
            if self[curRange].elementsEqual(subSequence) {
                return curRange
            }
            offset += 1
        }
        return nil
    }
}

extension Parser  {
    public static func prefix<I>(upTo subSequence: I.SubSequence) -> Parser<I, I.SubSequence> where I: Collection,
                                                                                                    I.SubSequence == I,
                                                                                                    I.Element: Equatable {
        Parser<I, I.SubSequence> { input in
            guard let endIndex = input.range(of: subSequence)?.lowerBound
            else { return nil }

            let match = input[..<endIndex]

            input = input[endIndex...]

            return match
        }
    }

    public static func prefix<I>(through subSequence: I.SubSequence) -> Parser<I, I.SubSequence> where I: Collection,
                                                                                                       I.SubSequence == I,
                                                                                                       I.Element: Equatable {
        Parser<I, I.SubSequence> { input in
            guard let endIndex = input.range(of: subSequence)?.upperBound
            else { return nil }

            let match = input[..<endIndex]

            input = input[endIndex...]

            return match
        }
    }
}

extension Parser {
    public static func everything<I>() -> Parser<I, I.SubSequence> where  I: Collection,
                                                                          I.SubSequence == I {
        Parser<I, I.SubSequence> { input in
            let match = input
            input = input[input.endIndex...]
            return match
        }
    }
}
