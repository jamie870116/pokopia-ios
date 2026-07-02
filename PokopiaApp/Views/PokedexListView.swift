//
//  PokedexListView.swift
//  PokopiaApp
//
//  Created by Apple on 2026/7/2.
//

import SwiftUI

struct PokedexListView: View {
    @StateObject var viewModel = PokedexListViewModel()
    @State private var isFilterExpanded = false

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // 篩選按鈕列（顯示筆數 + 展開/收合切換）
            HStack {
                Button {
                    withAnimation {
                        isFilterExpanded.toggle()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "magnifyingglass")
                        Text("篩選")
                        Image(systemName: isFilterExpanded ? "chevron.up" : "chevron.down")
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.15))
                    .foregroundStyle(.green)
                    .clipShape(Capsule())
                }

                Spacer()

                Text("\(viewModel.pokemons.count) / 303")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // 展開時顯示篩選面板
            if isFilterExpanded {
                ScrollView {
                    FilterPanelView(viewModel: viewModel)
                }
                .frame(maxHeight: 300)
                Divider()
            }

            // Pokémon 卡片清單
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.pokemons) { pokemon in
                        NavigationLink(destination: PokemonDetailView(pokemon: pokemon)) {
                            PokemonCardView(pokemon: pokemon)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "搜尋名稱或編號...")
        .navigationTitle("寶可夢圖鑑")
        .onAppear {
            viewModel.loadData()
        }
    }
}

#Preview {
    NavigationStack {
        PokedexListView()
    }
}
