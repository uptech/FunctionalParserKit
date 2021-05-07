import XCTest
import FunctionalParserKit

final class PrefixWhileParserTests: XCTestCase {
    func testNormalCase() {
        let parser: Parser<Substring, Substring> = .prefix(while: { $0 != "," })
        let res = parser.run("Hello, Bob")
        XCTAssertEqual(res.match!, "Hello")
        XCTAssertEqual(res.rest, ", Bob")
    }

    func testOnArraySlice() {
        let res = Parser<ArraySlice<String>, ArraySlice<String>>.prefix(while: { $0 != "World" }).run(["Hello", "World", "Bob"][...])
        XCTAssertEqual(res.match!, ["Hello"])
        XCTAssertEqual(res.rest, ["World", "Bob"])
    }

    static var allTests = [
        ("testNormalCase", testNormalCase),
        ("testOnArraySlice", testOnArraySlice)
    ]
}
