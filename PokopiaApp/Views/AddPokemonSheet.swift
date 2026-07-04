//
//  AddPokemonSheet.swift
//  PokopiaApp
//
//  Created by Apple on 2026/7/4.
//

import SwiftUI

struct AddPokemonSheet: View {
    @StateObject private var viewModel: AddPokemonViewModel
    @Environment(\.dismiss) private var dismiss

    init(targetMapId: Int?) {
        _viewModel = StateObject(wrappedValue: AddPokemonViewModel(targetMapId: targetMapId))
    }

    var body: some View {
        NavigationStack {
            List(viewModel.searchResults) { pokemon in
                Button {
                    viewModel.toggleSelection(pokemon.id)
                } label: {
                    HStack {
                        Image(pokemon.imageFile.replacingOccurrences(of: ".png", with: ""))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)

                        Text(pokemon.nameChinese)
                            .foregroundStyle(.primary)

                        Spacer()

                        if viewModel.selectedIds.contains(pokemon.id) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Image(systemName: "circle")
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "搜尋名稱或編號...")
            .navigationTitle("新增寶可夢")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("確定") {
                        viewModel.confirmAssignment()
                        dismiss()
                    }
                    .disabled(viewModel.selectedIds.isEmpty)
                }
            }
        }
    }
}
