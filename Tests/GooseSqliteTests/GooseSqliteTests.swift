import XCTest
@testable import GooseSqlite
import Glibc


final class GooseSqliteTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        var tv = timeval()
        gettimeofday(&tv, nil)

        let s = (tv.tv_sec) * 1000 + (tv.tv_usec) / 1000


        let database = Database(path: "./test.db")
        database.open()
        database.executeUpdate(sql: "create table test(id integer primary key, name text)", args: [])

        database.beginTransaction()
        for _ in 0...10000000 {
            database.executeUpdate(sql: "insert into test(name) values (?)", args: ["foo"])
        }
        database.commit()

        tv = timeval()
        gettimeofday(&tv, nil)

        let e = (tv.tv_sec) * 1000 + (tv.tv_usec) / 1000
        print("time \(Double(e - s) / 1000)")


    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
