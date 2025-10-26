import SwiftUI

struct ContentView: View {
    var username: String

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(username: username)
                    .navigationBarBackButtonHidden(true)
            }
            .tabItem { Label("Inicio", systemImage: "house.fill") }

            NavigationStack {
                InvestView()
                    .navigationBarBackButtonHidden(true)
            }
            .tabItem { Label("Invertir", systemImage: "chart.line.uptrend.xyaxis") }

            NavigationStack {
                SettingsView()
                    .navigationBarBackButtonHidden(true)
            }
            .tabItem { Label("Ajustes", systemImage: "gearshape.fill") }
        }
        .accentColor(BrandColors.primary)
    }
}
