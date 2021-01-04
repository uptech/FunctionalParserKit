import XCTest
import FunctionalParserKit

final class PrefixLiteralParserTests: XCTestCase {
    func testNormalCase() {
        let res = zip(Parser.int, " Hello Bob ", .int).run("123 Hello Bob 321")
        XCTAssertEqual(res.match!.0, 123)
        XCTAssertEqual(res.match!.2, 321)
        XCTAssertEqual(res.rest, "")
    }

    static var allTests = [
        ("testNormalCase", testNormalCase),
    ]
}
