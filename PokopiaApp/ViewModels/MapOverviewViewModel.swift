//
//  MapOverviewViewModel.swift
//  PokopiaApp
//
//  Created by Apple on 2026/7/4.
//

import Foundation

// 給地圖總覽畫面用，把 GameMap 加上「目前有幾隻寶可夢」這個額外資訊
struct MapWithCount: Identifiable {
    let map: GameMap?   // nil 代表「未分配」這個特殊卡片
    let count: Int

    var id: Int {
        map?.id ?? -1   // 「未分配」用 -1 當作固定識別碼
    }

    var displayName: String {
        map?.nameChinese ?? "未分配"
    }

    var imageFile: String? {
        map?.imageFile
    }
}

class MapOverviewViewModel: ObservableObject {
    @Published var mapItems: [MapWithCount] = []

    private let repository = PokemonRepository()

    func loadData() {
        let maps = repository.fetchAllMaps()

        var items: [MapWithCount] = maps.map { map in
            MapWithCount(map: map, count: repository.countPokemons(mapId: map.id))
        }

        // 加上「未分配」這張特殊卡片
        let unassignedCount = repository.countPokemons(mapId: nil)
        items.append(MapWithCount(map: nil, count: unassignedCount))

        mapItems = items
    }
}
