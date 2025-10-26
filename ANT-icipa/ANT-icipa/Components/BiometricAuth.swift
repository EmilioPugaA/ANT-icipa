//
//  BiometricAuth.swift
//  ANTicipa
//
//  Created by Enmanuel Rivas Barinas on 10/25/25.
//

import LocalAuthentication
import SwiftUI

class BiometricAuth {
    static let shared = BiometricAuth()
    
    private init() {}
    
    func authenticateUser(completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        // Verificar si el dispositivo soporta biométricos
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Confirma tu identidad para acceder a ANTicipa."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    if success {
                        completion(true, nil)
                    } else {
                        completion(false, authError?.localizedDescription)
                    }
                }
            }
        } else {
            completion(false, "Biometría no disponible en este dispositivo.")
        }
    }
}
