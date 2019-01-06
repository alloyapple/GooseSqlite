//
// Created by color on 1/1/19.
//

import Foundation
import CSqlite3

extension Data {
    func castToCPointer<T>() -> T {
        return self.withUnsafeBytes {
            $0.pointee
        }
    }
}

public class Database {
    let path: String
    var db: OpaquePointer? = nil

    public init(path: String) {
        self.path = path
    }

    public func open() -> Bool {
        return sqlite3_open(self.path, &db) == SQLITE_OK
    }


    public func bindObject(obj: Any?, idx: Int32, stmt: OpaquePointer?) {
        guard let obj = obj else {
            sqlite3_bind_null(stmt, idx)
            return
        }

        if let data = obj as? Data {
            sqlite3_bind_blob(stmt, idx, data.castToCPointer(), Int32(data.count), nil)
        } else if let date = obj as? Date {
            sqlite3_bind_double(stmt, idx, date.timeIntervalSince1970)
        } else if let i = obj as? Int32 {
            sqlite3_bind_int(stmt, idx, i)
        } else if let i = obj as? Int16 {
            sqlite3_bind_int(stmt, idx, Int32(i))
        } else if let i = obj as? Int64 {
            sqlite3_bind_int64(stmt, idx, i)
        } else if let i = obj as? Int8 {
            sqlite3_bind_int(stmt, idx, Int32(i))
        } else if let i = obj as? UInt32 {
            sqlite3_bind_int(stmt, idx, Int32(i))
        } else if let i = obj as? UInt16 {
            sqlite3_bind_int(stmt, idx, Int32(i))
        } else if let i = obj as? UInt64 {
            sqlite3_bind_int64(stmt, idx, Int64(i))
        } else if let i = obj as? UInt8 {
            sqlite3_bind_int(stmt, idx, Int32(i))
        } else if let d = obj as? Double {
            sqlite3_bind_double(stmt, idx, d)
        } else if let d = obj as? Float {
            sqlite3_bind_double(stmt, idx, Double(d))
        } else if let b = obj as? Bool {
            sqlite3_bind_int(stmt, idx, b ? 1 : 0)
        } else if let t = obj as? String {
            sqlite3_bind_text(stmt, idx, t, -1, nil)
        }
    }

    public func executeQuery(sql: String, args: [Any?] = []) -> ResultSet {
        var stmt: OpaquePointer? = nil
        let rc = sqlite3_prepare_v2(db, sql, -1, &stmt, nil)


        let queryCount = sqlite3_bind_parameter_count(stmt)

        if args.count == queryCount {
            for (i, item) in args.enumerated() {
                self.bindObject(obj: item, idx: Int32(i), stmt: stmt)
            }
        }

        let st = Statement()
        st.statement = stmt
        st.step()

        let rs = ResultSet(statement: st, database: self)

        return rs
    }

    public func executeQuery(sql: String, args: [String: Any?] = [:]) -> ResultSet {
        var stmt: OpaquePointer? = nil
        let rc = sqlite3_prepare_v2(db, sql, -1, &stmt, nil)

        for (key, value) in args {
            let namedIdx = sqlite3_bind_parameter_index(stmt, key)
            self.bindObject(obj: value, idx: namedIdx, stmt: stmt)
        }

        let queryCount = sqlite3_bind_parameter_count(stmt)

        let st = Statement()
        st.statement = stmt
        st.step()

        let rs = ResultSet(statement: st, database: self)

        return rs
    }

    public func executeUpdate(sql: String, args: [Any?]) -> Bool {
        var stmt: OpaquePointer? = nil

        defer {
            sqlite3_finalize(stmt)
        }
        var rc = sqlite3_prepare_v2(db, sql, -1, &stmt, nil)
        let queryCount = sqlite3_bind_parameter_count(stmt)
        if args.count == queryCount {
            for (i, item) in args.enumerated() {
                self.bindObject(obj: item, idx: Int32(i), stmt: stmt)
            }
        }

        rc = sqlite3_step(stmt)
        return rc == SQLITE_DONE || rc == SQLITE_OK
    }

    var lastErrorMessage: String {
        return String(cString: sqlite3_errmsg(db))
    }

    deinit {
        sqlite3_close(db)
    }
}