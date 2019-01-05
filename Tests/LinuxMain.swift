import XCTest

import GooseSqliteTests

var tests = [XCTestCaseEntry]()
tests += GooseSqliteTests.allTests()
XCTMain(tests)