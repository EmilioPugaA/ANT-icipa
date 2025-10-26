//
//  Account.swift
//  ANTicipa
//
//  Created by Enmanuel Rivas Barinas on 10/25/25.
//

import Foundation

/// Representa una cuenta bancaria de un usuario en la API de Nessie
struct Account: Codable, Identifiable {
    let id: String
    let type: String
    let nickname: String?
    let rewards: Int?
    let balance: Double
    let account_number: String?
    let customer_id: String?
    let date_created: String?
}
