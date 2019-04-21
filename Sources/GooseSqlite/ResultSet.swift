//
// Created by color on 1/2/19.
//

import Foundation
import CSqlite3

public class ResultSet {
    let statement: Statement
    let database: Database

    public init(statement: Statement, database: Database) {
        self.statement = statement
        self.database = database
    }

    var columnCount: Int32 {
        return sqlite3_column_count(self.statement.statement)
    }

    var resultDictionary: [String: Any?] {

        let num_cols = sqlite3_data_count(statement.statement)

        var ret = [String: Any]()

        if num_cols > 0 {
            let columnCount = self.columnCount
            for i in 0..<columnCount {
                let columnName = String(cString: sqlite3_column_name(statement.statement, i))

                let objectValue = self.objectForColumnIndex(i)
                ret[columnName] = objectValue
            }
        }

        return ret
    }

    public func result<T>() throws -> T  where T: Decodable   {
        let r = self.resultDictionary

        do {
            let data = try JSONSerialization.data(withJSONObject: r)
            let decoder = JSONDecoder()
            let t = try decoder.decode(T.self, from: data)
            return t
        } catch {
            throw SqliteError()
        }

    }

    func objectForColumnIndex(_ columnIdx: Int32) -> Any? {
        let columnType = sqlite3_column_type(statement.statement, columnIdx)


        if columnType == SQLITE_INTEGER {
            return sqlite3_column_int64(statement.statement, columnIdx)
        }

        if columnType == SQLITE_FLOAT {
            return sqlite3_column_double(statement.statement, columnIdx)
        }

        if columnType == SQLITE_BLOB {
            guard let dataBuffer = sqlite3_column_blob(statement.statement, columnIdx) else {
                return nil
            }

            let dataSize = sqlite3_column_bytes(statement.statement, columnIdx)

            return Data(bytes: dataBuffer, count: Int(dataSize))
        }

        if columnType == SQLITE_NULL {
            return nil
        }

        guard let c = sqlite3_column_text(statement.statement, columnIdx) else {
            return nil
        }

        return String(cString: c)
    }

    public func next() -> Bool {
        let r = self.statement.step()
        if r == SQLITE_DONE || r == SQLITE_ROW {
            return true
        }

        return false
    }

    var hasAnotherRow: Bool {
        return sqlite3_errcode(database.db) == SQLITE_ROW
    }


}
