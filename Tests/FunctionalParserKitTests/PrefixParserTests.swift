import XCTest
import FunctionalParserKit

final class PrefixParserTests: XCTestCase {
    func testPrefixOnSubstring() {
        let parser: Parser<Substring, Void> = .prefix("Hello")
        let res = parser.run("Hello Bob")
        res.match! as Void
        XCTAssertEqual(res.rest, " Bob")
    }

    func testPrefixUpToOnSubstring() {
        let res = Parser<Substring, Substring>.prefix(upTo: "lo"[...]).run("Hello Bob"[...])
        XCTAssertEqual(res.match!, "Hel")
        XCTAssertEqual(res.rest, "lo Bob")
    }

    func testPrefixUpToEndOnSubstring() {
        let res = Parser<Substring, Substring>.prefix(upTo: "b"[...]).run("Hello Bob"[...])
        XCTAssertEqual(res.match!, "Hello Bo")
        XCTAssertEqual(res.rest, "b")
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
        let helloWorldParser: Parser<ArraySlice<String>, Void> = .prefix(["Hello", "World"][...])
        let res = helloWorldParser.run(collection)
        res.match!
        XCTAssertEqual(res.rest, ["Bobby", "York"])
    }

    func testPrefixUpToOnArraySlice() {
        let collection: Array<String> = ["Hello", "World", "Bobby", "York"]
        let upToBobbyParser: Parser<ArraySlice<String>, ArraySlice<String>> = .prefix(upTo: ["Bobby"][...])
        let res = upToBobbyParser.run(collection[...])
        XCTAssertEqual(res.match!, ["Hello", "World"])
        XCTAssertEqual(res.rest, ["Bobby", "York"])
    }

    func testPrefixThroughOnArraySlice() {
        let collection: Array<String> = ["Hello", "World", "Bobby", "York"]
        let upToBobbyParser: Parser<ArraySlice<String>, ArraySlice<String>> = .prefix(through: ["Bobby"][...])
        let res = upToBobbyParser.run(collection[...])
        XCTAssertEqual(res.match!, ["Hello", "World", "Bobby"])
        XCTAssertEqual(res.rest, ["York"])
    }

    func testEverytingOnArraySlice() {
        let res = Parser<ArraySlice<String>, ArraySlice<String>>.everything().run(["Hello", "World", "Jack"][...])
        XCTAssertEqual(res.match!, ["Hello", "World", "Jack"])
        XCTAssertEqual(res.rest, [])
    }

    func testCrash() {
        let foo = "diff --git a/README.md b/README.md\nindex ed82b88..777d4d4 100644\n--- a/README.md\n+++ b/README.md\n@@ -1 +1,3 @@\n This is a repo to test Pullwalla with GitHub Cloud integration.\n+\n+add some text from test_branch_001 so that I can test approve/unapprove of a PR."

        let restOfLine: Parser<Substring, Substring> = .prefix(through: "\n").map { $0.dropLast() }

        let gitDiffHeaderParser = zip(.prefix(upTo: "diff --git "),
                                      restOfLine).map { _, a in String.init(a) }
        let gitDiffExtendedHeaderParser: Parser<Substring, String> = .prefix(upTo: "--- ")
            .flatMap { $0.isEmpty ? .always("") : .always($0.dropLast()) }
            .map(String.init)

        let gitDiffParser = zip(gitDiffHeaderParser, gitDiffExtendedHeaderParser)

        var _rawGitDiff = foo[...]
        let res = gitDiffParser.run(&_rawGitDiff)
        XCTAssertEqual(res!.0, "diff --git a/README.md b/README.md")
        XCTAssertEqual(res!.1, "index ed82b88..777d4d4 100644")
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
