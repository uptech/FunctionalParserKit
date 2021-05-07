import Functional

public typealias DrewParser<Input, Output> = (Input) -> (match: Output?, rest: Input)

public func map<I,A,B>(_ p: @escaping DrewParser<I,A>, _ f: @escaping (A) -> B) -> DrewParser<I, B> {
    return { input in
        let res = p(input)
        guard let a = res.match else { return (nil, res.rest) }
        return (f(a), res.rest)
    }
}

public func flatMap<I,A,B>(_ p: @escaping DrewParser<I,A>, _ f: @escaping (A) -> DrewParser<I,B>) -> DrewParser<I,B> {
    return { input in
        let resA = p(input)
        guard let a = resA.match else { return (nil, resA.rest) }
        let newParser = f(a)
        return newParser(resA.rest)
    }
}

public let intParser: DrewParser<Substring, Int> = { input in
    let original = input
    var i = input

    let sign: Int // +1, -1
    if input.first == "-" {
        sign = -1
        i.removeFirst()
    } else if input.first == "+" {
        sign = 1
        i.removeFirst()
    } else {
        sign = 1
    }

    let intPrefix = i.prefix(while: \.isNumber)
    guard let match = Int(intPrefix)
    else {
        i = original
        return (nil, input)
    }
    i.removeFirst(intPrefix.count)
    return (match * sign, i)
}


// Take the parsed output from p1 and pipe it as input into p2 via compose
// p1 >>> p2
// first >>> prefix("-f")
public func >>> <I,A,B>(
    _ f: @escaping DrewParser<I,A>,
    _ g: @escaping DrewParser<I,B>
) -> DrewParser<I,(A, B)> {
    return { inputF in
        let resF = f(inputF)
        guard let a = resF.match else { return (nil, resF.rest) }
        let resG = g(resF.rest)
        guard let b = resG.match else { return (nil, resF.rest) }
        return ((a, b), rest: resG.rest)
    }
}

public func >>> <I,A,B,C>(
    _ f: @escaping DrewParser<I,(A,B)>,
    _ g: @escaping DrewParser<I,C>
) -> DrewParser<I,(A,B,C)> {
    return { inputF in
        let resF = f(inputF)
        guard let ab = resF.match else { return (nil, resF.rest) }
        let resG = g(resF.rest)
        guard let c = resG.match else { return (nil, resG.rest) }
        return ((ab.0, ab.1, c), rest: resG.rest)
    }
}

public func >>> <I,A,B,C,D>(
    _ f: @escaping DrewParser<I,(A,B,C)>,
    _ g: @escaping DrewParser<I,D>
) -> DrewParser<I,(A,B,C,D)> {
    return { inputF in
        let resF = f(inputF)
        guard let abc = resF.match else { return (nil, resF.rest) }
        let resG = g(resF.rest)
        guard let d = resG.match else { return (nil, resG.rest) }
        return ((abc.0, abc.1, abc.2, d), rest: resG.rest)
    }
}

public func >>> <I,A,B,C,D,E>(
    _ f: @escaping DrewParser<I,(A,B,C,D)>,
    _ g: @escaping DrewParser<I,E>
) -> DrewParser<I,(A,B,C,D,E)> {
    return { inputF in
        let resF = f(inputF)
        guard let abcd = resF.match else { return (nil, resF.rest) }
        let resG = g(resF.rest)
        guard let e = resG.match else { return (nil, resG.rest) }
        return ((abcd.0, abcd.1, abcd.2, abcd.3, e), rest: resG.rest)
    }
}

public func >>> <I,A,B,C,D,E,F>(
    _ f: @escaping DrewParser<I,(A,B,C,D,E)>,
    _ g: @escaping DrewParser<I,F>
) -> DrewParser<I,(A,B,C,D,E,F)> {
    return { inputF in
        let resF = f(inputF)
        guard let abcde = resF.match else { return (nil, resF.rest) }
        let resG = g(resF.rest)
        guard let f = resG.match else { return (nil, resG.rest) }
        return ((abcde.0, abcde.1, abcde.2, abcde.3, abcde.4, f), rest: resG.rest)
    }
}

