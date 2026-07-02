//
//  PokemonCardView.swift
//  PokopiaApp
//
//  Created by Apple on 2026/7/2.
//

import SwiftUI

struct PokemonCardView: View {
    let pokemon: Pokemon

    var body: some View {
        VStack(spacing: 8) {
            Image(pokemon.imageFile.replacingOccurrences(of: ".png", with: ""))
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .background(
                    Circle().fill(Color.green.opacity(0.1))
                )

            Text(String(format: "No.%03d", pokemon.id))
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(pokemon.nameChinese)
                .font(.headline)

            HStack(spacing: 6) {
                TypeBadge(type: pokemon.type1)
                if let type2 = pokemon.type2 {
                    TypeBadge(type: type2)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 4)
    }
}

// 屬性標籤（草、毒、火...這種小圓角膠囊）
struct TypeBadge: View {
    let type: String

    var body: some View {
        Text(type)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(TypeColors.color(for: type))
            .clipShape(Capsule())
    }
}
