//
//  HomeView.swift
//  PokopiaApp
//
//  Created by Apple on 2026/7/2.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // 歡迎圖示
                Image("logo-pokopia")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)

                Text("Welcome to Pokopia App")
                    .font(.title)
                    .fontWeight(.bold)

                Spacer()

                // 兩個大按鈕
                VStack(spacing: 16) {
                    NavigationLink(destination: PokedexListView()) {
                        HomeMenuButton(title: "圖鑑", systemImage: "book.fill", color: .green)
                    }

                    NavigationLink(destination: MapAssignmentView()) {
                        HomeMenuButton(title: "地圖分配", systemImage: "map.fill", color: .blue)
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }.navigationTitle("").navigationBarTitleDisplayMode(.inline)
        }
    }
}

// 按鈕樣式抽成小元件，方便兩個按鈕共用
struct HomeMenuButton: View {
    let title: String
    let systemImage: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.title2)
            Text(title)
                .font(.headline)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding()
        .foregroundStyle(.white)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    HomeView()
}
