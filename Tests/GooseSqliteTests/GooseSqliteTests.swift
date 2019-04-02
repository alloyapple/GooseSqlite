import XCTest
@testable import GooseSqlite

final class GooseSqliteTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let database = Database(path: ":memory:")
        XCTAssertTrue(database.open())
        XCTAssertTrue(database.executeUpdate(sql: "create table test(id integer primary key, name text)", args: []))
        XCTAssertTrue(database.executeUpdate(sql: "insert into test(name) values (?)", args: ["foo"]))


    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
