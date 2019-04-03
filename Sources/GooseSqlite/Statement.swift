//
// Created by color on 1/2/19.
//

import Foundation
import CSqlite3

public class Statement: Hashable {
    public static func == (lhs: Statement, rhs: Statement) -> Bool {
        return lhs.statement == rhs.statement
    }

    public var hashValue: Int {
        return self.statement?.hashValue ?? 0
    }

    var statement: OpaquePointer?
    var inUse: Bool = false

    public func step() -> Int32 {
        return sqlite3_step(self.statement)
    }

    public func reset() {
        sqlite3_reset(statement)
    }

    deinit {
        sqlite3_finalize(statement)
    }
}