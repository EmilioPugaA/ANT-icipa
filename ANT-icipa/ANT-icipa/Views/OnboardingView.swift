import SwiftUI

struct OnboardingView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                
                Spacer().frame(height: 20)
                
                Image("ANTicipaLogoCompleto")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 320, height: 120)
                    .padding(.top, 20)
                
                Image("hormiga")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 190, height: 190)
                    .padding(.top, 10)
                
                VStack(spacing: 10) {
                    Text("Tu asistente inteligente \n para una vida financiera consciente.")
                        .font(.system(size: 22, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(BrandColors.primary)
                        .frame(maxWidth: 320)
                    
                    Text("Convierte cada gasto hormiga en tu \n próxima gran inversión.")
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 10)
                
                // 🔹 Navegación simple al LoginView
                NavigationLink(destination: LoginView()
                    .navigationBarBackButtonHidden(true)
                    .toolbar(.hidden, for: .navigationBar)) {
                    Text("Comenzar")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(BrandColors.primary)
                        .cornerRadius(14)
                        .padding(.horizontal, 40)
                }

                
                Spacer()
            }
            .background(Color.white.ignoresSafeArea())
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    OnboardingView()
}
