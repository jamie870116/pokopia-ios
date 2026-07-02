//
//  TypeColors.swift
//  PokopiaApp
//
//  Created by Apple on 2026/7/2.
//

import SwiftUI

enum TypeColors {
    static func color(for type: String) -> Color {
        switch type {
        case "草": return Color(red: 0x5D/255, green: 0x8A/255, blue: 0x3C/255)
        case "火": return Color(red: 0xC8/255, green: 0x40/255, blue: 0x28/255)
        case "水": return Color(red: 0x3B/255, green: 0x7F/255, blue: 0xC4/255)
        case "電": return Color(red: 0xA0/255, green: 0x88/255, blue: 0x00/255)
        case "冰": return Color(red: 0x4A/255, green: 0x90/255, blue: 0xB8/255)
        case "格鬥": return Color(red: 0x9A/255, green: 0x30/255, blue: 0x30/255)
        case "毒": return Color(red: 0x7C/255, green: 0x3F/255, blue: 0x9A/255)
        case "地面": return Color(red: 0x92/255, green: 0x70/255, blue: 0x40/255)
        case "飛行": return Color(red: 0x58/255, green: 0x70/255, blue: 0xC8/255)
        case "超能力": return Color(red: 0xC8/255, green: 0x30/255, blue: 0x70/255)
        case "蟲": return Color(red: 0x6A/255, green: 0x8A/255, blue: 0x10/255)
        case "岩石": return Color(red: 0x8A/255, green: 0x70/255, blue: 0x40/255)
        case "幽靈": return Color(red: 0x4A/255, green: 0x30/255, blue: 0x70/255)
        case "龍": return Color(red: 0x30/255, green: 0x38/255, blue: 0xB0/255)
        case "惡": return Color(red: 0x50/255, green: 0x38/255, blue: 0x28/255)
        case "鋼": return Color(red: 0x68/255, green: 0x70/255, blue: 0xA0/255)
        case "妖精": return Color(red: 0xC0/255, green: 0x70/255, blue: 0xA0/255)
        case "一般": return Color(red: 0x88/255, green: 0x88/255, blue: 0x88/255)
        default: return .gray
        }
    }
}
