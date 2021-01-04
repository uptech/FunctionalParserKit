import XCTest
import FunctionalParserKit

final class PrefixWhileParserTests: XCTestCase {
    func testNormalCase() {
        let res = Parser.prefix(while: { $0 != "," }).run("Hello, Bob")
        XCTAssertEqual(res.match!, "Hello")
        XCTAssertEqual(res.rest, ", Bob")
    }

    static var allTests = [
        ("testNormalCase", testNormalCase),
    ]
}
