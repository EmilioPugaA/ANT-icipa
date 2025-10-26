//
//  HomeView.swift
//  ANTicipa
//
//  Creado por Enmanuel Rivas Barinas el 25/10/25.
//

import SwiftUI

struct HomeView: View {
    @AppStorage("username") var username: String = ""
    @AppStorage("userId") var userId: Int = 0
    @AppStorage("userBalance") var userBalance: Double = 0.0
    
    @State private var goToExperience = false
    @State private var goToCard = false
    @State private var goToProfile = false

    
    @State private var totalBalance: Double = 0.0
    @State private var expensesCount: Int = 8
    @State private var hideBalance: Bool = false
    @State private var goToNotifications = false
    
    enum AntRole {
        case normal, carrier, explorer
    }
    
    struct Ant {
        var position: CGPoint
        var direction: CGVector
        var speed: CGFloat
        var angle: Double
        var isPaused: Bool
        var pauseTimer: Double
        var wanderFactor: CGFloat
        var role: AntRole
    }
    
    @State private var ants: [Ant] = []
    
    // --- Propiedades del área de animación
    let areaSize: CGFloat = 340
    let donutRadius: CGFloat = 110
    let innerRadius: CGFloat = 55
    var donutCenter: CGPoint { CGPoint(x: 170, y: 170) }
    
    let infestationColor = Color(red: 139/255, green: 46/255, blue: 36/255)
    
