//
//  MapAssignmentView.swift
//  PokopiaApp
//
//  Created by Apple on 2026/7/2.
//

import SwiftUI


struct MapAssignmentView: View {
    @StateObject var viewModel = MapOverviewViewModel()

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.mapItems) { item in
                    NavigationLink(destination: MapDetailView(mapId: item.map?.id, mapName: item.displayName)) {
                        MapCardView(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationTitle("地圖分配")
        .onAppear {
            viewModel.loadData()
        }
    }
}

// 單張地圖卡片：圖片 + 名字 + 數量
struct MapCardView: View {
    let item: MapWithCount

    var body: some View {
        VStack(spacing: 8) {
            if let imageFile = item.imageFile {
                Image(imageFile.replacingOccurrences(of: ".png", with: ""))
                    .resizable()
                    .scaledToFill()
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 100)
                    .overlay(
                        Image("overall_map")
                            .font(.largeTitle)
                            .foregroundStyle(.gray)
                    )
            }

            Text(item.displayName)
                .font(.headline)

            Text("\(item.count) 隻")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4)
        .contentShape(Rectangle())   // 加這行
    }
}

#Preview {
    NavigationStack {
        MapAssignmentView()
    }
}
