//
//  Message.swift
//  ANTicipa
//
//  Creado por Enmanuel Rivas Barinas el 25/10/25.
//

import Foundation

/// Modelo usado para enviar el historial a la API de Gemini
struct Message: Codable, Identifiable {
    let id = UUID()
    let role: String      // "user" o "model"
    let text: String
    var time: String? = nil
    var senderName: String? = nil
    var imageName: String? = nil
}
