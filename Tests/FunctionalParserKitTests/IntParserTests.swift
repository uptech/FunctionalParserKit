import XCTest
import FunctionalParserKit

final class IntParserTests: XCTestCase {
    func testNormalCase() {
        let res = Parser.int.run("123 Hello")
        XCTAssertEqual(res.match, 123)
        XCTAssertEqual(res.rest, " Hello")
    }

    func testExplicitPositiveCase() {
        let res = Parser.int.run("+123 Hello")
        XCTAssertEqual(res.match, 123)
        XCTAssertEqual(res.rest, " Hello")
    }

    func testNegativeCase() {
        let res = Parser.int.run("-123 Hello")
        XCTAssertEqual(res.match, -123)
        XCTAssertEqual(res.rest, " Hello")
    }

    func testNoLeaderNumber() {
        let res = Parser.int.run("Hello Bob")
        XCTAssertEqual(res.match, nil)
        XCTAssertEqual(res.rest, "Hello Bob")
    }

    func testLeadNegativeButNoNumeric() {
        let res = Parser.int.run("-Hello")
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
