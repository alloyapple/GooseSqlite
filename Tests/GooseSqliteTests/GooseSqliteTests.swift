import XCTest
@testable import GooseSqlite

final class GooseSqliteTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        let database = Database(path: "./sql/password.db")

        struct TestData: Codable {
            var password: String
            var _ID: Int32
        }

        if database.open() {
            let rs = database.executeQuery(sql: "SELECT * FROM password", args: [])
            let data: TestData?  = rs.result()

            if let data = data {
                print("data base open data \(data)")
            }


        }


    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
