//
//  LoginView.swift
//  ANTicipa
//
//  Creado por Emilio Puga Ascencio el 25/10/25.
//

import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    // MARK: - Variables globales
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("username") var username: String = ""
    @AppStorage("userBalance") var userBalance: Double = 0.0
    @AppStorage("biometricsEnabled") private var biometricsEnabled = false
    
    @State private var biometricError: String? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                // ✅ Navegación automática al ChatView
                if isLoggedIn, let user = viewModel.loggedUser {
                    ChatView(loggedUser: user)
                } else {
                    loginForm
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    // MARK: - Formulario de login
    private var loginForm: some View {
        VStack(spacing: 40) {
            
            // HEADER
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Conecta tu cuenta")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(BrandColors.textPrimary)
                    Text("CapitalOne para comenzar!")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(BrandColors.textPrimary)
                }
                Spacer()
                Image("hormigaLogIn")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding(.trailing, 4)
                    .offset(y: -6)
            }
            .padding(.horizontal, 30)
            .padding(.top, 90)
            
            // CAMPOS
            VStack(spacing: 26) {
                CustomTextField(
                    title: "Correo electrónico",
                    text: $viewModel.email,
                    isSecure: false,
                    icon: "envelope.fill"
                )
                
                CustomTextField(
                    title: "Contraseña",
                    text: $viewModel.password,
                    isSecure: true,
                    icon: "lock.fill"
                )
            }
            .padding(.horizontal, 30)
            
            // MENSAJE DE ERROR
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.system(size: 15))
                    .padding(.horizontal, 30)
                    .multilineTextAlignment(.center)
            }
            
            // BOTÓN NORMAL DE LOGIN
            Button {
                Task { await viewModel.login() }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(BrandColors.primary)
                        .cornerRadius(16)
                } else {
                    Text("Inicia Sesión")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(viewModel.email.isEmpty || viewModel.password.isEmpty
                                    ? BrandColors.primary.opacity(0.4)
                                    : BrandColors.primary)
                        .cornerRadius(16)
                }
            }
            .padding(.horizontal, 30)
            .disabled(viewModel.email.isEmpty || viewModel.password.isEmpty)
            
            // 🔐 BOTÓN BIOMÉTRICO
            if biometricsEnabled {
                VStack(spacing: 8) {
                    Button {
                        authenticateWithBiometrics()
                    } label: {
                        Label("Usar Face ID / Touch ID", systemImage: "faceid")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(BrandColors.primary)
                    }
                    
                    if let biometricError {
                        Text(biometricError)
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .padding(.top, 4)
            }
            
            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
    }
    
    // MARK: - Autenticación biométrica
    func authenticateWithBiometrics() {
        BiometricAuth.shared.authenticateUser { success, errorMessage in
            if success {
                if let savedEmail = UserDefaults.standard.string(forKey: "savedEmail") {
                    Task {
                        await viewModel.loginWithBiometrics(email: savedEmail)
                    }
                } else {
                    biometricError = "No hay sesión guardada para usar Face ID."
                }
            } else {
                biometricError = errorMessage ?? "Error desconocido al autenticar."
            }
        }
    }
}

#Preview {
    LoginView()
}
