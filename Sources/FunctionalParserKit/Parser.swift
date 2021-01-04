public struct Parser<Output> {
    public let run: (inout Substring) -> Output?
}

// Note: This run varient is just used for testing so that we can easily see
// the match as well as the resulting substring so we can verify appropriately
extension Parser {
    public func run(_ input: String) -> (match: Output?, rest: Substring) {
        var input = input[...]
        let match = self.run(&input)
        return (match, input)
    }
}

extension Parser {
    public func map<NewOutput>(_ f: @escaping (Output) -> NewOutput) -> Parser<NewOutput> {
        .init { input in
            self.run(&input).map(f)
        }
    }
}

// Sequence parsers together
extension Parser {
    public func flatMap<NewOutput>(_ f: @escaping (Output) -> Parser<NewOutput>) -> Parser<NewOutput> {
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
    public static func always(_ output: Output) -> Self {
        Self { _ in output }
    }

    public static var never: Self {
        Self { _ in nil }
    }
}

// Piece together multiple parsers in parallel
public func zip<Output1, Output2>(
    _ p1: Parser<Output1>,
    _ p2: Parser<Output2>
) -> Parser<(Output1, Output2)> {
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

public func zip<Output1, Output2, Output3>(
    _ p1: Parser<Output1>,
    _ p2: Parser<Output2>,
    _ p3: Parser<Output3>
) -> Parser<(Output1, Output2, Output3)> {
    zip(p1, zip(p2, p3))
        .map { output1, output23 in
            (output1, output23.0, output23.1)
        }
}

public func zip<A, B, C, D>(
    _ a: Parser<A>,
    _ b: Parser<B>,
    _ c: Parser<C>,
    _ d: Parser<D>
) -> Parser<(A, B, C, D)> {
    zip(a, zip(b, c, d))
        .map { a , bcd in (a, bcd.0, bcd.1, bcd.2) }
}

public func zip<A, B, C, D, E>(
    _ a: Parser<A>,
    _ b: Parser<B>,
    _ c: Parser<C>,
    _ d: Parser<D>,
    _ e: Parser<E>
) -> Parser<(A, B, C, D, E)> {
    zip(a, zip(b, c, d, e))
        .map { a , bcde in (a, bcde.0, bcde.1, bcde.2, bcde.3) }
}

public func zip<A, B, C, D, E, F>(
    _ a: Parser<A>,
    _ b: Parser<B>,
    _ c: Parser<C>,
    _ d: Parser<D>,
    _ e: Parser<E>,
    _ f: Parser<F>
) -> Parser<(A, B, C, D, E, F)> {
    zip(a, zip(b, c, d, e, f))
        .map { a , bcdef in (a, bcdef.0, bcdef.1, bcdef.2, bcdef.3, bcdef.4) }
}

extension Parser {
    public static func oneOf(_ ps: [Self]) -> Self {
        .init { input in
            for p in ps {
                if let match = p.run(&input) {
                    return match
                }
            }
            return nil
        }
    }

    public static func oneOf(_ ps: Self...) -> Self {
        self.oneOf(ps)
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
extension Parser: ExpressibleByUnicodeScalarLiteral where Output == Void {
    public typealias UnicodeScalarLiteralType = StringLiteralType
}

extension Parser: ExpressibleByExtendedGraphemeClusterLiteral where Output == Void {
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
}

extension Parser: ExpressibleByStringLiteral where Output == Void {
    public typealias StringLiteralType = String

    public init(stringLiteral value: String) {
        self = .prefix(value)
    }
}

extension Parser {
    public func skip<B>(_ p: Parser<B>) -> Self {
        zip(self, p).map { a, _ in a }
    }
}

extension Parser {
    public func take<NewOutput>(_ p: Parser<NewOutput>) -> Parser<(Output, NewOutput)> {
        zip(self, p)
    }
}

extension Parser {
    public func take<A, B, C>(_ c: Parser<C>) -> Parser<(A, B, C)> where Output == (A, B) {
        zip(self, c).map { ab, c in (ab.0, ab.1, c) }
    }

    public func take<A, B, C, D>(_ p: Parser<D>) -> Parser<(A, B, C, D)> where Output == (A, B, C) {
        zip(self, p).map { abc, d in (abc.0, abc.1, abc.2, d) }
    }

    public func take<A, B, C, D, E>(_ p: Parser<E>) -> Parser<(A, B, C, D, E)> where Output == (A, B, C, D) {
        zip(self, p).map { abcd, e in (abcd.0, abcd.1, abcd.2, abcd.3, e) }
    }

    public func take<A, B, C, D, E, F>(_ p: Parser<F>) -> Parser<(A, B, C, D, E, F)> where Output == (A, B, C, D, E) {
        zip(self, p).map { abcde, f in (abcde.0, abcde.1, abcde.2, abcde.3, abcde.4, f) }
    }

    public func take<A, B, C, D>(_ p: Parser<(C, D)>) -> Parser<(A, B, C, D)> where Output == (A, B) {
        zip(self, p).map { ab, cd in (ab.0, ab.1, cd.0, cd.1) }
    }
}

extension Parser {
    public static func skip(_ p: Self) -> Parser<Void> {
        p.map { _ in () }
    }

    public static func take(_ p: Self) -> Self {
        p
    }
}

extension Parser where Output == Void {
    public func take<A>(_ p: Parser<A>) -> Parser<A> {
        zip(self, p).map { _, a in a }
    }
}
