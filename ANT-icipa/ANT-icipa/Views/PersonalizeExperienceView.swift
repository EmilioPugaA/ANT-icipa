import SwiftUI

struct PersonalizeExperienceView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var goalName: String = "Ahorro Intercambio 2026"
    @State private var goalAmount: String = "25,000 MXN"
    @State private var investmentPercentage: String = "20%"
    @State private var monthlyLimit: String = "900 MXN"
    @State private var disciplineMode: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - STICKY TOP BAR
            HStack(spacing: 16) {
                Spacer()
            }
            .padding(.horizontal, 24)
            .background(BrandColors.secondary)
            .zIndex(1) // always on top
            
            // MARK: - SCROLLABLE CONTENT
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // MARK: - BLUE ISLAND (scrollable)
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
                                
                                Text("Cuenta Destino de\nInversión")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.top, 120)
                        }
                        .padding(.horizontal, 24)
                    }
                    .frame(height: 240)
                    .clipShape(BottomRoundedShape(radius: 25))
                    
                    
                    // MARK: - FORM FIELDS
                    VStack(alignment: .leading, spacing: 32) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Define el monto y nombre de\ntu meta actual:")
                                .font(.system(size: 24))
                                .foregroundColor(Color.gray.opacity(0.7))
                                .padding(.horizontal, 24)
                            
                            EditableField(
                                text: $goalName,
                                textColor: BrandColors.primary
                            )
                            .padding(.horizontal, 24)
                            
                            EditableField(
                                text: $goalAmount,
                                textColor: BrandColors.primary
                            )
                            .padding(.horizontal, 24)
                        }
                        
                        Divider().padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Establece el porcentaje\npara invertir")
                                .font(.system(size: 24))
                                .foregroundColor(Color.gray.opacity(0.7))
                                .padding(.horizontal, 24)
                            
                            EditableField(
                                text: $investmentPercentage,
                                textColor: BrandColors.primary
                            )
                            .padding(.horizontal, 24)
                        }
                        
                        Divider().padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Establece un límite mensual\nde penitencia en tu cuenta")
                                .font(.system(size: 24))
                                .foregroundColor(Color.gray.opacity(0.7))
                                .padding(.horizontal, 24)
                            
                            EditableField(
                                text: $monthlyLimit,
                                textColor: BrandColors.primary
                            )
                            .padding(.horizontal, 24)
                        }
                        
                        Divider().padding(.horizontal, 24)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("¿Deseas activar el modo disciplina?")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 24)
                            
                            Text("Si la penalización doble te dejaria sin fondos para el gasto original, te enviaremos una alerta inmediata para que reconsideres tu compra")
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                                .padding(.horizontal, 24)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            HStack {
                                Spacer()
                                Toggle("", isOn: $disciplineMode)
                                    .labelsHidden()
                                    .tint(BrandColors.primary)
                                    .scaleEffect(1.1)
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                        }
                        
                        Spacer(minLength: 60)
                        
                        Button(action: {}) {
                            Text("Guardar Cambios")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(red: 164/255, green: 51/255, blue: 44/255))
                                .cornerRadius(30)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                    .padding(.top, 48)
                }
            }
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
    }
}

struct EditableField: View {
    @Binding var text: String
    var textColor: Color
    
    var body: some View {
        HStack {
            Spacer()
            
            TextField("", text: $text)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(textColor)
                .multilineTextAlignment(.trailing)
            
            Button(action: {}) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 18))
                    .foregroundColor(textColor)
            }
        }
    }
}

#Preview {
    PersonalizeExperienceView()
}
