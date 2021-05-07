extension Parser {
    public static func prefix<I>(while p: @escaping (I.Element) -> Bool) -> Parser<I, I.SubSequence> where I: Collection, I.SubSequence == I, I.Element: Equatable {
        Parser<I, I.SubSequence> { input in
            let output = input.prefix(while: p)
            input.removeFirst(output.count)
            return output
        }
    }
}
