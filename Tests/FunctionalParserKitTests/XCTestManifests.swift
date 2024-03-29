#if !canImport(ObjectiveC)
import XCTest

extension CharParserTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__CharParserTests = [
        ("testEmptyString", testEmptyString),
        ("testNormalCase", testNormalCase),
    ]
}

extension DoubleParserTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__DoubleParserTests = [
        ("testLeadingExplicitPositive", testLeadingExplicitPositive),
        ("testLeadingPoint", testLeadingPoint),
        ("testLeadNegative", testLeadNegative),
        ("testLeadNegativeButNoNumeric", testLeadNegativeButNoNumeric),
        ("testMiddlePoint", testMiddlePoint),
        ("testMultipleDecimals", testMultipleDecimals),
        ("testNormalCase", testNormalCase),
        ("testTrailingPoint", testTrailingPoint),
    ]
}

extension IntParserTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__IntParserTests = [
        ("testExplicitPositiveCase", testExplicitPositiveCase),
        ("testLeadNegativeButNoNumeric", testLeadNegativeButNoNumeric),
        ("testNegativeCase", testNegativeCase),
        ("testNoLeaderNumber", testNoLeaderNumber),
        ("testNormalCase", testNormalCase),
    ]
}

extension ParserTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__ParserTests = [
        ("testFlatMap", testFlatMap),
        ("testMap", testMap),
        ("testOneOf", testOneOf),
        ("testZipThree", testZipThree),
        ("testZipTwo", testZipTwo),
    ]
}

extension PrefixLiteralParserTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__PrefixLiteralParserTests = [
        ("testNormalCase", testNormalCase),
    ]
}

extension PrefixParserTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__PrefixParserTests = [
        ("testNormalCase", testNormalCase),
    ]
}

extension PrefixWhileParserTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__PrefixWhileParserTests = [
        ("testNormalCase", testNormalCase),
    ]
}

extension ZeroOrMoreParserTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__ZeroOrMoreParserTests = [
        ("testNormalCase", testNormalCase),
        ("testNoSeparator", testNoSeparator),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(CharParserTests.__allTests__CharParserTests),
        testCase(DoubleParserTests.__allTests__DoubleParserTests),
        testCase(IntParserTests.__allTests__IntParserTests),
        testCase(ParserTests.__allTests__ParserTests),
        testCase(PrefixLiteralParserTests.__allTests__PrefixLiteralParserTests),
        testCase(PrefixParserTests.__allTests__PrefixParserTests),
        testCase(PrefixWhileParserTests.__allTests__PrefixWhileParserTests),
        testCase(ZeroOrMoreParserTests.__allTests__ZeroOrMoreParserTests),
    ]
}
#endif
