//
//  Note.swift
//  Notes
//
//  Created by Sanjeev Garg on 23/04/20.
//  Copyright © 2020 Karan. All rights reserved.
//

import Foundation
import SQLite3

struct Note {
    let id: Int
    var content: String
}
class NoteManager {
    var database: OpaquePointer!
    
    // have a static object of itself to use
    static let main = NoteManager()
    // do not let anyone make any instance of noteManager
    private init() {
        
    }
    
    func connect() {
        // return if already you have a pointer to the sqlite database
        // if not than just create the databse pointer and make a table if it does not exist
        if database != nil {
            return
        }
        do {
            let databaseURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("notes.sqlite3")
            if sqlite3_open(databaseURL.path, &database) == SQLITE_OK {
                if sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS notes (content TEXT)", nil, nil, nil) == SQLITE_OK {
                    
                } else {
                    print("Could not Create Table")
                }
            } else {
                print("Could not Connect")
            }
        }
        catch let error {
            print(error)
            print("Could not open file")
        }
    }
    
    func create() -> Int {
        connect()
        
        var statement: OpaquePointer!
        if sqlite3_prepare_v2(database, "INSERT INTO notes (content) VALUES ('New NOTE')", -1, &statement, nil) != SQLITE_OK {
            print("Could not create query")
            return -1
        }
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Could not process query")
            return -1
        }
        sqlite3_finalize(statement)
        return Int(sqlite3_last_insert_rowid(database))
    }
    
    func getAllNotes() -> [Note] {
        connect()
        var result: [Note] = []
        
        var statement: OpaquePointer!
        if sqlite3_prepare_v2(database, "SELECT rowid, content FROM notes", -1, &statement, nil) != SQLITE_OK {
            print("Could not create query")
                return []
        }
        while sqlite3_step(statement) == SQLITE_ROW {
            result.append(Note(id: Int(sqlite3_column_int(statement, 0)), content: String(cString: sqlite3_column_text(statement, 1))))
        }
        sqlite3_finalize(statement)
        return result
    }
    
    func save(note: Note) {
        connect()
        
        var statement: OpaquePointer!
        if sqlite3_prepare_v2(database, "UPDATE notes SET content = ? WHERE rowid = ?", -1, &statement, nil) != SQLITE_OK {
            print("Could not create query")
            return
        }
        
        sqlite3_bind_text(statement, 1, NSString(string: note.content).utf8String, -1, nil)
        sqlite3_bind_int(statement, 2, Int32(note.id))
        
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Could not process query")
            return
        }
        sqlite3_finalize(statement)
        return
    }
    
    func delete(note: Note) {
        connect()
        
        var statement: OpaquePointer!
        if sqlite3_prepare_v2(database, "DELETE FROM notes WHERE rowid = ?", -1, &statement, nil) != SQLITE_OK {
            print("Could not create query")
            return
        }
        sqlite3_bind_int(statement, 1, Int32(note.id))
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Could not process delet query")
            return
        }
        sqlite3_finalize(statement)
    }
}
