import XCTest
import FunctionalParserKit

final class PrefixParserTests: XCTestCase {
    func testNormalCase() {
        let res = Parser.prefix("Hello").run("Hello Bob")
        res.match! as Void
        XCTAssertEqual(res.rest, " Bob")
    }

//    func testSuffix() {
//        let res = Parser.suffix(from: "Bob").run("Hey there Bob. How are you doing?")
//        XCTAssertEqual(res.match!, "Bob. How are you doing?")
//        XCTAssertEqual(res.rest, "")
//    }

    static var allTests = [
        ("testNormalCase", testNormalCase),
//        ("testSuffix", testSuffix)
    ]
}
