//
//  DashboardView.swift
//  ANTicipa
//
//  Creado por Emilio Puga Ascencio el 25/10/25.
//

import SwiftUI

struct DashboardView: View {
    @Environment(\.dismiss) var dismiss
    @State private var progress: CGFloat = 0.66
    
    // 🎨 Tonos rojos y cálidos para el gráfico
    let dataPie: [(Double, Color)] = [
        (11_032, Color(red: 198/255, green: 44/255, blue: 44/255)),   // rojo principal
        (5_459, Color(red: 217/255, green: 74/255, blue: 56/255)),    // rojo-naranja
        (2_234, Color(red: 235/255, green: 142/255, blue: 52/255))    // naranja acento
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    ZStack(alignment: .topLeading) {
                        BrandColors.primary
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 15) {
                                Button(action: {
                                    dismiss()
                                }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(BrandColors.secondary)
                                }
                                Text("Progreso de \ntus metas")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 30)

                            Text("Observa como avanza tu progreso, y \n como piquiete aporta a tus metas")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                        }
                        .padding(.horizontal, 38)
                    }
                    .frame(height: 230)
                    .clipShape(BottomRoundedShape(radius: 25))
                    
                    VStack(spacing: 18) {
                        Text("Ahorro Intercambio 2026")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(BrandColors.primary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 22)
                            
                            RoundedRectangle(cornerRadius: 20)
                                .fill(BrandColors.primary)
                                .frame(width: CGFloat(progress) * UIScreen.main.bounds.width * 0.8, height: 22)
                                .animation(.easeInOut(duration: 1.2), value: progress)
                        }
                        .padding(.horizontal, 40)
                        
                        VStack(spacing: 6) {
                            Text("16,452 / 25,000 MXN ahorrados")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(BrandColors.textPrimary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 25)
                    
                    Divider()
                        .padding(.horizontal, 40)
                        .padding(.bottom, 25)
                    
                    // 🍩 GRÁFICO CIRCULAR
                    VStack(spacing: 24) {
                        Text("Tu Hormiguero en Resumen")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(BrandColors.primary)
                        
                        PieChartView(slices: dataPie, isDonut: true, hasGap: true)
                            .frame(width: 200, height: 220)
                            .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
                        
                        VStack(spacing: 8) {
                            Text("11,032 generado por tus ahorros")
                            Text("5,459 generado por los piquetes")
                            Text("2,234 generado por intereses")
                        }
                        .font(.system(size: 15))
                        .foregroundColor(BrandColors.textPrimary)
                        .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                }
            }
            .background(Color.white)
            .navigationBarBackButtonHidden(true)

            
            VStack {
                BrandColors.primary
                    .frame(height: 70)
                    .ignoresSafeArea(edges: .top)
                    .overlay(
                        HStack {
                        
                        }
                    )
            }
        }
    }
}

#Preview {
    DashboardView()
}
