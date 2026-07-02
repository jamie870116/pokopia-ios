//
//  PokemonDatabase.swift
//  PokopiaApp
//
//  Created by Apple on 2026/7/2.
//

import Foundation

class PokemonDatabase {
    static let shared = PokemonDatabase()
    private var db: OpaquePointer?

    private init() {
        openDatabase()
        createTables()
    }

    private func openDatabase() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("pokopia.sqlite3")

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
        } else {
            print("Database opened at: \(fileURL.path)")
        }
    }

    private func createTables() {
        let createPokemonTable = """
        CREATE TABLE IF NOT EXISTS pokemons (
            id INTEGER PRIMARY KEY,
            slug TEXT NOT NULL,
            nameChinese TEXT NOT NULL,
            nameEnglish TEXT NOT NULL,
            imageFile TEXT NOT NULL,
            type1 TEXT NOT NULL,
            type2 TEXT,
            specialties TEXT,
            spawnTime TEXT,
            weather TEXT,
            environment TEXT,
            favorites TEXT,
            obtainMethod TEXT,
            habitatsJSON TEXT,
            mapId INTEGER
        );
        """

        let createMapTable = """
        CREATE TABLE IF NOT EXISTS maps (
            id INTEGER PRIMARY KEY,
            nameChinese TEXT NOT NULL,
            nameEnglish TEXT NOT NULL,
            imageFile TEXT
        );
        """

        execute(createPokemonTable)
        execute(createMapTable)
        seedMapsIfNeeded()
    }

    private func execute(_ sql: String) {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error executing: \(sql)")
            }
        } else {
            print("Error preparing: \(sql)")
        }
        sqlite3_finalize(statement)
    }

    private func seedMapsIfNeeded() {
        let checkSQL = "SELECT COUNT(*) FROM maps;"
        var statement: OpaquePointer?
        var count = 0

        if sqlite3_prepare_v2(db, checkSQL, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                count = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)

        if count == 0 {
            // TODO: 之後補上英文名跟圖檔名，這裡先放預設值
            let maps: [(id: Int, nameChinese: String, nameEnglish: String, imageFile: String)] = [
                (1, "空空鎮", "Palette Town", ""),
                (2, "乾巴巴荒野", "Withered Wastelands", ""),
                (3, "陰沉沉海濱", "Bleak Beach", ""),
                (4, "凸隆隆山地", "Rocky Ridges", ""),
                (5, "亮晶晶空島", "Sparkling Skyland", "")
            ]

            for map in maps {
                let insertSQL = """
                INSERT INTO maps (id, nameChinese, nameEnglish, imageFile)
                VALUES (\(map.id), '\(map.nameChinese)', '\(map.nameEnglish)', '\(map.imageFile)');
                """
                execute(insertSQL)
            }
            print("Seeded \(maps.count) maps")
        }
    }

    func getConnection() -> OpaquePointer? {
        return db
    }
}
