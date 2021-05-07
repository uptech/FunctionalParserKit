import XCTest
import FunctionalParserKit

final class CharParserTests: XCTestCase {
    func testNormalCase() {
        let parser: Parser<Substring, Character> = .char()
        let res = parser.run("Hello Bob")
        XCTAssertEqual(res.match, "H")
        XCTAssertEqual(res.rest, "ello Bob")
    }

    func testEmptyString() {
        let parser: Parser<Substring, Character> = .char()
        let res = parser.run("")
        XCTAssertEqual(res.match, nil)
        XCTAssertEqual(res.rest, "")
    }


    static var allTests = [
        ("testNormalCase", testNormalCase),
        ("testEmptyString", testEmptyString)
    ]
}