    var body: some View {
        ZStack(alignment: .top) {
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // MARK: - ENCABEZADO
                    ZStack(alignment: .topLeading) {
                        BrandColors.primary
                            .ignoresSafeArea(edges: .top)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            
                            // TOP RIGHT ICONS
                            HStack {
                                Spacer()
                                HStack(spacing: 16) {
                                    Button {
                                        withAnimation(.easeInOut) { hideBalance.toggle() }
                                    } label: {
                                        Image(systemName: hideBalance ? "eye.fill" : "eye.slash.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.white)
                                    }
                                    
                                    Button {
                                        goToNotifications = true
                                    } label: {
                                        Image(systemName: "bell.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding(.top, 70)
                            .padding(.trailing, 24)
                            
                            // GREETING + BALANCE
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Hola, \(hideBalance ? "••••••••" : (username.isEmpty ? "Cliente Puga" : username))!")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("Bienvenida, empecemos a invertir")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.85))
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Balance Total")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.9))
                                    
                                    Text(hideBalance ? "••••••" : "$" + userBalance.formatted(.number.precision(.fractionLength(2)).grouping(.automatic)))
                                        .font(.system(size: 32, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text("Actualizado hace unos segundos")
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 16)
                        }
                    }
                    .frame(height: 320)
                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                    
                    // MARK: - NIVEL DE INFESTACIÓN
                    Text("Nivel de Infestación Hormiga")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(infestationColor)
                        .padding(.top, 30)
                    
                    // MARK: - DONA Y HORMIGAS
                    ZStack {
                        Image("Dona")
                            .resizable()
                            .scaledToFit()
                            .frame(width: areaSize, height: areaSize)
                            .shadow(radius: 5)
                            .clipped()
                        
                        ForEach(0..<ants.count, id: \.self) { i in
                            Image("hormiga")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .rotationEffect(.degrees(ants[i].angle))
                                .position(ants[i].position)
                                .opacity(ants[i].isPaused ? 0.85 : 1.0)
                                .animation(.linear(duration: 0.1), value: ants[i].position)
                        }
                    }
                    .frame(width: areaSize + 40, height: areaSize)
                    .onAppear {
                        inicializarHormigas()
                        moverHormigasConRoles()
                        Task { await fetchBalance() }
                    }
                    
                    // MARK: - BOTONES INFERIORES
                    HStack(alignment: .top, spacing: 25) {
                        Button {
                            goToExperience = true
                        } label: {
                            MiniAction(icon: "lightbulb", text: "Personaliza \ntu experiencia")
                        }
                        .buttonStyle(.plain)

                        Button {
                            goToCard = true
                        } label: {
                            MiniAction(icon: "creditcard", text: "Cambiar\ntarjeta de fondos")
                        }
                        .buttonStyle(.plain)

                        Button {
                            goToProfile = true
                        } label: {
                            MiniAction(icon: "leaf.arrow.triangle.circlepath", text: "Define y \n alcanza tus metas")
                        }
                        .buttonStyle(.plain)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 30)

                    .multilineTextAlignment(.center)
                    .padding(.bottom, 30)
                    
                    CapiSection(
                        infestationColor: infestationColor,
                        userId: userId,
                        username: username,
                        userBalance: userBalance
                    )

                    // MARK: - HISTORIAL DE GASTOS
                    HistorialGastosSection(infestationColor: infestationColor)
                    
                    Spacer(minLength: 40)
                }
                // ✅ PULL TO REFRESH REAL
                .refreshable {
                    await refreshHomeData()
                }
            }
            .background(Color.white)
            .ignoresSafeArea(edges: .top)
            .navigationDestination(isPresented: $goToExperience) {
                PersonalizeExperienceView()
            }
            .navigationDestination(isPresented: $goToCard) {
                PenaltyAccountView()
            }
            .navigationDestination(isPresented: $goToProfile) {
                DashboardView()
            }

            
            VStack {
                BrandColors.primary
                    .frame(height: 70)
                    .ignoresSafeArea(edges: .top)
                    .overlay(
                        HStack {
                        
                        }
                    )
            }
        }
    }
    
    // MARK: - Inicialización de hormigas
    func inicializarHormigas() {
        ants = (0..<expensesCount).map { _ in
            let angle = Double.random(in: 0...(2 * .pi))
            let radius = CGFloat.random(in: innerRadius...donutRadius)
            let x = donutCenter.x + cos(angle) * radius
            let y = donutCenter.y + sin(angle) * radius
            
            let dirAngle = Double.random(in: 0...(2 * .pi))
            let dx = CGFloat(cos(dirAngle))
            let dy = CGFloat(sin(dirAngle))
            
            let role: AntRole
            switch Int.random(in: 1...10) {
            case 1: role = .explorer
            case 2, 3: role = .carrier
            default: role = .normal
            }
            
            let baseSpeed: CGFloat
            let wander: CGFloat
            
            switch role {
            case .normal:
                baseSpeed = CGFloat.random(in: 0.13...0.22)
                wander = CGFloat.random(in: 0.01...0.025)
            case .carrier:
                baseSpeed = CGFloat.random(in: 0.08...0.15)
                wander = CGFloat.random(in: 0.008...0.018)
            case .explorer:
                baseSpeed = CGFloat.random(in: 0.20...0.35)
                wander = CGFloat.random(in: 0.02...0.04)
            }
            
            return Ant(
                position: CGPoint(x: x, y: y),
                direction: CGVector(dx: dx, dy: dy),
                speed: baseSpeed,
                angle: dirAngle * 180 / .pi,
                isPaused: false,
                pauseTimer: Double.random(in: 2...6),
                wanderFactor: wander,
                role: role
            )
        }
    }
    
    // MARK: - Movimiento de hormigas
    func moverHormigasConRoles() {
        Timer.scheduledTimer(withTimeInterval: 0.033, repeats: true) { _ in
            for i in ants.indices {
                var ant = ants[i]
                
                if ant.isPaused {
                    ant.pauseTimer -= 0.033
                    if ant.pauseTimer <= 0 {
                        ant.isPaused = false
                        ant.pauseTimer = Double.random(in: 2...6)
                    }
                } else {
                    let variableSpeed = ant.speed * CGFloat.random(in: 0.9...1.1)
                    ant.position.x += ant.direction.dx * variableSpeed * 2
                    ant.position.y += ant.direction.dy * variableSpeed * 2
                    
                    let dxCenter = donutCenter.x - ant.position.x
                    let dyCenter = donutCenter.y - ant.position.y
                    let distance = sqrt(dxCenter * dxCenter + dyCenter * dyCenter)
                    
                    if distance > donutRadius {
                        ant.direction.dx += dxCenter * 0.0003
                        ant.direction.dy += dyCenter * 0.0003
                    } else if distance < innerRadius {
                        ant.direction.dx -= dxCenter * 0.0002
                        ant.direction.dy -= dyCenter * 0.0002
                    }
                    
                    ant.direction.dx += CGFloat.random(in: -ant.wanderFactor...ant.wanderFactor)
                    ant.direction.dy += CGFloat.random(in: -ant.wanderFactor...ant.wanderFactor)
                    ant.direction.dx *= 0.985
                    ant.direction.dy *= 0.985
                    
                    let len = max(0.1, sqrt(ant.direction.dx * ant.direction.dx + ant.direction.dy * ant.direction.dy))
                    ant.direction.dx /= len
                    ant.direction.dy /= len
                    
                    let pauseChance = (ant.role == .explorer) ? 1800 : 1200
                    if Int.random(in: 0...pauseChance) == 1 {
                        ant.isPaused = true
                        ant.pauseTimer = Double.random(in: 0.5...2.5)
                    }
                }
                
                let newAngle = atan2(Double(ant.direction.dy), Double(ant.direction.dx)) * 180 / .pi
                ant.angle = ant.angle * 0.9 + newAngle * 0.1
                
                ants[i] = ant
            }
        }
    }

    // MARK: - Cargar balance desde API
    @MainActor
    func fetchBalance() async {
        guard userId > 0 else { return }
        do {
            let response = try await ANTicipaAPIClient.shared.getTransactions(clienteId: userId)
            if let last = response.transactions.last,
               let balanceStr = last.balance_resultante,
               let balance = Double(balanceStr) {
                totalBalance = balance
            }
        } catch {
            print("⚠️ Error cargando balance:", error.localizedDescription)
        }
    }
    
    // MARK: - Refresh completo
    @MainActor
    func refreshHomeData() async {
        guard userId > 0 else { return }
        do {
            let response = try await ANTicipaAPIClient.shared.getTransactions(clienteId: userId)
            NotificationCenter.default.post(name: .didRefreshTransactions, object: response.transactions)
            
            if let last = response.transactions.last,
               let balanceStr = last.balance_resultante,
               let balance = Double(balanceStr) {
                totalBalance = balance
            }
            print("🔄 Refrescado: \(response.transactions.count) transacciones")
        } catch {
            print("❌ Error refrescando datos:", error.localizedDescription)
        }
    }
}


// MARK: - Extensión para sincronizar vistas
extension Notification.Name {
    static let didRefreshTransactions = Notification.Name("didRefreshTransactions")
}

// MARK: - MINI ACCIÓN
struct MiniAction: View {
    var icon: String
    var text: String
    
    var body: some View {
        VStack(spacing: 10) {
            Circle()
                .fill(Color.gray.opacity(0.15))
                .frame(width: 70, height: 70)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 25))
                        .foregroundColor(Color.black.opacity(0.75))
                )
            Text(text)
                .font(.system(size: 13))
                .multilineTextAlignment(.center)
                .foregroundColor(.black.opacity(0.8))
        }
        .frame(width: 100)
    }
}

