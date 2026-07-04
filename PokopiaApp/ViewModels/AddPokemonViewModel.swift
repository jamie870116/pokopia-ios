//
//  AddPokemonSheet.swift
//  PokopiaApp
//
//  Created by Apple on 2026/7/4.
//

import Foundation

class AddPokemonViewModel: ObservableObject {
    @Published var searchResults: [Pokemon] = []
    @Published var searchText: String = "" {
        didSet { search() }
    }
    @Published var selectedIds: Set<Int> = []

    let targetMapId: Int?
    private let repository = PokemonRepository()

    init(targetMapId: Int?) {
        self.targetMapId = targetMapId
    }

    // 只搜尋「尚未分配」或「在其他地圖」的寶可夢都可以選（因為一隻只能屬於一個分類，
    // 選中後會自動從原本的地圖移除、改分配到這裡）
    func search() {
        if searchText.isEmpty {
            searchResults = []
            return
        }
        searchResults = repository.search(query: searchText)
    }

    func toggleSelection(_ id: Int) {
        if selectedIds.contains(id) {
            selectedIds.remove(id)
        } else {
            selectedIds.insert(id)
        }
    }

    func confirmAssignment() {
        repository.assignPokemons(ids: Array(selectedIds), toMapId: targetMapId)
    }
}
