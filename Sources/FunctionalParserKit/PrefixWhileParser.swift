extension Parser where Input: Collection,
                       Input.SubSequence == Input,
                       Input.Element: Equatable,
                       Output == Input.SubSequence {
    public static func prefix(while p: @escaping (Input.Element) -> Bool) -> Self {
        Self { input in
            let output = input.prefix(while: p)
            input.removeFirst(output.count)
            return output
        }
    }
}
