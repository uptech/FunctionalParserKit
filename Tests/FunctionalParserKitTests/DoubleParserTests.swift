import XCTest
import FunctionalParserKit

final class DoubleParserTests: XCTestCase {
    func testNormalCase() {
        let res = Parser.double.run("42 Hello")
        XCTAssertEqual(res.match, Double(42))
        XCTAssertEqual(res.rest, " Hello")
    }

    func testMiddlePoint() {
        let res = Parser.double.run("4.2 Hello")
        XCTAssertEqual(res.match, 4.2)
        XCTAssertEqual(res.rest, " Hello")
    }

    func testTrailingPoint() {
        let res = Parser.double.run("42. Hello")
        XCTAssertEqual(res.match, 42.0)
        XCTAssertEqual(res.rest, " Hello")
    }

    func testLeadingPoint() {
        let res = Parser.double.run(".42 Hello")
        XCTAssertEqual(res.match, 0.42)
        XCTAssertEqual(res.rest, " Hello")
    }

    func testLeadNegative() {
        let res = Parser.double.run("-42 Hello")
        XCTAssertEqual(res.match, -42.0)
        XCTAssertEqual(res.rest, " Hello")
    }

    func testLeadingExplicitPositive() {
        let res = Parser.double.run("+42 Hello")
        XCTAssertEqual(res.match, 42.0)
        XCTAssertEqual(res.rest, " Hello")
    }

    func testLeadNegativeButNoNumeric() {
        let res = Parser.double.run("-Hello")
        XCTAssertEqual(res.match, nil)
        XCTAssertEqual(res.rest, "-Hello")
    }

    func testMultipleDecimals() {
        let res = Parser.double.run("1.2.3 Hello")
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