let foo: DrewParser<Substring, (Int, Int, Int)> = intParser >>> intParser >>> intParser



//public func zip<I,A,B>(
//    _ a: @escaping DrewParser<I,A>,
//    _ b: @escaping DrewParser<I,B>
//) -> DrewParser<I,(A,B)> {
//    return { input in
//        let aRes = a(input)
//        guard let aMatch = aRes.match else { return (nil, aRes.rest) }
//        let bRes = b(aRes.rest)
//        guard let bMatch = bRes.match else { return (nil, aRes.rest) }
//        return ((aMatch, bMatch), bRes.rest)
//    }
//}

//public func zip<I,A,B,C>(
//    _ a: @escaping DrewParser<I,A>,
//    _ b: @escaping DrewParser<I,B>,
//    _ c: @escaping DrewParser<I,C>
//) -> DrewParser<I,(A,B,C)> {
//    return map(zip(a, zip(b, c))) { a, bc in (a, bc.0, bc.1) }
//}
//
//public func zip<I, A, B, C, D>(
//    _ a: @escaping DrewParser<I, A>,
//    _ b: @escaping DrewParser<I, B>,
//    _ c: @escaping DrewParser<I, C>,
//    _ d: @escaping DrewParser<I, D>
//) -> DrewParser<I,(A,B,C,D)> {
//    return map(zip(a, zip(b, c, d))) { a , bcd in (a, bcd.0, bcd.1, bcd.2) }
//}
//
//public func zip<I,A,B,C,D,E>(
//    _ a: @escaping DrewParser<I, A>,
//    _ b: @escaping DrewParser<I, B>,
//    _ c: @escaping DrewParser<I, C>,
//    _ d: @escaping DrewParser<I, D>,
//    _ e: @escaping DrewParser<I, E>
//) -> DrewParser<I,(A,B,C,D,E)> {
//    return map(zip(a, zip(b, c, d, e))) { a , bcde in (a, bcde.0, bcde.1, bcde.2, bcde.3) }
//}
//
//public func zip<I,A,B,C,D,E,F>(
//    _ a: @escaping DrewParser<I, A>,
//    _ b: @escaping DrewParser<I, B>,
//    _ c: @escaping DrewParser<I, C>,
//    _ d: @escaping DrewParser<I, D>,
//    _ e: @escaping DrewParser<I, E>,
//    _ f: @escaping DrewParser<I, F>
//) -> DrewParser<I,(A,B,C,D,E,F)> {
//    return map(zip(a, zip(b, c, d, e, f))) { a , bcdef in (a, bcdef.0, bcdef.1, bcdef.2, bcdef.3, bcdef.4) }
//}


//let pubForceOption: Parser<ArraySlice<Substring>, SubCommand.PubOption> = .first(.prefix("-f")).map { _ in SubCommand.PubOption.force }
//let pubKeepOption: Parser<ArraySlice<Substring>, SubCommand.PubOption> = .first(.prefix("-k")).map { _ in SubCommand.PubOption.keep }
//let pubBranchOption: Parser<ArraySlice<Substring>, SubCommand.PubOption> = zip(.first(.prefix("-n")), .first(.everything())).map { _, branchName in SubCommand.PubOption.branch(String(branchName)) }
//let pubOptions: Parser<ArraySlice<Substring>, [SubCommand.PubOption]> = .oneOf(pubBranchOption, pubForceOption, pubKeepOption).zeroOrMore()
//
//let pubSubCommand: Parser<ArraySlice<Substring>, SubCommand> = zip(
//    .first(.prefix("pub")),
//    pubOptions,
//    .first(.int()),
//    pubOptions
//).map { _, ops1, idx, ops2 in SubCommand.publish(patchIndex: idx, options: ops1 + ops2) }
//


//extension Parser {
//    public func flatMap<NewOutput>(_ f: @escaping (Output) -> Parser<Input, NewOutput>) -> Parser<Input, NewOutput> {
//        .init { input in
//            let original = input
//            let output = self.run(&input)
//            let newParser = output.map(f)
//            guard let newOutput = newParser?.run(&input) else {
//                input = original
//                return nil
//            }
//            return newOutput
//        }
//    }
//}

