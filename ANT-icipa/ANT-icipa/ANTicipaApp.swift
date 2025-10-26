//
//  ANTicipaApp.swift
//  ANTicipa
//
//  Creado por Enmanuel Rivas Barinas el 25/10/25.
//

import SwiftUI

@main
struct ANT_icipaApp: App {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("username") var username: String = ""
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                ContentView(username: username)
                    .transition(.opacity)
            } else {
                NavigationStack {
                    OnboardingView()
                }
                .transition(.opacity)
            }
        }
    }
}
