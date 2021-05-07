import XCTest
import FunctionalParserKit

final class ZeroOrMoreParserTests: XCTestCase {
    func testNormalCase() {
        // "1,3,4,23,82,10823"

        let zeroOrMoreInt: Parser<Substring, [Int]> = .int().zeroOrMore(separatedBy: .prefix(","))
        let res = zeroOrMoreInt.run("1,3,4,23,82,10823")
        XCTAssertEqual(res.match!, [1,3,4,23,82,10823])
        XCTAssertEqual(res.rest, "")
    }

    func testNoSeparator() {
        // "1°3°4°23°82°10823"

        let degree: Parser<Substring, Int> = zip(.int(), Parser<Substring, Void>.prefix("°")).map { $0.0 }
        let degrees = degree.zeroOrMore()

        let res = degrees.run("1°3°4°23°82°10823°")
        XCTAssertEqual(res.match!, [1,3,4,23,82,10823])
        XCTAssertEqual(res.rest, "")
    }

    static var allTests = [
        ("testNormalCase", testNormalCase),
        ("testNoSeparator", testNoSeparator)
    ]
}
