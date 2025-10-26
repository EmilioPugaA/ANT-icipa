//
//  LoginViewModel.swift
//  ANTicipa
//
//  Creado por Emilio Puga Ascencio el 25/10/25.
//

import SwiftUI

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Usuario completo para pasar al Chat
    @Published var loggedUser: UserInfo? = nil
    
    // Persistencia básica
    @AppStorage("username") var username: String = ""
    @AppStorage("userId") var userId: Int = 0
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("userBalance") var userBalance: Double = 0.0
    
    // MARK: - LOGIN NORMAL
    func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Por favor, ingresa tu correo y contraseña."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await ANTicipaAPIClient.shared.login(email: email, password: password)
            
            if response.success, let user = response.user {
                // Guardar datos básicos
                username = user.nombre_completo
                userId = user.id_cliente
                userBalance = user.balance ?? 0.0
                loggedUser = user        // ✅ usuario completo
                isLoggedIn = true
                
                // Guardar email para Face ID
                UserDefaults.standard.set(email, forKey: "savedEmail")
                
                print("Inicio de sesión correcto: \(user.nombre_completo)")
            } else {
                errorMessage = response.message.isEmpty ? "Error desconocido al iniciar sesión." : response.message
            }
        } catch {
            errorMessage = "Error de conexión: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - LOGIN BIOMÉTRICO
    func loginWithBiometrics(email: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Contraseña dummy o token cifrado según backend
            let response = try await ANTicipaAPIClient.shared.login(email: email, password: "123")
            
            if response.success, let user = response.user {
                username = user.nombre_completo
                userId = user.id_cliente
                userBalance = user.balance ?? 0.0
                loggedUser = user       // ✅ usuario completo
                isLoggedIn = true
                
                print("Inicio de sesión biométrico exitoso: \(user.nombre_completo)")
            } else {
                errorMessage = "No se pudo iniciar sesión con Face ID."
            }
        } catch {
            errorMessage = "Error al conectar: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
