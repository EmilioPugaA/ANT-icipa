//
//  NotificationView.swift
//  ANTicipa
//
//  Creado por Enmanuel Rivas Barinas el 25/10/25.
//

import SwiftUI

struct NotificationView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("username") var username: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - HEADER AZUL
            ZStack(alignment: .topLeading) {
                BrandColors.primary
                    .ignoresSafeArea(edges: .top)
                
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 12) {
                        // 🔙 Botón de regreso
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        Image(systemName: "bell.badge.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(.white)
                            .font(.system(size: 26, weight: .bold))
                        
                        Text("Notificaciones")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.top, 60)
                    
                    Text("Revisa tus alertas y logros recientes.\nMantente al tanto de tu progreso financiero.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 36)
                }
                .padding(.horizontal, 24)
            }
            .frame(height: 230)
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
            .shadow(color: .black.opacity(0.15), radius: 6, y: 4)
            
            // MARK: - CONTENIDO
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    NotificationCard(
                        title: "¡Piquete!",
                        message: "Se detectó un gasto hormiga de $150 en Starbucks. Hemos transferido $75 a tu fondo de inversión.",
                        color: BrandColors.secondary,
                        icon: "ant.fill",
                        background: Color(red: 239/255, green: 243/255, blue: 255/255)
                    )
                    
                    NotificationCard(
                        title: "¡Buena disciplina!",
                        message: "No se detectaron gastos hormiga en la última semana. Tu fondo sigue creciendo.",
                        color: Color(red: 0/255, green: 68/255, blue: 137/255),
                        icon: "checkmark.seal.fill",
                        background: Color(red: 236/255, green: 243/255, blue: 255/255)
                    )
                    
                    NotificationCard(
                        title: "Protección de saldo doble",
                        message: "La compra en Uber de $250 requiere su aprobación. Toca para aprobar o rechazar.",
                        color: Color(red: 139/255, green: 46/255, blue: 36/255),
                        icon: "shield.lefthalf.fill",
                        background: Color(red: 245/255, green: 240/255, blue: 240/255)
                    )
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 18)
            }
            .background(Color.white)
        }
        .background(Color.white)
        .ignoresSafeArea() // ✅ cubre toda la pantalla
        .navigationBarHidden(true)
    }
}



// MARK: - TARJETA DE NOTIFICACIÓN
struct NotificationCard: View {
    var title: String
    var message: String
    var color: Color
    var icon: String
    var background: Color
    
    @State private var pressed = false
    @State private var appear = false
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                pressed.toggle()
            }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 38, height: 38)
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 18, weight: .semibold))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(color)
                    
                    Text(message)
                        .font(.system(size: 15))
                        .foregroundColor(.black.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(background)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.06), radius: 3, y: 2)
            .scaleEffect(pressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: pressed)
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 10)
            .animation(.easeOut(duration: 0.35), value: appear)
            .onAppear { appear = true }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NotificationView()
}
