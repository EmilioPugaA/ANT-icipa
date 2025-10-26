//
//  OnboardingTutorial.swift
//  ANTicipa
//
//  Created by Atenas Lucia Arita Garcia on 26/10/25.
//

import SwiftUI

struct OnboardingTutorialView: View {
    @State private var name: String = ""
    @State private var goal: String = ""
    @State private var savingFrequency: String = ""
    @State private var monthlyBudget: String = ""
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                
                // Encabezado
                ZStack(alignment: .bottomLeading) {
                    BrandColors.primary
                        .frame(height: 260)
                        .clipShape(BottomRoundedShape(radius: 35))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Convierte cada gasto hormiga")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                        Text("en tu próxima gran inversión.")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
                
                // Sección 1: Qué es ANTicipa
                VStack(alignment: .leading, spacing: 12) {
                    Text("¿Qué es ANTicipa?")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(BrandColors.primary)
                    Text("ANTicipa te ayuda a transformar tus pequeños gastos diarios —tus ‘piquetes’— en oportunidades de ahorro e inversión, personalizadas para tus metas.")
                        .foregroundColor(BrandColors.textPrimary)
                        .font(.system(size: 16))
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(20)
                .padding(.horizontal, 24)
                
                // Sección 2: Tus metas
                VStack(alignment: .leading, spacing: 12) {
                    Text("¿Cuál es tu meta principal?")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(BrandColors.primary)
                    
                    TextField("Ej. Viaje, fondo de emergencia, universidad...", text: $goal)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.top, 4)
                    
                    Text("Tu experiencia se personalizará según lo que quieras alcanzar.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(20)
                .padding(.horizontal, 24)
                
                // Sección 3: Tu frecuencia de ahorro
                VStack(alignment: .leading, spacing: 12) {
                    Text("¿Con qué frecuencia te gustaría ahorrar?")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(BrandColors.primary)
                    
                    Picker("Frecuencia", selection: $savingFrequency) {
                        Text("Diario").tag("Diario")
                        Text("Semanal").tag("Semanal")
                        Text("Mensual").tag("Mensual")
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(20)
                .padding(.horizontal, 24)
                
                // Sección 4: Presupuesto mensual
                VStack(alignment: .leading, spacing: 12) {
                    Text("¿Cuál es tu presupuesto mensual aproximado?")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(BrandColors.primary)
                    
                    TextField("Ej. 10,000 MXN", text: $monthlyBudget)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(20)
                .padding(.horizontal, 24)
                
                // Sección 5: Botón final
                Button(action: {
                    // Acción para guardar datos e ir al Dashboard
                }) {
                    Text("Comenzar mi experiencia")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(BrandColors.primary)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .top)
    }
}

#Preview {
    OnboardingTutorialView()
}