// MARK: - SECCIÓN DE CAPI
let piqueteRed = Color(hex: "#A83D38")

struct CapiSection: View {
    let infestationColor: Color
    let userId: Int
    let username: String
    let userBalance: Double
    
    private let InfestRed = Color(hex: "#A4332C")

    
    var body: some View {
        
        Divider()
            .padding(.horizontal, 24)
 
        
        VStack(alignment: .leading, spacing: 14) {
            Text("¿Tienes alguna pregunta sobre tus piquetes?")
                .font(.system(size: 16))
                .foregroundColor(piqueteRed)
            
            Text("Consulta a tu asistente,\nCapi, sobre los criterios\nde tus gastos hormiga.")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(InfestRed)
            
            HStack(alignment: .center, spacing: 16) {
                NavigationLink(destination:
                    ChatView(
                        loggedUser: UserInfo(
                            id_cliente: userId,
                            nombre_completo: username,
                            email: UserDefaults.standard.string(forKey: "savedEmail") ?? "",
                            numero_cliente: "0000",
                            segmento_cliente: "Estándar",
                            fecha_ingreso_banco: "2024-01-01",
                            balance: userBalance
                        )
                    )
                ) {
                    HStack(spacing: 8) {
                        Text("Entra al chat")
                            .font(.system(size: 15, weight: .medium))
                        Image(systemName: "arrow.right")
                    }
                    .padding(.vertical, 20)
                    .padding(.horizontal, 20)
                    .background(Color(red: 0/255, green: 46/255, blue: 90/255))
                    .foregroundColor(.white)
                    .cornerRadius(40)
                }
                
                Spacer()
                
                Image("CapiHormiga")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 130)
                    .offset(y: 6)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 20)
        .padding(.top, 25)
    }
}

// MARK: - SECCIÓN HISTORIAL
struct HistorialGastosSection: View {
    let infestationColor: Color
    @AppStorage("userId") var userId: Int = 0
    @State private var transactions: [TransactionWithCategory] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showFullHistory = false
    
    var body: some View {
        Divider()
            .padding(.vertical, 40)
            .padding(.horizontal, 24)
        
        VStack(alignment: .leading, spacing: 10) {
            Text("Historial de gastos recientes")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(BrandColors.secondary)
                .padding(.bottom, 5)
                .padding(.horizontal, 40)
            
            if isLoading {
                ProgressView("Cargando tus transacciones...")
                    .padding(.horizontal, 40)
                    .padding(.vertical, 40)
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.system(size: 15))
                    .padding(.horizontal, 20)
            } else if transactions.isEmpty {
                Text("No se encontraron transacciones recientes.")
                    .foregroundColor(.gray)
                    .font(.system(size: 15))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(transactions.prefix(4)) { t in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(t.category ?? "Sin categoría")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.black)
                                Text(t.is_gasto_hormiga == 1 ? "Gasto hormiga" : "Gasto normal")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Text(String(format: "-%.2f MXN", t.montoDouble))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 0/255, green: 68/255, blue: 137/255))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
            }
            
            HStack {
                Spacer()
                Button {
                    showFullHistory = true
                } label: {
                    HStack(spacing: 4) {
                        Text("Ver historial completo")
                        Image(systemName: "arrow.right.circle")
                    }
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(red: 0/255, green: 68/255, blue: 137/255))
                }
                Spacer()
            }
            .padding(.top, 8)
        }
        .padding(.bottom, 40)
        .task { await fetchTransactions() }
        .onReceive(NotificationCenter.default.publisher(for: .didRefreshTransactions)) { notif in
            if let updated = notif.object as? [TransactionWithCategory] {
                transactions = updated
            }
        }
        .navigationDestination(isPresented: $showFullHistory) {
            HistorialCompletoView()
        }
    }
    
    func fetchTransactions() async {
        guard userId > 0 else {
            errorMessage = "No se encontró el ID del usuario."
            isLoading = false
            return
        }
        do {
            let response = try await ANTicipaAPIClient.shared.getTransactions(clienteId: userId)
            transactions = response.transactions
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? "Error al cargar las transacciones."
        }
        isLoading = false
    }
}

#Preview {
    HomeView(username: "Atenas Arita")
}
