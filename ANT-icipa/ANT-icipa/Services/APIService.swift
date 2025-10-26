import Foundation

struct API {
    static let base = URL(string: "https://ab4ea2519f82.ngrok-free.app")!
}

enum APIError: LocalizedError {
    case badURL
    case invalidResponse
    case http(Int, String?)
    case decoding(String)
    
    var errorDescription: String? {
        switch self {
        case .badURL: return "URL inválida"
        case .invalidResponse: return "Respuesta inválida del servidor"
        case .http(let code, let msg): return msg ?? "Error HTTP \(code)"
        case .decoding(let msg): return "Error decodificando: \(msg)"
        }
    }
}

// MARK: - Modelos base

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let success: Bool
    let message: String
    let user: UserInfo?
}

struct UserInfo: Codable {
    let id_cliente: Int
    let nombre_completo: String
    let email: String
    let numero_cliente: String
    let segmento_cliente: String
    let fecha_ingreso_banco: String?
    let balance: Double? // ✅ agregado
}

struct HealthCheckResponse: Codable {
    let api: String
    let database: String
    let categorizer: String
    let timestamp: String
}

struct AddTransactionRequest: Encodable {
    let id_cliente: Int
    let id_cuenta: Int
    let id_fecha: Int
    let id_tipo_transaccion: Int
    let monto: Double
    let balance_resultante: Double
    let es_credito: Int
    let descripcion_comercio: String?
}

struct TransactionResponse: Codable {
    let success: Bool
    let transaction_id: Int
    let transaction: TransactionDetail
    let categorization: Categorization?
    let suggestions: [String]
}

struct TransactionDetail: Codable {
    let id: Int
    let descripcion: String
    let monto: Double
    let category: String?
    let confidence: Double?
    let is_gasto_hormiga: Int
    let auto_categorized: Int
}

struct Categorization: Codable {
    let category: String
    let confidence: Double
    let reasoning: String
    let isGastoHormiga: Bool
    let suggestions: [String]
}

struct GetTransactionsResponse: Codable {
    let success: Bool
    let count: Int
    let transactions: [TransactionWithCategory]
}

struct TransactionWithCategory: Codable, Identifiable {
    let id_transaccion: Int
    let id_cliente: Int
    let monto: String
    let category: String?
    let is_gasto_hormiga: Int?
    let auto_categorized: Int?
    let suggestions: [String]
    let balance_resultante: String?
    let category_confidence: String?
    let tipo_categoria: String?
    let tipo_descripcion: String?
    let fecha_hora_transaccion: String?   // ✅ agregado
    var id: Int { id_transaccion }

    var montoDouble: Double {
        Double(monto) ?? 0.0
    }
}

struct GastoHormigaEstadistica: Codable, Identifiable {
    let ahorro_mes: String
    let gasto_mes: String
    let inversion_acumulada: Double
    let mes: String

    var id: String { mes }
}




// MARK: - Modelos para historial reciente

struct TransactionSummary: Codable, Identifiable {
    let descripcion: String
    let monto: Double
    let moneda: String
    var id: String { descripcion + "\(monto)" }
}

struct RecientesResponse: Codable {
    let success: Bool
    let items: [TransactionSummary]
}

// MARK: - API Client principal

struct ANTicipaAPIClient {
    static let shared = ANTicipaAPIClient()
    public init() {}
    
    // ---------- Login ----------
    func login(email: String, password: String) async throws -> LoginResponse {
        let url = API.base.appendingPathComponent("/api/auth/login")
        var req = URLRequest(url: url, timeoutInterval: 15)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.httpBody = try JSONEncoder().encode(LoginRequest(email: email, password: password))
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.invalidResponse }
        
        if (200..<300).contains(http.statusCode) {
            do { return try JSONDecoder().decode(LoginResponse.self, from: data) }
            catch { throw APIError.decoding(error.localizedDescription) }
        } else {
            if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let msg = obj["message"] as? String {
                throw APIError.http(http.statusCode, msg)
            }
            throw APIError.http(http.statusCode, nil)
        }
    }
    
    // ---------- Health ----------
    func healthCheck() async throws -> HealthCheckResponse {
        let url = API.base.appendingPathComponent("/health")
        var req = URLRequest(url: url, timeoutInterval: 10)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.http(http.statusCode, nil)
        }
        do { return try JSONDecoder().decode(HealthCheckResponse.self, from: data) }
        catch { throw APIError.decoding(error.localizedDescription) }
    }
    
    // ---------- Transactions ----------
    func addTransaction(_ body: AddTransactionRequest) async throws -> TransactionResponse {
        let url = API.base.appendingPathComponent("/api/transactions")
        var req = URLRequest(url: url, timeoutInterval: 15)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.httpBody = try JSONEncoder().encode(body)
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.invalidResponse }
        
        if (200..<300).contains(http.statusCode) {
            do { return try JSONDecoder().decode(TransactionResponse.self, from: data) }
            catch { throw APIError.decoding(error.localizedDescription) }
        } else {
            if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let msg = obj["error"] as? String {
                throw APIError.http(http.statusCode, msg)
            }
            throw APIError.http(http.statusCode, nil)
        }
    }
    
    func getTransactions(clienteId: Int) async throws -> GetTransactionsResponse {
        let url = API.base.appendingPathComponent("/api/transactions/\(clienteId)")
        var req = URLRequest(url: url, timeoutInterval: 15)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.http(http.statusCode, nil)
        }
        do { return try JSONDecoder().decode(GetTransactionsResponse.self, from: data) }
        catch { throw APIError.decoding(error.localizedDescription) }
    }
    
    // ---------- Historial de gastos recientes ----------
    func getRecentTransactions(clienteId: Int, limit: Int = 4) async throws -> RecientesResponse {
        var urlComponents = URLComponents(url: API.base.appendingPathComponent("/api/transactions/recientes/\(clienteId)"), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        guard let url = urlComponents.url else {
            throw APIError.badURL
        }
        var req = URLRequest(url: url, timeoutInterval: 10)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.http(http.statusCode, nil)
        }
        do { return try JSONDecoder().decode(RecientesResponse.self, from: data) }
        catch { throw APIError.decoding(error.localizedDescription) }
    }
    
    // ---------- Estadísticas de gasto hormiga ----------
    func getEstadisticasGastoHormiga(idUsuario: Int) async throws -> [GastoHormigaEstadistica] {
        var urlComponents = URLComponents(
            url: API.base.appendingPathComponent("/api/estadisticas_gastohormiga"),
            resolvingAgainstBaseURL: false
        )!
        urlComponents.queryItems = [
            URLQueryItem(name: "id_usuario", value: "\(idUsuario)")
        ]
        guard let url = urlComponents.url else {
            throw APIError.badURL
        }

        var req = URLRequest(url: url, timeoutInterval: 10)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.http(http.statusCode, nil)
        }

        do {
            return try JSONDecoder().decode([GastoHormigaEstadistica].self, from: data)
        } catch {
            throw APIError.decoding(error.localizedDescription)
        }
    }

}
