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


    public func bindObject(obj: Any?, idx: Int32, stmt: OpaquePointer?) -> Bool {

        var ret = SQLITE_OK

        switch obj {
        case let value as Data:
            ret = sqlite3_bind_blob64(stmt, idx, value.castToCPointer(), UInt64(value.count), nil)
        case let value as Date:
            ret = sqlite3_bind_double(stmt, idx, value.timeIntervalSince1970)
        case let value as Int32:
            ret = sqlite3_bind_int(stmt, idx, value)
        case let value as Int16:
            ret = sqlite3_bind_int(stmt, idx, Int32(value))
        case let value as Int64:
            ret = sqlite3_bind_int64(stmt, idx, value)
        case let value as Int8:
            ret = sqlite3_bind_int(stmt, idx, Int32(value))
        case let value as UInt32:
            ret = sqlite3_bind_int(stmt, idx, Int32(value))
        case let value as UInt16:
            ret = sqlite3_bind_int(stmt, idx, Int32(value))
        case let value as UInt64:
            ret = sqlite3_bind_int64(stmt, idx, Int64(value))
        case let value as UInt8:
            ret = sqlite3_bind_int(stmt, idx, Int32(value))
        case let value as Double:
            ret = sqlite3_bind_double(stmt, idx, value)
        case let value as Float:
            ret = sqlite3_bind_double(stmt, idx, Double(value))
        case let value as Float32:
            ret = sqlite3_bind_double(stmt, idx, Double(value))
        case let value as Bool:
            ret = sqlite3_bind_int(stmt, idx, value ? 1 : 0)
        case let value as String:
            ret = sqlite3_bind_text(stmt, idx, value, -1, nil)
        default:
            ret = sqlite3_bind_null(stmt, idx)
        }

        return ret == SQLITE_OK
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
                if self.bindObject(obj: item, idx: Int32(i + 1), stmt: stmt) == false {
                    print("\(self.lastErrorMessage)")
                }
            }
        }

        rc = sqlite3_step(stmt)
        return rc == SQLITE_DONE || rc == SQLITE_OK
    }

    public func beginTransaction() -> Bool {
        let b = self.executeUpdate(sql: "begin exclusive transaction", args: [])
        return b
    }

    public func commit() -> Bool {
        let b = self.executeUpdate(sql: "commit transaction", args: [])
        return b
    }

    var lastErrorMessage: String {
        return String(cString: sqlite3_errmsg(db))
    }

    deinit {
        sqlite3_close(db)
    }
}