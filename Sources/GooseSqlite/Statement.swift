//
// Created by color on 1/2/19.
//

import Foundation
import CSqlite3

public class Statement {
    var statement: OpaquePointer?

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