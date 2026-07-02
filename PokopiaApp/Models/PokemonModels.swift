//
//  PokemonModels.swift
//  PokopiaApp
//
//  Created by Apple on 2026/7/2.
//
import Foundation


// 對應原始 JSON 檔案裡單筆 Pokémon 的結構，用來解析（Decode）用
struct PokemonJSON: Codable {
    let slug: String
    let number: String
    let nameChinese: String
    let nameEnglish: String
    let pokemonImageFile: String
    let types: [String]
    let specialties: [String]
    let spawnTime: [String]
    let weather: [String]
    let environment: [String]
    let favorites: [String]
    let obtainMethod: [String]
    let habitats: [Habitat]
}

struct Habitat: Codable {
    let name: String
    let slug: String
    let href: String
    let imageFile: String
}

// App 實際使用的核心資料模型，對應 SQLite pokemons 表
struct Pokemon: Identifiable {
    let id: Int
    let slug: String
    let nameChinese: String
    let nameEnglish: String
    let imageFile: String
    let type1: String
    let type2: String?            // optional：只有一個屬性時為 nil
    let specialties: [String]
    let spawnTime: [String]
    let weather: [String]
    let environment: [String]
    let favorites: [String]
    let obtainMethod: [String]
    let habitats: [Habitat]
    var mapId: Int?                // optional：nil = 尚未分配到任何地圖
}

// 地圖，對應 SQLite maps 表
struct GameMap: Identifiable {
    let id: Int
    let nameChinese: String
    let nameEnglish: String
    let imageFile: String
}

