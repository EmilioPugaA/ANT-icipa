//
//  HistorialCompletoView.swift
//  ANTicipa
//
//  Creado por Enmanuel Rivas Barinas el 25/10/25.
//

import SwiftUI

struct HistorialCompletoView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("userId") var userId: Int = 0
    
    @State private var transactions: [TransactionWithCategory] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - HEADER AZUL
            ZStack {
                BrandColors.primary
                    .ignoresSafeArea(edges: .top)
                
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.leading, 16)
                    }
                    
                    Spacer()
                    
                    Text("Historial completo")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.left")
                        .opacity(0)
                        .padding(.trailing, 16)
                }
                .padding(.top, 55)
                .padding(.bottom, 15)
            }
            .frame(height: 100)
            
            // MARK: - LISTA
            ScrollView(.vertical, showsIndicators: false) {
                if isLoading {
                    ProgressView("Cargando todas tus transacciones...")
                        .padding(.top, 40)
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.system(size: 15))
                        .padding(.top, 40)
                } else if transactions.isEmpty {
                    Text("No se encontraron transacciones registradas.")
                        .foregroundColor(.gray)
                        .font(.system(size: 15))
                        .padding(.top, 40)
                } else {
                    VStack(spacing: 12) {
                        ForEach(transactions) { t in
                            TransactionCard(transaction: t)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.white)
        }
        .background(Color.white)
        .ignoresSafeArea() // ✅ cubre todo
        .navigationBarBackButtonHidden(true)
        .task {
            await fetchAllTransactions()
        }
    }
    
    // MARK: - Cargar desde API
    func fetchAllTransactions() async {
        guard userId > 0 else {
            errorMessage = "No se encontró el ID del usuario."
            isLoading = false
            return
        }
        
        do {
            let response = try await ANTicipaAPIClient.shared.getTransactions(clienteId: userId)
            transactions = response.transactions.sorted(by: { $0.id_transaccion > $1.id_transaccion })
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? "Error al cargar las transacciones."
        }
        
        isLoading = false
    }
}

#Preview {
    HistorialCompletoView()
}
