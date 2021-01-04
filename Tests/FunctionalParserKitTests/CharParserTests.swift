import XCTest
import FunctionalParserKit

final class CharParserTests: XCTestCase {
    func testNormalCase() {
        let res = Parser.char.run("Hello Bob")
        XCTAssertEqual(res.match, "H")
        XCTAssertEqual(res.rest, "ello Bob")
    }

    func testEmptyString() {
        let res = Parser.char.run("")
        XCTAssertEqual(res.match, nil)
        XCTAssertEqual(res.rest, "")
    }


    static var allTests = [
        ("testNormalCase", testNormalCase),
        ("testEmptyString", testEmptyString)
    ]
}
