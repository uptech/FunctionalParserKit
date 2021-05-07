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

    func testFoo() {
        enum SubCommand: Equatable {
            enum PubOption: Equatable {
                case force
                case keep
                case branch(String)
            }
            case ls
            case show(patchIndex: Int)
            case pull
            case rebase
            case requestReviewOfPatch(patchIndex: Int)
            case requestReviewOfPatchWithBranchName(patchIndex: Int, branchName: String)
            case requestReviewOfPatchSeries(startPatchIndex: Int, endPatchIndex: Int, branchName: String)
            case publish(patchIndex: Int, options: [PubOption])
        }

        // ls - parsers
        let lsSubCommand: Parser<ArraySlice<Substring>, SubCommand> = .first(.prefix("ls")).map { _ in SubCommand.ls }

        let lsArgs: ArraySlice<Substring> = ["ls"]
        let lsRes = lsSubCommand.run(lsArgs)
        XCTAssertEqual(lsRes.match!, SubCommand.ls)
        XCTAssertEqual(lsRes.rest, [])

        // show - parsers
        let showSubCommand: Parser<ArraySlice<Substring>, SubCommand> = zip(
            .first(.prefix("show")),
            .first(.int())
        ).map { _, patchIndex in SubCommand.show(patchIndex: patchIndex) }

        let showArgs: ArraySlice<Substring> = ["show", "33"]
        let showRes = showSubCommand.run(showArgs)
        XCTAssertEqual(showRes.match, SubCommand.show(patchIndex: 33))
        XCTAssertEqual(showRes.rest, [])

        // pull - parsers
        let pullSubCommand: Parser<ArraySlice<Substring>, SubCommand> = .first(.prefix("pull")).map { _ in SubCommand.pull }

        let pullArgs: ArraySlice<Substring> = ["pull"]
        let pullRes = pullSubCommand.run(pullArgs)
        XCTAssertEqual(pullRes.match!, SubCommand.pull)
        XCTAssertEqual(pullRes.rest, [])

        // rebase - parsers
        let rebaseSubCommand: Parser<ArraySlice<Substring>, SubCommand> = .first(.prefix("rebase")).map { _ in SubCommand.rebase }

        let rebaseArgs: ArraySlice<Substring> = ["rebase"]
        let rebaseRes = rebaseSubCommand.run(rebaseArgs)
        XCTAssertEqual(rebaseRes.match!, SubCommand.rebase)
        XCTAssertEqual(rebaseRes.rest, [])

        // rr with branch name - parser
        let rrWithBranchSubCommanad: Parser<ArraySlice<Substring>, SubCommand> = zip(
            .first(.prefix("rr")),
            .first(.int()),
            .first(.prefix("-n")),
            .first(.everything())
        ).map { _, patchIndex, _, branchName in SubCommand.requestReviewOfPatchWithBranchName(patchIndex: patchIndex, branchName: String(branchName)) }

        let rrWithBranchNameArgs: ArraySlice<Substring> = ["rr", "3", "-n", "fooBranch"]
        let rrWithBranchNameRes = rrWithBranchSubCommanad.run(rrWithBranchNameArgs)
        XCTAssertEqual(rrWithBranchNameRes.match!, SubCommand.requestReviewOfPatchWithBranchName(patchIndex: 3, branchName: "fooBranch"))
        XCTAssertEqual(rrWithBranchNameRes.rest, [])

        // rr - parser
        let rrSubCommand: Parser<ArraySlice<Substring>, SubCommand> = zip(
            .first(.prefix("rr")),
            .first(.int())
        ).map { _, patchIndex in SubCommand.requestReviewOfPatch(patchIndex: patchIndex) }

        let rrArgs: ArraySlice<Substring> = ["rr", "3"]
        let rrRes = rrSubCommand.run(rrArgs)
        XCTAssertEqual(rrRes.match!, SubCommand.requestReviewOfPatch(patchIndex: 3))
        XCTAssertEqual(rrRes.rest, [])

        // rr patch series - parser
        let rrPatchSeriesArgs: ArraySlice<Substring> = ["rr", "3-5", "-n", "fooBranch"]
        let rrPatchSeriesSubCommand: Parser<ArraySlice<Substring>, SubCommand> = zip(
            .first(.prefix("rr")),
            .first(zip(.int(), .prefix("-"), .int()).map { si, _, ei in (si, ei) }),
            .first(.prefix("-n")),
            .first(.everything())
        ).map { _, indexes, _, branchName in
            SubCommand.requestReviewOfPatchSeries(startPatchIndex: indexes.0, endPatchIndex: indexes.1, branchName: String(branchName))
        }

        let rrPatchseriesRes = rrPatchSeriesSubCommand.run(rrPatchSeriesArgs)
        XCTAssertEqual(rrPatchseriesRes.match!, SubCommand.requestReviewOfPatchSeries(startPatchIndex: 3, endPatchIndex: 5, branchName: "fooBranch"))
        XCTAssertEqual(rrPatchseriesRes.rest, [])

        // pub - parser
        let pubForceOption: Parser<ArraySlice<Substring>, SubCommand.PubOption> = .first(.prefix("-f")).map { _ in SubCommand.PubOption.force }
        let pubKeepOption: Parser<ArraySlice<Substring>, SubCommand.PubOption> = .first(.prefix("-k")).map { _ in SubCommand.PubOption.keep }
        let pubBranchOption: Parser<ArraySlice<Substring>, SubCommand.PubOption> = zip(.first(.prefix("-n")), .first(.everything())).map { _, branchName in SubCommand.PubOption.branch(String(branchName)) }
        let pubOptions: Parser<ArraySlice<Substring>, [SubCommand.PubOption]> = .oneOf(pubBranchOption, pubForceOption, pubKeepOption).zeroOrMore()

        let pubSubCommand: Parser<ArraySlice<Substring>, SubCommand> = zip(
            .first(.prefix("pub")),
            pubOptions,
            .first(.int()),
            pubOptions
        ).map { _, ops1, idx, ops2 in SubCommand.publish(patchIndex: idx, options: ops1 + ops2) }

        let pubForceVarientOneArgs: ArraySlice<Substring> = ["pub", "-f", "4"]
        let pubForceVarientOneRes = pubSubCommand.run(pubForceVarientOneArgs)
        XCTAssertEqual(pubForceVarientOneRes.match!, SubCommand.publish(patchIndex: 4, options: [.force]))

        let pubForceVarientTwoArgs: ArraySlice<Substring> = ["pub", "4", "-f"]
        let pubForceVarientTwoRes = pubSubCommand.run(pubForceVarientTwoArgs)
        XCTAssertEqual(pubForceVarientTwoRes.match!, SubCommand.publish(patchIndex: 4, options: [.force]))

        let pubKeepVarientOneArgs: ArraySlice<Substring> = ["pub", "-k", "4"]
        let pubKeepVarientOneRes = pubSubCommand.run(pubKeepVarientOneArgs)
        XCTAssertEqual(pubKeepVarientOneRes.match!, SubCommand.publish(patchIndex: 4, options: [.keep]))

        let pubKeepVarientTwoArgs: ArraySlice<Substring> = ["pub", "4", "-k"]
        let pubKeepVarientTwoRes = pubSubCommand.run(pubKeepVarientTwoArgs)
        XCTAssertEqual(pubKeepVarientTwoRes.match!, SubCommand.publish(patchIndex: 4, options: [.keep]))

        let pubBranchVarientOneArgs: ArraySlice<Substring> = ["pub", "-n", "fooBranch", "4"]
        let pubBranchVarientOneRes = pubSubCommand.run(pubBranchVarientOneArgs)
        XCTAssertEqual(pubBranchVarientOneRes.match!, SubCommand.publish(patchIndex: 4, options: [.branch("fooBranch")]))

        let pubBranchVarientTwoArgs: ArraySlice<Substring> = ["pub", "4", "-n", "fooBranch"]
        let pubBranchVarientTwoRes = pubSubCommand.run(pubBranchVarientTwoArgs)
        XCTAssertEqual(pubBranchVarientTwoRes.match!, SubCommand.publish(patchIndex: 4, options: [.branch("fooBranch")]))

        let pubForceWithBranchVarientOneArgs: ArraySlice<Substring> = ["pub", "-f", "-n", "fooBranch", "4"]
        let pubForceWithBranchVarientOneRes = pubSubCommand.run(pubForceWithBranchVarientOneArgs)
        switch pubForceWithBranchVarientOneRes.match! {
        case .publish(patchIndex: let index, options: let ops):
            XCTAssertEqual(index, 4)
            XCTAssertTrue(ops.contains(.branch("fooBranch")))
            XCTAssertTrue(ops.contains(.force))
        default:
            XCTFail()
        }
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
