//
//  Customer.swift
//  ANTicipa
//
//  Created by Enmanuel Rivas Barinas on 10/25/25.
//

import Foundation

/// Representa un cliente (usuario) de la API de Nessie
struct Customer: Codable, Identifiable {
    let id: String
    let first_name: String
    let last_name: String
    let address: Address?

    struct Address: Codable {
        let street_number: String?
        let street_name: String?
        let city: String?
        let state: String?
        let zip: String?
    }
}
