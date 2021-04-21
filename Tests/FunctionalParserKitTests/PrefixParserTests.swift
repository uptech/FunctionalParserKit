import XCTest
import FunctionalParserKit

final class PrefixParserTests: XCTestCase {
    func testPrefixOnSubstring() {
        let res = Parser<Substring, Void>.prefix("Hello").run("Hello Bob")
        res.match! as Void
        XCTAssertEqual(res.rest, " Bob")
    }

    func testPrefixUpToOnSubstring() {
        let res = Parser<Substring, Substring>.prefix(upTo: "lo"[...]).run("Hello Bob"[...])
        XCTAssertEqual(res.match!, "Hel")
        XCTAssertEqual(res.rest, "lo Bob")
    }

    func testPrefixThroughOnSubstring() {
        let res = Parser<Substring, Substring>.prefix(through: "lo"[...]).run("Hello Bob"[...])
        XCTAssertEqual(res.match!, "Hello")
        XCTAssertEqual(res.rest, " Bob")
    }

    func testEverytingOnSubstring() {
        let res = Parser<Substring, Substring>.everything().run("Hello Bob"[...])
        XCTAssertEqual(res.match!, "Hello Bob")
        XCTAssertEqual(res.rest, "")
    }

    func testPrefixOnArraySlice() {
        let collection: ArraySlice<String> = ["Hello", "World", "Bobby", "York"][...]
        let helloWorldParser = Parser<ArraySlice<String>, Void>.prefix(["Hello", "World"][...])
        let res = helloWorldParser.run(collection)
        res.match!
        XCTAssertEqual(res.rest, ["Bobby", "York"])
    }

    func testPrefixUpToOnArraySlice() {
        let collection: Array<String> = ["Hello", "World", "Bobby", "York"]
        let upToBobbyParser = Parser<ArraySlice<String>, ArraySlice<String>>.prefix(upTo: ["Bobby"][...])
        let res = upToBobbyParser.run(collection[...])
        XCTAssertEqual(res.match!, ["Hello", "World"])
        XCTAssertEqual(res.rest, ["Bobby", "York"])
    }

    func testPrefixThroughOnArraySlice() {
        let collection: Array<String> = ["Hello", "World", "Bobby", "York"]
        let upToBobbyParser = Parser<ArraySlice<String>, ArraySlice<String>>.prefix(through: ["Bobby"][...])
        let res = upToBobbyParser.run(collection[...])
        XCTAssertEqual(res.match!, ["Hello", "World", "Bobby"])
        XCTAssertEqual(res.rest, ["York"])
    }

    func testEverytingOnArraySlice() {
        let res = Parser<ArraySlice<String>, ArraySlice<String>>.everything().run(["Hello", "World", "Jack"][...])
        XCTAssertEqual(res.match!, ["Hello", "World", "Jack"])
        XCTAssertEqual(res.rest, [])
    }
    

    static var allTests = [
        ("testPrefixOnSubstring", testPrefixOnSubstring),
        ("testPrefixUpToOnSubstring", testPrefixUpToOnSubstring),
        ("testPrefixThroughOnSubstring", testPrefixThroughOnSubstring),
        ("testEverytingOnSubstring", testEverytingOnSubstring),
        ("testPrefixOnArraySlice", testPrefixOnArraySlice),
        ("testPrefixUpToOnArraySlice", testPrefixUpToOnArraySlice),
        ("testPrefixThroughOnArraySlice", testPrefixThroughOnArraySlice),
        ("testEverytingOnArraySlice", testEverytingOnArraySlice)
    ]
}
