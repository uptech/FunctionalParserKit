extension Parser {
    public func zeroOrMore(
        separatedBy separator: Parser<Input, Void> = .always(())
    ) -> Parser<Input, [Output]> {
        Self.zeroOrMore(self, separatedBy: separator)
    }

    public static func zeroOrMore<I,O>(
        _ p: Parser<I,O>,
        separatedBy separator: Parser<I, Void> = .always(())
    ) -> Parser<I,[O]> {
        Parser<I, [O]> { input in
            var rest = input
            var matches: [O] = []
            while let match = p.run(&input) {
                rest = input
                matches.append(match)
                if separator.run(&input) == nil {
                    return matches
                }
            }
            input = rest
            return matches
        }
    }
}
