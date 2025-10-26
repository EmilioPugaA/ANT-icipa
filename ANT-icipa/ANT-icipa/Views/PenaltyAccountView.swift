//
//  PenaltyAccountView.swift
//  ANTicipa
//
//  Created by Atenas Lucia Arita Garcia on 25/10/25.
//

import SwiftUI

struct PenaltyAccountView: View {
    @Environment(\.dismiss) var dismiss
    
    struct BankAccount: Identifiable {
        let id = UUID()
        let icon: String
        let accountNumber: String
        let iconColor: Color
        let isSystemImage: Bool
    }
    
    @State private var selectedAccountId: UUID?
    
    let accounts = [
        BankAccount(icon: "creditcard", accountNumber: "**** 0982", iconColor: .green, isSystemImage: true),
        BankAccount(icon: "creditcard", accountNumber: "**** 2307", iconColor: .black, isSystemImage: true),
        BankAccount(icon: "dollarsign.circle", accountNumber: "**** 3995", iconColor: .orange, isSystemImage: true)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - ENCABEZADO
            ZStack(alignment: .topLeading) {
                BrandColors.primary
                    .ignoresSafeArea(edges: .top)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 16) {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(BrandColors.secondary)
                        }
                        
                        Text("Cuenta Origen de\nPenalización")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 100)
                }
                .padding(.horizontal, 24)
            }
            .frame(height: 240)
            .clipShape(BottomRoundedShape(radius: 25)) // Only round bottom corners
            
            
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - TUS CUENTAS
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tus cuentas")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(red: 0/255, green: 68/255, blue: 137/255))
                            .padding(.horizontal, 32)
                            .padding(.top, 50)
                        
                        Image("logo-Capital-one")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                            .padding(.horizontal, 32)
                    }
                    
                    // MARK: - DESCRIPCIÓN
                    Text("Selecciona la cuenta de la que\nsaldrán tus montos de inversiones")
                        .font(.system(size: 17))
                        .foregroundColor(Color.gray.opacity(0.85))
                        .padding(.horizontal, 32)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // MARK: - CONTENIDO SCROLLABLE
                    ScrollView(.vertical, showsIndicators: false) {
                        // MARK: - LISTA DE CUENTAS
                        VStack(spacing: 0) {
                            ForEach(accounts) { account in
                                AccountRow(
                                    account: account,
                                    isSelected: selectedAccountId == account.id,
                                    action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedAccountId = account.id
                                        }
                                    }
                                )
                                
                                if account.id != accounts.last?.id {
                                    Divider()
                                        .padding(.leading, 90)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // MARK: - BOTÓN GUARDAR
                    Button(action: {
                        // Acción para guardar cambios
                    }) {
                        Text("Guardar Cambios")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(BrandColors.secondary)
                            .cornerRadius(30)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 30)
                }
            }
        .background(Color.white)
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if accounts.count > 1 {
                selectedAccountId = accounts[1].id
            }
        }
    }
}

// MARK: - FILA DE CUENTA
struct AccountRow: View {
    let account: PenaltyAccountView.BankAccount
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                // Icono de cuenta
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(account.iconColor, lineWidth: 2)
                        .frame(width: 50, height: 35)
                    
                    Image(systemName: account.icon)
                        .font(.system(size: 20))
                        .foregroundColor(account.iconColor)
                }
                
                // Número de cuenta
                Text(account.accountNumber)
                    .font(.system(size: 18))
                    .foregroundColor(Color.gray.opacity(0.7))
                
                Spacer()
                
                // Checkmark si está seleccionada
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(red: 0/255, green: 68/255, blue: 137/255))
                }
            }
            .padding(.vertical, 20)
        }
    }
}

#Preview {
    PenaltyAccountView()
}
