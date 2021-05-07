import XCTest
import FunctionalParserKit

final class IntParserTests: XCTestCase {
    func testNormalCase() {
        let parser: Parser<Substring, Int> = .int()
        let res = parser.run("123 Hello")
        XCTAssertEqual(res.match, 123)
        XCTAssertEqual(res.rest, " Hello")
    }

    func testExplicitPositiveCase() {
        let parser: Parser<Substring, Int> = .int()
        let res = parser.run("+123 Hello")
        XCTAssertEqual(res.match, 123)
        XCTAssertEqual(res.rest, " Hello")
    }

    func testNegativeCase() {
        let parser: Parser<Substring, Int> = .int()
        let res = parser.run("-123 Hello")
        XCTAssertEqual(res.match, -123)
        XCTAssertEqual(res.rest, " Hello")
    }

    func testNoLeaderNumber() {
        let parser: Parser<Substring, Int> = .int()
        let res = parser.run("Hello Bob")
        XCTAssertEqual(res.match, nil)
        XCTAssertEqual(res.rest, "Hello Bob")
    }

    func testLeadNegativeButNoNumeric() {
        let parser: Parser<Substring, Int> = .int()
        let res = parser.run("-Hello")
        XCTAssertEqual(res.match, nil)
        XCTAssertEqual(res.rest, "-Hello")
    }

    static var allTests = [
        ("testNormalCase", testNormalCase),
        ("testExplicitPositiveCase", testExplicitPositiveCase),
        ("testNegativeCase", testNegativeCase),
        ("testNoLeaderNumber", testNoLeaderNumber),
        ("testLeadNegativeButNoNumeric", testLeadNegativeButNoNumeric)
    ]
}
