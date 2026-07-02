//
//  PokedexListViewModel.swift
//  PokopiaApp
//
//  Created by Apple on 2026/7/2.
//

import Foundation

class PokedexListViewModel: ObservableObject {
    @Published var pokemons: [Pokemon] = []
    @Published var searchText: String = "" {
        didSet { applyFilters() }
    }

    // 改成 Set，可以裝多個選中的值
    @Published var selectedTypes: Set<String> = [] {
        didSet { applyFilters() }
    }
    @Published var selectedSpecialties: Set<String> = [] {
        didSet { applyFilters() }
    }
    @Published var selectedFavorites: Set<String> = [] {
        didSet { applyFilters() }
    }
    @Published var selectedEnvironments: Set<String> = [] {
        didSet { applyFilters() }
    }

    @Published var allTypes: [String] = []
    @Published var allSpecialties: [String] = []
    @Published var allFavorites: [String] = []
    @Published var allEnvironments: [String] = []

    private let repository = PokemonRepository()

    func loadData() {
        repository.importFromJSONIfNeeded()
        pokemons = repository.fetchAll()
        loadFilterOptions()
    }

    private func loadFilterOptions() {
        allTypes = repository.fetchAllTypes()
        allSpecialties = repository.fetchAllSpecialties()
        allFavorites = repository.fetchAllFavorites()
        allEnvironments = repository.fetchAllEnvironments()
    }

    private func applyFilters() {
        pokemons = repository.filter(
            searchText: searchText,
            types: selectedTypes,
            specialties: selectedSpecialties,
            favorites: selectedFavorites,
            environments: selectedEnvironments
        )
    }

    // 切換選取狀態：已選中就移除，未選中就加入
    func toggleType(_ value: String) {
        if selectedTypes.contains(value) {
            selectedTypes.remove(value)
        } else {
            // 類型最多兩個（呼應寶可夢本身最多兩屬性的邏輯）
            if selectedTypes.count < 2 {
                selectedTypes.insert(value)
            }
        }
    }

    func toggleSpecialty(_ value: String) {
        toggle(value, in: &selectedSpecialties)
    }

    func toggleFavorite(_ value: String) {
        toggle(value, in: &selectedFavorites)
    }

    func toggleEnvironment(_ value: String) {
        toggle(value, in: &selectedEnvironments)
    }

    private func toggle(_ value: String, in set: inout Set<String>) {
        if set.contains(value) {
            set.remove(value)
        } else {
            set.insert(value)
        }
    }

    // 清除全部篩選
    func clearFilters() {
        selectedTypes.removeAll()
        selectedSpecialties.removeAll()
        selectedFavorites.removeAll()
        selectedEnvironments.removeAll()
        searchText = ""
    }
}
