import XCTest
import FunctionalParserKit

final class DoubleParserTests: XCTestCase {
    func testNormalCase() {
        let parser: Parser<Substring, Double> = .double()
        let res = parser.run("42 Hello")
        XCTAssertEqual(res.match, Double(42))
        XCTAssertEqual(res.rest, " Hello")
    }

    func testMiddlePoint() {
        let parser: Parser<Substring, Double> = .double()
        let res = parser.run("4.2 Hello")
        XCTAssertEqual(res.match, 4.2)
        XCTAssertEqual(res.rest, " Hello")
    }

    func testTrailingPoint() {
        let parser: Parser<Substring, Double> = .double()
        let res = parser.run("42. Hello")
        XCTAssertEqual(res.match, 42.0)
        XCTAssertEqual(res.rest, " Hello")
    }

    func testLeadingPoint() {
        let parser: Parser<Substring, Double> = .double()
        let res = parser.run(".42 Hello")
        XCTAssertEqual(res.match, 0.42)
        XCTAssertEqual(res.rest, " Hello")
    }

    func testLeadNegative() {
        let parser: Parser<Substring, Double> = .double()
        let res = parser.run("-42 Hello")
        XCTAssertEqual(res.match, -42.0)
        XCTAssertEqual(res.rest, " Hello")
    }

    func testLeadingExplicitPositive() {
        let parser: Parser<Substring, Double> = .double()
        let res = parser.run("+42 Hello")
        XCTAssertEqual(res.match, 42.0)
        XCTAssertEqual(res.rest, " Hello")
    }

    func testLeadNegativeButNoNumeric() {
        let parser: Parser<Substring, Double> = .double()
        let res = parser.run("-Hello")
        XCTAssertEqual(res.match, nil)
        XCTAssertEqual(res.rest, "-Hello")
    }

    func testMultipleDecimals() {
        let parser: Parser<Substring, Double> = .double()
        let res = parser.run("1.2.3 Hello")
        XCTAssertEqual(res.match, 1.2)
        XCTAssertEqual(res.rest, ".3 Hello")
    }

    static var allTests = [
        ("testNormalCase", testNormalCase),
        ("testMiddlePoint", testMiddlePoint),
        ("testTrailingPoint", testTrailingPoint),
        ("testLeadingPoint", testLeadingPoint),
        ("testLeadNegative", testLeadNegative),
        ("testLeadingExplicitPositive", testLeadingExplicitPositive),
        ("testLeadNegativeButNoNumeric", testLeadNegativeButNoNumeric),
        ("testMultipleDecimals", testMultipleDecimals)
    ]
}
