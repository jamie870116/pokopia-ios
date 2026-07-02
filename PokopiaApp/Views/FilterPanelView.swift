//
//  FilterPanelView.swift
//  PokopiaApp
//
//  Created by Apple on 2026/7/2.
//

import SwiftUI

struct FilterPanelView: View {
    @ObservedObject var viewModel: PokedexListViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FilterCategoryRow(
                title: "按類型瀏覽",
                items: viewModel.allTypes,
                selectedItems: viewModel.selectedTypes,
                onToggle: { viewModel.toggleType($0) }
            )
            Divider()

            FilterCategoryRow(
                title: "按特長瀏覽",
                items: viewModel.allSpecialties,
                selectedItems: viewModel.selectedSpecialties,
                onToggle: { viewModel.toggleSpecialty($0) }
            )
            Divider()

            FilterCategoryRow(
                title: "按喜好瀏覽",
                items: viewModel.allFavorites,
                selectedItems: viewModel.selectedFavorites,
                onToggle: { viewModel.toggleFavorite($0) }
            )
            Divider()

            FilterCategoryRow(
                title: "按喜歡的環境瀏覽",
                items: viewModel.allEnvironments,
                selectedItems: viewModel.selectedEnvironments,
                onToggle: { viewModel.toggleEnvironment($0) }
            )

            // 清除全部（輕觸按鈕）
            Button {
                viewModel.clearFilters()
            } label: {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                    Text("清除全部篩選")
                }
                .font(.subheadline)
                .foregroundStyle(.red)
                .padding(.top, 12)
            }
        }
        .padding()
    }
}

// 單一篩選分類：標題可點擊展開/收合，展開後顯示可複選的按鈕群
struct FilterCategoryRow: View {
    let title: String
    let items: [String]
    let selectedItems: Set<String>
    let onToggle: (String) -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    if !selectedItems.isEmpty {
                        Text("(\(selectedItems.count))")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                FlowLayout(spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        FilterChip(title: item, isSelected: selectedItems.contains(item)) {
                            onToggle(item)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
    }
}
