//
//  GeminiOrchestrator.swift
//  ANTicipa
//
//  Creado por Enmanuel Rivas Barinas el 25/10/25.
//

import Foundation

@MainActor
final class GeminiOrchestrator {
    static let shared = GeminiOrchestrator()
    private let gemini = GeminiService.shared
    private let api = ANTicipaAPIClient.shared
    
    private init() {}
    
    /// Maneja la interacción entre el usuario y Capi 🐜 con contexto financiero real.
    func handleUserQuestion(_ prompt: String, user: UserInfo?) async -> String {
        do {
            // 🧠 Construir contexto completo
            let context = try await buildFullUserContext(user: user, prompt: prompt)
            
            // 🔹 Generar respuesta con Gemini
            let reply = try await gemini.generateResponse(for: context)
            
            // ✅ Si Gemini respondió vacío, devolvemos una respuesta amigable
            if reply.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return """
                Lo siento, no entendí muy bien tu pregunta 🐜.
                ¿Podrías reformularla o darme un poco más de detalle?
                Por ejemplo:
                - “¿Cuánto gasté este mes?”
                - “¿Cómo puedo ahorrar más?”
                """
            }
            
            return reply
            
        } catch {
            // ⚠️ No mostrar errores técnicos, pero mantener coherencia
            #if DEBUG
            print("⚠️ Error en GeminiOrchestrator:", error.localizedDescription)
            #endif
            
            return """
            No logré procesar eso correctamente 🐜, pero aquí estoy para ayudarte.
            Puedes preguntarme cosas como:
            - “¿Cuánto gasté en cafés?”
            - “¿Cómo puedo reducir mis gastos hormiga?”
            - “Muéstrame mi progreso de ahorro”
            """
        }
    }
    
    
    // MARK: - Construcción de contexto con datos reales del API
    private func buildFullUserContext(user: UserInfo?, prompt: String) async throws -> String {
        guard let user = user else {
            return "Usuario no identificado. Pregunta: \(prompt)"
        }
        
        var resumenTransacciones = "No se encontraron transacciones recientes."
        var resumenEstadisticas = "No se encontraron estadísticas de gasto hormiga."
        
        // 🔹 Cargar transacciones recientes
        do {
            let transResponse = try await api.getTransactions(clienteId: user.id_cliente)
            let ultimas = transResponse.transactions.prefix(5)
            if !ultimas.isEmpty {
                resumenTransacciones = ultimas.map { t in
                    let tipo = t.tipo_descripcion ?? "Transacción"
                    let categoria = t.category ?? "Sin categoría"
                    let monto = t.monto
                    let tipoGasto = (t.is_gasto_hormiga == 1) ? "Gasto hormiga" : "Normal"
                    return "- \(tipo) de \(monto) MXN en \(categoria) (\(tipoGasto))"
                }.joined(separator: "\n")
            }
        } catch {
            print("⚠️ No se pudieron cargar transacciones:", error.localizedDescription)
        }
        
        // 🔹 Cargar estadísticas de gasto hormiga (para gráficas o resumen)
        do {
            let stats = try await api.getEstadisticasGastoHormiga(idUsuario: user.id_cliente)
            if !stats.isEmpty {
                let ultimosMeses = stats.prefix(3)
                resumenEstadisticas = ultimosMeses.map { s in
                    "Mes \(s.mes): gasto \(s.gasto_mes) MXN, ahorro \(s.ahorro_mes) MXN, inversión acumulada \(s.inversion_acumulada) MXN."
                }.joined(separator: "\n")
            }
        } catch {
            print("⚠️ No se pudieron cargar estadísticas:", error.localizedDescription)
        }
        
        // 🧩 Contexto final enviado a Gemini
        return """
        Contexto financiero del usuario:
        - Nombre: \(user.nombre_completo)
        - ID Cliente: \(user.id_cliente)
        - Segmento: \(user.segmento_cliente)
        - Balance actual: \(String(format: "%.2f", user.balance ?? 0.0)) MXN
        - Fecha de ingreso al banco: \(user.fecha_ingreso_banco ?? "Desconocida")

        Transacciones recientes:
        \(resumenTransacciones)

        Estadísticas de gasto hormiga:
        \(resumenEstadisticas)

        Pregunta del usuario:
        "\(prompt)"

        Instrucción para Capi:
        Analiza el contexto anterior y responde de forma personalizada, clara y en español.
        Sé breve, amable y empático. Si el usuario pide consejos, ofrece recomendaciones financieras
        simples y útiles basadas en sus datos recientes.
        """
    }
}
