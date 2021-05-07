public struct Parser<Input, Output> {
    public let run: (inout Input) -> Output?
}

// Note: This run varient is just used for testing so that we can easily see
// the match as well as the resulting substring so we can verify appropriately
extension Parser {
    public func run(_ input: Input) -> (match: Output?, rest: Input) {
        var input = input
        let match = self.run(&input)
        return (match, input)
    }
}

extension Parser {
    public func map<NewOutput>(_ f: @escaping (Output) -> NewOutput) -> Parser<Input, NewOutput> {
        .init { input in
            self.run(&input).map(f)
        }
    }
}

// Sequence parsers together
extension Parser {
    public func flatMap<NewOutput>(_ f: @escaping (Output) -> Parser<Input, NewOutput>) -> Parser<Input, NewOutput> {
        .init { input in
            let original = input
            let output = self.run(&input)
            let newParser = output.map(f)
            guard let newOutput = newParser?.run(&input) else {
                input = original
                return nil
            }
            return newOutput
        }
    }
}

extension Parser {
    public static func always<O>(_ output: O) -> Parser<Input, O> {
        Parser<Input, O> { _ in output }
    }

    public static func never() -> Self {
        Self { _ in nil }
    }
}

// Piece together multiple parsers in parallel
public func zip<Input, Output1, Output2>(
    _ p1: Parser<Input, Output1>,
    _ p2: Parser<Input, Output2>
) -> Parser<Input, (Output1, Output2)> {
    .init { input -> (Output1, Output2)? in
        let original = input
        guard let output1 = p1.run(&input) else { return nil }
        guard let output2 = p2.run(&input) else {
            input = original
            return nil
        }
        return (output1, output2)
    }
}

public func zip<Input, Output1, Output2, Output3>(
    _ p1: Parser<Input, Output1>,
    _ p2: Parser<Input, Output2>,
    _ p3: Parser<Input, Output3>
) -> Parser<Input, (Output1, Output2, Output3)> {
    zip(p1, zip(p2, p3))
        .map { output1, output23 in
            (output1, output23.0, output23.1)
        }
}

public func zip<Input, A, B, C, D>(
    _ a: Parser<Input, A>,
    _ b: Parser<Input, B>,
    _ c: Parser<Input, C>,
    _ d: Parser<Input, D>
) -> Parser<Input, (A, B, C, D)> {
    zip(a, zip(b, c, d))
        .map { a , bcd in (a, bcd.0, bcd.1, bcd.2) }
}

public func zip<Input, A, B, C, D, E>(
    _ a: Parser<Input, A>,
    _ b: Parser<Input, B>,
    _ c: Parser<Input, C>,
    _ d: Parser<Input, D>,
    _ e: Parser<Input, E>
) -> Parser<Input, (A, B, C, D, E)> {
    zip(a, zip(b, c, d, e))
        .map { a , bcde in (a, bcde.0, bcde.1, bcde.2, bcde.3) }
}

public func zip<Input, A, B, C, D, E, F>(
    _ a: Parser<Input, A>,
    _ b: Parser<Input, B>,
    _ c: Parser<Input, C>,
    _ d: Parser<Input, D>,
    _ e: Parser<Input, E>,
    _ f: Parser<Input, F>
) -> Parser<Input, (A, B, C, D, E, F)> {
    zip(a, zip(b, c, d, e, f))
        .map { a , bcdef in (a, bcdef.0, bcdef.1, bcdef.2, bcdef.3, bcdef.4) }
}

extension Parser {
    public static func oneOf<I, O>(_ ps: [Parser<I, O>]) -> Parser<I, O> {
        .init { input in
            for p in ps {
                if let match = p.run(&input) {
                    return match
                }
            }
            return nil
        }
    }

    public static func oneOf<I, O>(_ ps: Parser<I, O>...) -> Parser<I, O> {
        self.oneOf(ps)
    }
}

extension Parser {
    public static func first<I, O>(_ p: Parser<I.Element, O>) -> Parser<I, O> where I: Collection,
                                                                                    I.SubSequence == I,
                                                                                    I.Element: Equatable,
                                                                                    I.Element: Collection {
        Parser<I, O> { input in
            guard input.count > 0 else { return nil }
            guard var childParserInput = input.first else { return nil }

            guard let match = p.run(&childParserInput) else { return nil }
            guard childParserInput.isEmpty else { return nil }

            input = input.dropFirst()

            return match
        }
    }
}

// Provide Ergonomics so that we can use string literals in place of .prefix()
// calls so that the string literals will be uplifted int prefix parsers for
// us making things easier to read.
//
// let coord = zip(latitude, ", ", longitude)
//
// rather than
//
// let coord = zip(latitude, .prefix(", "), longitude)
extension Parser: ExpressibleByUnicodeScalarLiteral where Input == Substring, Output == Void {
    public typealias UnicodeScalarLiteralType = StringLiteralType
}

extension Parser: ExpressibleByExtendedGraphemeClusterLiteral where Input == Substring, Output == Void {
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
}

extension Parser: ExpressibleByStringLiteral where Input == Substring, Output == Void {
    public typealias StringLiteralType = String

    public init(stringLiteral value: String) {
        self = .prefix(value[...])
    }
}
