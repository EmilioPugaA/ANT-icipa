//
//  AuthViewModel.swift
//  ANTicipa
//
//  Created by Emilio Puga on 25/10/25.
//


import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    // Simulación base de datos local
    private let localUsers = [
        "emilio": "1234",
        "atenas": "abcd",
        "admin": "admin123"
    ]

    func login(username: String, password: String) async {
        isLoading = true
        try? await Task.sleep(for: .seconds(1)) // Simula delay de red
        
        if let storedPass = localUsers[username.lowercased()],
           storedPass == password {
            isAuthenticated = true
            errorMessage = nil
        } else {
            errorMessage = "Usuario o contraseña incorrectos"
            isAuthenticated = false
        }
        
        isLoading = false
    }

    func logout() {
        isAuthenticated = false
    }
}
