//
//  GeminiService.swift
//  ANTicipa
//
//  Creado por Enmanuel Rivas Barinas el 25/10/25.
//

import Foundation

class GeminiService {
    static let shared = GeminiService()
    private init() {}

    // MARK: - API Key
    private let apiKey: String = {
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let key = dict["API_KEY"] as? String {
            return key
        } else {
            fatalError("❌ No se encontró 'API_KEY' en Secrets.plist")
        }
    }()

    // MARK: - Conversación
    private var conversationHistory: [Message] = []
    private let historyKey = "CapiConversationHistory"

    init(loadSavedHistory: Bool = true) {
        if loadSavedHistory { loadConversationHistory() }
    }

    // MARK: - Generar respuesta
    func generateResponse(for prompt: String) async throws -> String {
        // Agregar mensaje del usuario
        conversationHistory.append(Message(role: "user", text: prompt))

        // Formato esperado por Gemini (solo roles user/model)
        var contents: [[String: Any]] = [
            [
                "role": "user",
                "parts": [
                    ["text": "Eres Capi 🐜, un asistente financiero amable que ayuda a los usuarios a entender sus gastos hormiga e inversiones. Responde siempre en español y recuerda el contexto de la conversación."]
                ]
            ]
        ]

        // Agrega historial de conversación
        for msg in conversationHistory {
            contents.append([
                "role": msg.role == "system" ? "user" : msg.role, // evita 'system'
                "parts": [["text": msg.text]]
            ])
        }

        // Cuerpo del request actualizado
        let requestBody: [String: Any] = [
            "contents": contents,
            "generationConfig": [
                "temperature": 0.8,
                "maxOutputTokens": 512
            ],
            "safetySettings": [
                ["category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_NONE"],
                ["category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_NONE"],
                ["category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_NONE"],
                ["category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_NONE"]
            ]
        ]

        // Endpoint actualizado para Gemini 2.5 Flash
        guard let url = URL(string:
            "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=\(apiKey)"
        ) else {
            throw URLError(.badURL)
        }

        // Configurar request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])

        // Llamada a la API
        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("🌐 Gemini status:", httpResponse.statusCode)
        }

        // Decodificar respuesta
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "GeminiError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No se pudo decodificar JSON"])
        }

        // Ver salida para depuración
        print("🧩 Gemini raw response:", json)

        if let candidates = json["candidates"] as? [[String: Any]],
           let content = candidates.first?["content"] as? [String: Any],
           let parts = content["parts"] as? [[String: Any]],
           let text = parts.first?["text"] as? String {

            let reply = text.trimmingCharacters(in: .whitespacesAndNewlines)
            conversationHistory.append(Message(role: "model", text: reply))
            saveConversationHistory()
            return reply
        } else {
            let errorMsg = (json["error"] as? [String: Any])?["message"] as? String ?? "Respuesta no válida del modelo."
            print("⚠️ Error Gemini:", errorMsg)
            throw NSError(domain: "GeminiError", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
    }

    // MARK: - Guardar / Cargar historial
    private func saveConversationHistory() {
        if let data = try? JSONEncoder().encode(conversationHistory) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }

    private func loadConversationHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let saved = try? JSONDecoder().decode([Message].self, from: data) {
            conversationHistory = saved
        }
    }

    func clearConversationHistory() {
        conversationHistory.removeAll()
        UserDefaults.standard.removeObject(forKey: historyKey)
    }
}
