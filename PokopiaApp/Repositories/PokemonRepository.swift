//
//  PokemonRepository.swift
//  PokopiaApp
//
//  Created by Apple on 2026/7/2.
//

import Foundation

class PokemonRepository {
    private let db = PokemonDatabase.shared.getConnection()

    // 從 Bundle 讀取 JSON 並匯入 SQLite（只在第一次執行）
    func importFromJSONIfNeeded() {
        if !isEmpty() {
//            print("已有資料，略過匯入")
            return
        }

        guard let url = Bundle.main.url(forResource: "pokemon_data", withExtension: "json") else {
            print("找不到 pokemon_data.json，確認檔案有加進 target")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([PokemonJSON].self, from: data)
            insertAll(decoded)
            print("匯入 \(decoded.count) 筆 Pokémon 資料")
        } catch {
            print("JSON 解析失敗: \(error)")
        }
    }

    private func isEmpty() -> Bool {
        let sql = "SELECT COUNT(*) FROM pokemons;"
        var statement: OpaquePointer?
        var count = 0
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                count = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)
        return count == 0
    }

    private func insertAll(_ items: [PokemonJSON]) {
        let insertSQL = """
        INSERT INTO pokemons
        (id, slug, nameChinese, nameEnglish, imageFile, type1, type2,
         specialties, spawnTime, weather, environment, favorites, obtainMethod,
         habitatsJSON, mapId)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """

        for item in items {
            var statement: OpaquePointer?
            guard sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK else {
                print("Prepare 失敗: \(item.nameEnglish)")
                continue
            }

            let idInt = Int(item.number) ?? 0
            let type1 = item.types.first ?? ""
            let type2: String? = item.types.count > 1 ? item.types[1] : nil
            let habitatsString = encodeHabitats(item.habitats)

            // 綁定基本欄位（SQLITE_TRANSIENT 讓 SQLite 自己複製字串，避免記憶體被提早釋放）
            sqlite3_bind_int(statement, 1, Int32(idInt))
            bindText(statement, 2, item.slug)
            bindText(statement, 3, item.nameChinese)
            bindText(statement, 4, item.nameEnglish)
            bindText(statement, 5, item.pokemonImageFile)
            bindText(statement, 6, type1)

            if let type2 = type2 {
                bindText(statement, 7, type2)
            } else {
                sqlite3_bind_null(statement, 7)
            }

            bindText(statement, 8, item.specialties.joined(separator: ","))
            bindText(statement, 9, item.spawnTime.joined(separator: ","))
            bindText(statement, 10, item.weather.joined(separator: ","))
            bindText(statement, 11, item.environment.joined(separator: ","))
            bindText(statement, 12, item.favorites.joined(separator: ","))
            bindText(statement, 13, item.obtainMethod.joined(separator: ","))
            bindText(statement, 14, habitatsString)
            sqlite3_bind_null(statement, 15)   // mapId 一開始都是未分配

            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("Insert 失敗: \(item.nameEnglish) - 原因: \(errorMessage)")
            }
            sqlite3_finalize(statement)
        }
    }

    // 把字串安全綁進 SQL statement 的小工具函式
    private func bindText(_ statement: OpaquePointer?, _ index: Int32, _ value: String) {
        sqlite3_bind_text(statement, index, (value as NSString).utf8String, -1, nil)
    }

    // habitats 是物件陣列，轉成 JSON 字串存
    private func encodeHabitats(_ habitats: [Habitat]) -> String {
        guard let data = try? JSONEncoder().encode(habitats),
              let jsonString = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return jsonString
    }
    
    // 讀取全部 Pokémon
    func fetchAll() -> [Pokemon] {
        let sql = "SELECT * FROM pokemons ORDER BY id ASC;"
        return runQuery(sql)
    }

    // 依名稱搜尋（中英文都比對）
    func search(query: String) -> [Pokemon] {
        if query.isEmpty { return fetchAll() }

        let sql = """
        SELECT * FROM pokemons
        WHERE nameChinese LIKE ? OR nameEnglish LIKE ? OR CAST(id AS TEXT) LIKE ?
        ORDER BY id ASC;
        """
        var statement: OpaquePointer?
        var results: [Pokemon] = []

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("Search prepare 失敗")
            return []
        }

        let pattern = "%\(query)%"
        bindText(statement, 1, pattern)
        bindText(statement, 2, pattern)
        bindText(statement, 3, pattern)

        while sqlite3_step(statement) == SQLITE_ROW {
            results.append(mapRowToPokemon(statement))
        }
        sqlite3_finalize(statement)
        return results
    }

    // 共用的查詢執行器（給 fetchAll 用，之後其他查詢也可以共用）
    private func runQuery(_ sql: String) -> [Pokemon] {
        var statement: OpaquePointer?
        var results: [Pokemon] = []

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("Query prepare 失敗")
            return []
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            results.append(mapRowToPokemon(statement))
        }
        sqlite3_finalize(statement)
        return results
    }
    
    // 依類型/特長/喜好/環境篩選（同時支援搜尋文字 + 篩選條件疊加使用）
    func filter(searchText: String, types: Set<String>, specialties: Set<String>, favorites: Set<String>, environments: Set<String>) -> [Pokemon] {
        var conditions: [String] = []
        var params: [String] = []

        if !searchText.isEmpty {
            conditions.append("(nameChinese LIKE ? OR nameEnglish LIKE ? OR CAST(id AS TEXT) LIKE ?)")
            let pattern = "%\(searchText)%"
            params.append(contentsOf: [pattern, pattern, pattern])
        }

        // 同一分類內選多個 = OR（符合任一個就算），跨分類 = AND（每個分類都要符合）
        if !types.isEmpty {
            let typeConditions = types.map { _ in "(type1 = ? OR type2 = ?)" }.joined(separator: " OR ")
            conditions.append("(\(typeConditions))")
            for type in types {
                params.append(contentsOf: [type, type])
            }
        }

        if !specialties.isEmpty {
            addCommaColumnCondition(column: "specialties", values: specialties, conditions: &conditions, params: &params)
        }

        if !favorites.isEmpty {
            addCommaColumnCondition(column: "favorites", values: favorites, conditions: &conditions, params: &params)
        }

        if !environments.isEmpty {
            addCommaColumnCondition(column: "environment", values: environments, conditions: &conditions, params: &params)
        }

        var sql = "SELECT * FROM pokemons"
        if !conditions.isEmpty {
            sql += " WHERE " + conditions.joined(separator: " AND ")
        }
        sql += " ORDER BY id ASC;"

        var statement: OpaquePointer?
        var results: [Pokemon] = []

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("Filter prepare 失敗")
            return []
        }

        for (index, param) in params.enumerated() {
            bindText(statement, Int32(index + 1), param)
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            results.append(mapRowToPokemon(statement))
        }
        sqlite3_finalize(statement)
        return results
    }

    // 共用：逗號分隔欄位的「選中任一個就符合」條件組裝
    private func addCommaColumnCondition(column: String, values: Set<String>, conditions: inout [String], params: inout [String]) {
        let subConditions = values.map { _ in "\(column) LIKE ?" }.joined(separator: " OR ")
        conditions.append("(\(subConditions))")
        for value in values {
            params.append("%\(value)%")
        }
    }
    
    // 抓出所有出現過的類型（例如 "草", "毒", "火"...）
    func fetchAllTypes() -> [String] {
        var types = Set<String>()

        let sql = "SELECT DISTINCT type1 FROM pokemons WHERE type1 IS NOT NULL UNION SELECT DISTINCT type2 FROM pokemons WHERE type2 IS NOT NULL;"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                types.insert(columnText(statement, 0))
            }
        }
        sqlite3_finalize(statement)
        return types.sorted()
    }

    // 抓出所有出現過的特長（因為存的是逗號分隔字串，要先撈出來再拆解去重）
    func fetchAllSpecialties() -> [String] {
        return fetchDistinctItemsFromCommaColumn("specialties")
    }

    func fetchAllFavorites() -> [String] {
        return fetchDistinctItemsFromCommaColumn("favorites")
    }

    func fetchAllEnvironments() -> [String] {
        return fetchDistinctItemsFromCommaColumn("environment")
    }

    // 共用邏輯：讀取某個逗號分隔欄位的全部資料，拆開、去重、排序
    private func fetchDistinctItemsFromCommaColumn(_ column: String) -> [String] {
        var items = Set<String>()

        let sql = "SELECT \(column) FROM pokemons;"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let raw = columnText(statement, 0)
                let parts = raw.split(separator: ",").map(String.init)
                items.formUnion(parts)
            }
        }
        sqlite3_finalize(statement)
        return items.sorted()
    }

    // 把資料庫一行資料轉成 Pokemon struct
    private func mapRowToPokemon(_ statement: OpaquePointer?) -> Pokemon {
        let id = Int(sqlite3_column_int(statement, 0))
        let slug = columnText(statement, 1)
        let nameChinese = columnText(statement, 2)
        let nameEnglish = columnText(statement, 3)
        let imageFile = columnText(statement, 4)
        let type1 = columnText(statement, 5)
        let type2 = columnTextOrNil(statement, 6)
        let specialties = columnText(statement, 7).split(separator: ",").map(String.init)
        let spawnTime = columnText(statement, 8).split(separator: ",").map(String.init)
        let weather = columnText(statement, 9).split(separator: ",").map(String.init)
        let environment = columnText(statement, 10).split(separator: ",").map(String.init)
        let favorites = columnText(statement, 11).split(separator: ",").map(String.init)
        let obtainMethod = columnText(statement, 12).split(separator: ",").map(String.init)
        let habitatsJSON = columnText(statement, 13)
        let habitats = decodeHabitats(habitatsJSON)
        let mapId: Int? = sqlite3_column_type(statement, 14) == SQLITE_NULL
            ? nil
            : Int(sqlite3_column_int(statement, 14))

        return Pokemon(
            id: id, slug: slug, nameChinese: nameChinese, nameEnglish: nameEnglish,
            imageFile: imageFile, type1: type1, type2: type2,
            specialties: specialties, spawnTime: spawnTime, weather: weather,
            environment: environment, favorites: favorites, obtainMethod: obtainMethod,
            habitats: habitats, mapId: mapId
        )
    }

    // 讀取 TEXT 欄位的小工具
    private func columnText(_ statement: OpaquePointer?, _ index: Int32) -> String {
        guard let cString = sqlite3_column_text(statement, index) else { return "" }
        return String(cString: cString)
    }

    // 讀取可能是 NULL 的 TEXT 欄位（例如 type2）
    private func columnTextOrNil(_ statement: OpaquePointer?, _ index: Int32) -> String? {
        if sqlite3_column_type(statement, index) == SQLITE_NULL { return nil }
        return columnText(statement, index)
    }

    private func decodeHabitats(_ jsonString: String) -> [Habitat] {
        guard let data = jsonString.data(using: .utf8),
              let habitats = try? JSONDecoder().decode([Habitat].self, from: data) else {
            return []
        }
        return habitats
    }
}
