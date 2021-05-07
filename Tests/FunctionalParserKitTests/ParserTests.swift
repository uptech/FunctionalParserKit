import XCTest
import FunctionalParserKit

final class ParserTests: XCTestCase {
    func testMap() {
        let parser: Parser<Substring, Int> = .int()
        let even = parser.map { $0.isMultiple(of: 2) }

        let res = even.run("123 Hello")
        XCTAssertEqual(res.match, false)
        XCTAssertEqual(res.rest, " Hello")

        let res1 = even.run("124 Hello")
        XCTAssertEqual(res1.match, true)
        XCTAssertEqual(res1.rest, " Hello")
    }

    func testFlatMap() {
        let parser: Parser<Substring, Int> = .int()
        let evenInt = parser.flatMap { n in
            n.isMultiple(of: 2)
                ? .always(n)
                : .never()
        }

        let res = evenInt.run("123 Hello")
        XCTAssertEqual(res.match, nil)
        XCTAssertEqual(res.rest, "123 Hello")

        let res1 = evenInt.run("124 Hello")
        XCTAssertEqual(res1.match, 124)
        XCTAssertEqual(res1.rest, " Hello")
    }

    func testZipTwo() {
        // Parse "100°F"
        let temparature = zip(.int(), .prefix("°F"))
            .map { temperature, _ in temperature }

        let res = temparature.run("100°F")
        XCTAssertEqual(res.match, 100)
        XCTAssertEqual(res.rest, "")

        let res1 = temparature.run("-100°F")
        XCTAssertEqual(res1.match, -100)
        XCTAssertEqual(res1.rest, "")
    }

    func testZipThree() {
        let northSouth: Parser<Substring, Double> = .char().flatMap {
            $0 == "N" ? .always(1.0)
                : $0 == "S" ? .always(-1)
                : .never()
        }

        let eastWest: Parser<Substring, Double> = .char().flatMap {
            $0 == "E" ? .always(1.0)
                : $0 == "W" ? .always(-1)
                : .never()
        }

        let latitude = zip(.double(), .prefix("° "), northSouth)
            .map { latitude, _, latSign in
                latitude * latSign
            }

        let latRes = latitude.run("40.446° N")
        XCTAssertEqual(latRes.match, 40.446)
        XCTAssertEqual(latRes.rest, "")

        let longitude = zip(.double(), .prefix("° "), eastWest)
            .map { longitude, _, longSign in
                longitude * longSign
            }

        let longRes = longitude.run("40.446° W")
        XCTAssertEqual(longRes.match, -40.446)
        XCTAssertEqual(longRes.rest, "")

        // "40.446° N, 70.982° W"

        struct Coordinate {
            let latitude: Double
            let longitude: Double
        }

        let coord = zip(latitude, .prefix(", "), longitude).map { lat, _, long in
            Coordinate(latitude: lat, longitude: long)
        }

        let coordRes = coord.run("40.446° N, 70.982° W")
        XCTAssertEqual(coordRes.match!.latitude, 40.446)
        XCTAssertEqual(coordRes.match!.longitude, -70.982)
        XCTAssertEqual(coordRes.rest, "")
    }

    func testOneOf() {
        enum Currency { case eur, gbp, usd }

        let currency: Parser<Substring, Currency> = .oneOf(
            .prefix("€").map { _ in Currency.eur },
            .prefix("£").map { _ in Currency.gbp },
            .prefix("$").map { _ in Currency.usd }
        )

        struct Money {
            let currency: Currency
            let value: Double
        }

        let money = zip(currency, .double()).map(Money.init(currency:value:))

        // "$100"

        let resOne = money.run("$100")
        XCTAssertEqual(resOne.match!.currency, .usd)
        XCTAssertEqual(resOne.match!.value, 100)
        XCTAssertEqual(resOne.rest, "")

        let resTwo = money.run("£100")
        XCTAssertEqual(resTwo.match!.currency, .gbp)
        XCTAssertEqual(resTwo.match!.value, 100)
        XCTAssertEqual(resTwo.rest, "")

        let resThree = money.run("€100")
        XCTAssertEqual(resThree.match!.currency, .eur)
        XCTAssertEqual(resThree.match!.value, 100)
        XCTAssertEqual(resThree.rest, "")
    }

    func testFirst() {
        let args: ArraySlice<Substring> = ["show", "23"]

        let showSubCommand: Parser<ArraySlice<Substring>, Void> = .first(.prefix("show"))
        let res = showSubCommand.run(args)
        res.match!
        XCTAssertEqual(res.rest, ["23"])
    }

    func testFirstNotConsumeAllOfChild() {
        let args: ArraySlice<Substring> = ["show", "23"]

        let showSubCommand: Parser<ArraySlice<Substring>, Void> = .first(.prefix("sh"))
        let res = showSubCommand.run(args)
        XCTAssertNil(res.match)
        XCTAssertEqual(res.rest, ["show", "23"])
    }

    func testFirstNotMatch() {
        let args: ArraySlice<Substring> = ["show", "23"]

        let showSubCommand: Parser<ArraySlice<Substring>, Int> = .first(.int())
        let res = showSubCommand.run(args)
        XCTAssertNil(res.match)
        XCTAssertEqual(res.rest, ["show", "23"])
    }

    static var allTests = [
        ("testMap", testMap),
        ("testFlatMap", testFlatMap),
        ("testZipTwo", testZipTwo),
        ("testZipThree", testZipThree),
        ("testOneOf", testOneOf),
        ("testFirst", testFirst),
        ("testFirstNotConsumeAllOfChild", testFirstNotConsumeAllOfChild),
        ("testFirstNotMatch", testFirstNotMatch)
    ]
}
