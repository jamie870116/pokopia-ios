//
//  MapDetailView.swift
//  PokopiaApp
//
//  Created by Apple on 2026/7/4.
//

import SwiftUI

struct MapDetailView: View {
    @StateObject private var viewModel: MapDetailViewModel
    @State private var showAddSheet = false

    init(mapId: Int?, mapName: String) {
        _viewModel = StateObject(wrappedValue: MapDetailViewModel(mapId: mapId, mapName: mapName))
    }

    var body: some View {
        List(viewModel.pokemons) { pokemon in
            HStack {
                Image(pokemon.imageFile.replacingOccurrences(of: ".png", with: ""))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)

                Text(pokemon.nameChinese)
                    .font(.body)

                Spacer()
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "搜尋名稱或編號...")
        .navigationTitle(viewModel.mapName)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showAddSheet, onDismiss: {
            viewModel.loadPokemons()
        }) {
            AddPokemonSheet(targetMapId: viewModel.mapId)
        }
        .onAppear {
            viewModel.loadPokemons()
        }
    }
}
