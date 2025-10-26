//
//  InvestView.swift
//  ANTicipa
//
//  Creado por Enmanuel Rivas Barinas el 25/10/25.
//

import SwiftUI
import Charts

struct InvestView: View {
    
    // MARK: - Estado general
    @AppStorage("userId") private var userId: Int = 0
    
    @State private var estadisticas: [GastoHormigaEstadistica] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    @State private var selectedRange = "1 año"
    
    let rangoOpciones = ["3 meses", "6 meses", "1 año"]
    
    // MARK: - Datos filtrados según rango
    var datosActuales: [GastoHormigaEstadistica] {
        switch selectedRange {
        case "3 meses":
            return Array(estadisticas.suffix(3))
        case "6 meses":
            return Array(estadisticas.suffix(6))
        default:
            return estadisticas
        }
    }
    
    // MARK: - Cálculos dinámicos
    var gastoTotal: Double {
        datosActuales.reduce(0) { $0 + (Double($1.gasto_mes) ?? 0.0) }
    }
    
    var inversionTotal: Double {
        datosActuales.last?.inversion_acumulada ?? 0.0
    }
    
    // MARK: - Body principal
    var body: some View {
        ZStack(alignment: .top) {
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // MARK: - ENCABEZADO
                    ZStack(alignment: .topLeading) {
                        BrandColors.primary
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Mi Hormiguero Capital")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.top, 60)
                            
                            Text("Mira cómo tus pequeños ahorros crecen mes a mes 🐜")
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.trailing, 40)
                        }
                        .padding(.horizontal, 24)
                    }
                    .frame(height: 160)
                    .clipShape(BottomRoundedShape(radius: 25))
                    .padding(.top, 30)
                    
                    // MARK: - CONTENIDO PRINCIPAL
                    if isLoading {
                        ProgressView("Cargando tus estadísticas...")
                            .padding(.top, 100)
                            .foregroundColor(.gray)
                    } else if let errorMessage = errorMessage {
                        VStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.system(size: 36))
                            Text("Error al cargar datos")
                                .font(.headline)
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 120)
                    } else {
                        VStack(spacing: 28) {
                            
                            // 🗓 Selector de rango
                            HStack {
                                Text("Historial")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(BrandColors.textPrimary)
                                
                                Spacer()
                                
                                Menu {
                                    ForEach(rangoOpciones, id: \.self) { opcion in
                                        Button(opcion) { selectedRange = opcion }
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text(selectedRange)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(BrandColors.secondary)
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(BrandColors.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal, 26)
                            .padding(.top, 10)
                            
                            // 🧾 Texto dinámico de gasto
                            Text("Has gastado $\(Int(gastoTotal)) en gastos hormiga.")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 26)
                                .animation(.easeInOut, value: gastoTotal)
                            
                            // 📊 Gráfica de barras: Gastos por mes
                            Chart {
                                ForEach(datosActuales) { mes in
                                    let gasto = Double(mes.gasto_mes) ?? 0.0
                                    let label = "$\(Int(gasto))"
                                    BarMark(
                                        x: .value("Mes", String(mes.mes.prefix(3))),

                                        y: .value("Gasto", gasto)
                                    )
                                    .foregroundStyle(Color(red: 222/255, green: 118/255, blue: 54/255))
                                    .cornerRadius(6)
                                    .annotation(position: .top) {
                                        Text(label)
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .frame(height: 200)
                            .padding(.horizontal, 22)
                            .animation(.spring(), value: selectedRange)

                            
                            // 📈 Texto intermedio
                            Text("Tus inversiones acumuladas a lo largo del tiempo")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 50)
                            
                            // 📈 Gráfica de línea: Inversión acumulada
                            Chart(datosActuales) { mes in
                                LineMark(
                                    x: .value("Mes", String(mes.mes.prefix(3))),

                                    y: .value("Inversión acumulada", mes.inversion_acumulada)
                                )
                                .symbol(Circle())
                                .lineStyle(StrokeStyle(lineWidth: 3))
                                .foregroundStyle(Color(red: 222/255, green: 118/255, blue: 54/255))
                                .interpolationMethod(.catmullRom)
                            }
                            .frame(height: 160)
                            .padding(.horizontal, 22)
                            .animation(.easeInOut(duration: 0.4), value: selectedRange)
                            
                            // 💬 Resumen final
                            Text("Tu inversión total acumulada es de $\(Int(inversionTotal))")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(BrandColors.textPrimary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 60)
                                .padding(.top, 5)
                        }
                        .padding(.bottom, 50)
                    }
                }
            }
            
            // ✅ Barra fija superior
            VStack {
                BrandColors.primary
                    .frame(height: 70)
                    .ignoresSafeArea(edges: .top)
            }
        }
        .task {
            await fetchData()
        }
        .ignoresSafeArea(edges: .top)
    }
    
    // MARK: - Llamada API
    private func fetchData() async {
        guard userId != 0 else {
            DispatchQueue.main.async {
                self.errorMessage = "No hay usuario en sesión."
                self.isLoading = false
            }
            return
        }
        
        do {
            let data = try await ANTicipaAPIClient.shared.getEstadisticasGastoHormiga(idUsuario: userId)
            DispatchQueue.main.async {
                self.estadisticas = data
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

#Preview {
    InvestView()
}
