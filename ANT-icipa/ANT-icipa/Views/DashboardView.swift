//
//  DashboardView.swift
//  ANTicipa
//
//  Creado por Emilio Puga Ascencio el 25/10/25.
//

import SwiftUI

struct DashboardView: View {
    @Environment(\.dismiss) var dismiss
    
    // 🧠 Datos guardados del usuario
    @AppStorage("userId") private var userId: Int = 0
    @AppStorage("username") private var username: String = ""
    
    // 🎯 Meta configurable
    @AppStorage("goalTitle") private var goalTitle: String = "Ahorro Intercambio 2026"
    @AppStorage("goalAmount") private var goalAmount: Double = 25000
    
    @State private var showingEditGoal = false
    @State private var tempTitle = ""
    @State private var tempAmount = ""
    
    // 📊 Totales
    @State private var totalGanado: Double = 0
    @State private var totalPerdido: Double = 0
    @State private var totalInteres: Double = 0
    
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    // 🔢 Cálculo del progreso
    var progress: CGFloat {
        guard goalAmount > 0 else { return 0 }
        return CGFloat(min(totalGanado / goalAmount, 1))
    }
    
    // 🍩 Datos del gráfico
    var dataPie: [(Double, Color)] {
        [
            (totalGanado, Color(red: 198/255, green: 44/255, blue: 44/255)),   // Ahorros
            (totalPerdido, Color(red: 217/255, green: 74/255, blue: 56/255)),  // Piquetes
            (totalInteres, Color(red: 235/255, green: 142/255, blue: 52/255))  // Intereses
        ]
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // MARK: - HEADER
                    ZStack(alignment: .topLeading) {
                        BrandColors.primary
                            .ignoresSafeArea(edges: .top)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 15) {
                                Button(action: { dismiss() }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(BrandColors.secondary)
                                }
                                Text("Progreso de \ntus metas")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, UIApplication.shared.connectedScenes
                                .compactMap { ($0 as? UIWindowScene)?.windows.first?.safeAreaInsets.top }
                                .first ?? 60)
                            
                            Text("Observa como avanza tu progreso, y cómo Piquiete aporta a tus metas")
                                .font(.system(size: 18))
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal, 20)
                        }
                        .padding(.horizontal, 38)
                    }
                    .frame(height: 230)
                    .clipShape(BottomRoundedShape(radius: 25))
                    
                    // MARK: - PROGRESO DE META
                    VStack(spacing: 18) {
                        HStack {
                            Text(goalTitle)
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(BrandColors.primary)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                            
                            Button {
                                tempTitle = goalTitle
                                tempAmount = "\(Int(goalAmount))"
                                showingEditGoal = true
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(BrandColors.primary)
                            }
                        }
                        
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
                        
                        Text("\(Int(totalGanado)) / \(Int(goalAmount)) MXN ahorrados")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(BrandColors.textPrimary)
                            .multilineTextAlignment(.center)
                        
                        Text("\(Int(progress * 100))% completado")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 25)
                    
                    Divider()
                        .padding(.horizontal, 40)
                        .padding(.bottom, 25)
                    
                    // MARK: - GRÁFICO
                    VStack(spacing: 24) {
                        Text("Tu Hormiguero en Resumen")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(BrandColors.primary)
                        
                        if isLoading {
                            ProgressView("Cargando datos...")
                                .padding(.top, 30)
                        } else if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding(.top, 30)
                        } else {
                            PieChartView(slices: dataPie, isDonut: true, hasGap: true)
                                .frame(width: 200, height: 220)
                                .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
                            
                            VStack(spacing: 8) {
                                Text("🟢 \(Int(totalGanado)) generado por tus ahorros")
                                Text("🔴 \(Int(totalPerdido)) generado por los piquetes")
                                Text("🟠 \(Int(totalInteres)) generado por intereses")
                            }
                            .font(.system(size: 15))
                            .foregroundColor(BrandColors.textPrimary)
                            .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                }
            }
            .background(Color.white)
            .navigationBarBackButtonHidden(true)
            .task { await fetchFinancialData() }
            
            // MARK: - MODAL DE META
            if showingEditGoal {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Editar Meta")
                        .font(.title3)
                        .bold()
                        .padding(.top, 10)
                    
                    TextField("Título de la meta", text: $tempTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 20)
                    
                    TextField("Monto objetivo (MXN)", text: $tempAmount)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 20)
                    
                    HStack {
                        Button("Cancelar") {
                            showingEditGoal = false
                        }
                        .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Button("Guardar") {
                            if let newAmount = Double(tempAmount) {
                                goalTitle = tempTitle
                                goalAmount = newAmount
                            }
                            showingEditGoal = false
                        }
                        .bold()
                        .foregroundColor(BrandColors.primary)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 15)
                }
                .frame(width: 320)
                .background(.white)
                .cornerRadius(20)
                .shadow(radius: 15)
                .transition(.scale)
            }
        }
        .ignoresSafeArea(edges: .top) // ✅ asegura que el header azul toque el borde superior
    }
    
    // MARK: - Carga de datos reales
    @MainActor
    func fetchFinancialData() async {
        guard userId > 0 else { return }
        isLoading = true
        errorMessage = nil
        do {
            let response = try await ANTicipaAPIClient.shared.getTransactions(clienteId: userId)
            let trans = response.transactions
            
            totalGanado = trans.filter { $0.is_gasto_hormiga == 0 }.reduce(0) { $0 + $1.montoDouble }
            totalPerdido = trans.filter { $0.is_gasto_hormiga == 1 }.reduce(0) { $0 + $1.montoDouble }
            totalInteres = totalGanado * 0.12 / 12 // estimación simple mensual
            
        } catch {
            errorMessage = "No se pudieron cargar tus transacciones."
            print("❌ Error:", error.localizedDescription)
        }
        isLoading = false
    }
}

#Preview {
    DashboardView()
}
