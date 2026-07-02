//
//  PokemonDetailView.swift
//  PokopiaApp
//
//  Created by Apple on 2026/7/2.
//

import SwiftUI

struct PokemonDetailView: View {
    let pokemon: Pokemon

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 圖片
                Image(pokemon.imageFile.replacingOccurrences(of: ".png", with: ""))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .background(Circle().fill(Color.green.opacity(0.1)))

                // 編號 + 名稱
                VStack(spacing: 4) {
                    Text(String(format: "No.%03d", pokemon.id))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(pokemon.nameChinese)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(pokemon.nameEnglish)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                // 屬性
                HStack(spacing: 8) {
                    TypeBadge(type: pokemon.type1)
                    if let type2 = pokemon.type2 {
                        TypeBadge(type: type2)
                    }
                }

                Divider()

                // 其他資訊區塊
                VStack(alignment: .leading, spacing: 16) {
                    InfoSection(title: "特長", items: pokemon.specialties)
                    InfoSection(title: "出沒時間", items: pokemon.spawnTime)
                    InfoSection(title: "天氣", items: pokemon.weather)
                    InfoSection(title: "喜歡的環境", items: pokemon.environment)
                    InfoSection(title: "喜好", items: pokemon.favorites)
                    InfoSection(title: "獲得方式", items: pokemon.obtainMethod)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle(pokemon.nameChinese)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// 顯示一組標籤清單的共用元件（特長、喜好、環境都用這個）
struct InfoSection: View {
    let title: String
    let items: [String]

    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)

                FlowLayout(spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
}
