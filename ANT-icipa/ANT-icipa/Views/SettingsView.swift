//
//  ConfigurationView.swift
//  ANTicipa
//
//  Creado por Atenas Arita
//
import SwiftUI

struct SettingsView: View {
    
    @State private var notificationsEnabled: Bool = true
    @AppStorage("biometricsEnabled") private var biometricsEnabled: Bool = false
    
    @State private var goToPentaly = false
    @State private var goToInversion = false
    @State private var goToExperience = false

    // 🔹 Variables globales de sesión
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @AppStorage("username") private var username: String = ""
    @AppStorage("userId") private var userId: Int = 0
    @AppStorage("userBalance") private var userBalance: Double = 0.0
    
    // 🔹 Estado para confirmar cierre
    @State private var showLogoutConfirmation = false

    var body: some View {
        ZStack(alignment: .top) {
            
            // MARK: - MAIN SCROLL CONTENT
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // MARK: - ENCABEZADO (starts below the fixed bar)
                    ZStack(alignment: .topLeading) {
                        BrandColors.primary
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Configuración")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.top, 80)
                        }
                        .padding(.horizontal, 24)
                    }
                    .frame(height: 160)
                    .clipShape(BottomRoundedShape(radius: 25))
                    .padding(.top, 30)
                    
                    
                    
                    
                    // MARK: - REST OF CONTENT
                    VStack(alignment: .leading, spacing: 24)  {
                        // MARK: - USUARIO
                        HStack(spacing: 16) {
                            Circle()
                                .fill(Color.red.opacity(0.07))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(BrandColors.secondary)
                                )
                            
                            Text(username.isEmpty ? "Atenas Arita" : username)
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(BrandColors.secondary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 40)
                        
                        // MARK: - GESTIÓN
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Gestión")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(BrandColors.primary)
                                .padding(.horizontal, 24)
                                .padding(.bottom, 12)
                            
                            ConfigMenuItem(
                                title: "Cuenta de Origen de Penalización",
                                action: {goToPentaly = true}
                            )
                            
                            ConfigMenuItem(
                                title: "Cuenta de Destino de Inversiones",
                                action: {goToInversion = true}
                            )
                            
                            ConfigMenuItem(
                                title: "Personaliza tus experiencia",
                                action: {goToExperience = true}
                            )
                        }
                        
                        // MARK: - EXPERIENCIA
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Experiencia")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(BrandColors.primary)
                                .padding(.horizontal, 24)
                                .padding(.bottom, 12)
                            
                            ConfigToggleItem(
                                title: "Notificaciones",
                                isOn: $notificationsEnabled
                            )
                            
                            ConfigDeleteItem(
                                title: "Historial del ChatBot",
                                action: {}
                            )
                        }
                        
                        // MARK: - SEGURIDAD
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Seguridad")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(BrandColors.primary)
                                .padding(.horizontal, 24)
                                .padding(.bottom, 12)
                            
                            ConfigToggleItem(
                                title: "Uso de Biométricos",
                                isOn: $biometricsEnabled
                            )
                            
                            ConfigMenuItem(
                                title: "Términos y Condiciones",
                                action: {}
                            )
                        }
                        
                        // MARK: - BOTÓN CERRAR SESIÓN
                        Button(action: {
                            showLogoutConfirmation = true
                        }) {
                            Text("Cierre de Sesión")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(BrandColors.secondary)
                                .cornerRadius(30)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 60)
                        .alert("¿Deseas cerrar sesión?", isPresented: $showLogoutConfirmation) {
                            Button("Cancelar", role: .cancel) {}
                            Button("Cerrar sesión", role: .destructive) {
                                logout()
                            }
                        } message: {
                            Text("Tu sesión actual se cerrará y volverás a la pantalla de inicio.")
                        }
                    }
                }
            }
            .background(Color.white)
            
            // MARK: ✅ FIXED BLUE BAR (Always visible)
            VStack {
                BrandColors.primary
                    .frame(height: 70)
                    .ignoresSafeArea(edges: .top)
                    .overlay(
                        HStack {
                            Spacer()
                            Spacer()
                        }
                    )
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationDestination(isPresented: $goToPentaly) {
            PenaltyAccountView()
        }
        .navigationDestination(isPresented: $goToInversion) {
            InversionAccountView()
        }
        .navigationDestination(isPresented: $goToExperience) {
            PersonalizeExperienceView()
        }
    }
    
    // MARK: - 🔐 CIERRE DE SESIÓN
    private func logout() {
        username = ""
        userId = 0
        userBalance = 0.0
        isLoggedIn = false
        
        // Limpieza de datos locales
        UserDefaults.standard.removeObject(forKey: "savedPassword")
        
        // Animación visual suave
        withAnimation(.easeInOut(duration: 0.5)) {
            isLoggedIn = false
        }
        
        print("🚪 Sesión cerrada correctamente")
    }
}




// MARK: - ITEM DE MENÚ CON FLECHA
struct ConfigMenuItem: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 17))
                    .foregroundColor(Color.gray.opacity(0.85))
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(BrandColors.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        
        Divider()
            .padding(.leading, 24)
    }
}

// MARK: - ITEM DE MENÚ CON TOGGLE
struct ConfigToggleItem: View {
    var title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 17))
                .foregroundColor(Color.gray.opacity(0.85))
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color(red: 0/255, green: 68/255, blue: 137/255))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        
        Divider()
            .padding(.leading, 24)
    }
}

// MARK: - ITEM DE MENÚ CON ÍCONO DE ELIMINAR
struct ConfigDeleteItem: View {
    var title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 17))
                    .foregroundColor(Color.gray.opacity(0.85))
                
                Spacer()
                
                Image(systemName: "trash.fill")
                    .font(.system(size: 18))
                    .foregroundColor(BrandColors.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        
        Divider()
            .padding(.leading, 24)
    }
}

struct BottomRoundedShape: Shape {
    var radius: CGFloat = 25.0
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
#Preview {
    SettingsView()
}
