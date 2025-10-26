//
//  Colors.swift
//  ANTicipa
//
//  Created by Enmanuel Rivas Barinas on 10/25/25.
//  Ajustado por Emilio Puga Ascencio
//

import SwiftUI

// MARK: - Paleta oficial Capital One adaptada a ANTicipa
extension Color {
    static let capitalOneBlue = Color(hex: "#004878")
    static let capitalOneRed = Color(hex: "#B22524")
    static let capitalOneLightBlue = Color(hex: "#0071CE")
    static let capitalOneNavy = Color(hex: "#003A63")
    static let capitalOneGray = Color(hex: "#F5F7FA")
    static let capitalOneDarkGray = Color(hex: "#4A4A4A")
    static let capitalOneYellow = Color(hex: "#FFC20E")
}

// MARK: - Paleta de marca ANTicipa
struct BrandColors {
    static let primary = Color.capitalOneNavy       // Azul institucional
    static let secondary = Color.capitalOneRed      // Rojo hormiga
    static let accent = Color.capitalOneYellow      // Detalle cálido
    static let background = Color.capitalOneGray    // Fondo claro
    static let textPrimary = Color.capitalOneDarkGray
    static let textContrast = Color.white
}

// MARK: - Paleta de interfaz
struct UIColors {
    static let buttonPrimary = BrandColors.primary
    static let buttonSecondary = BrandColors.secondary
    static let inputBackground = Color.white
    static let border = Color.black.opacity(0.1)
    static let shadow = Color.black.opacity(0.08)
}

// MARK: - Inicializador HEX
extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}
