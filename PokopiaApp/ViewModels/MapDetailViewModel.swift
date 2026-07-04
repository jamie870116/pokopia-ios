//
//  MapDetailViewModel.swift
//  PokopiaApp
//
//  Created by Apple on 2026/7/4.
//

import Foundation

class MapDetailViewModel: ObservableObject {
    @Published var pokemons: [Pokemon] = []
    @Published var searchText: String = "" {
        didSet { loadPokemons() }
    }

    let mapId: Int?      // nil 代表這是「未分配」的詳情頁
    let mapName: String
    private let repository = PokemonRepository()

    init(mapId: Int?, mapName: String) {
        self.mapId = mapId
        self.mapName = mapName
    }

    func loadPokemons() {
        pokemons = repository.fetchPokemons(mapId: mapId, searchText: searchText)
    }
}
