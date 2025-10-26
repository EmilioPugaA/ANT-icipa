//
//  ChatView.swift
//  ANTicipa
//
//  Creado por Enmanuel Rivas Barinas el 25/10/25.
//

import SwiftUI
import AVFoundation

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss
    let loggedUser: UserInfo // ✅ usuario real, obligatorio
    
    @State private var messages: [Message] = [
        Message(
            role: "model",
            text: "Hola " + (UserDefaults.standard.string(forKey: "username") ?? "usuario") +
                  ", soy Capi, tu asistente financiero. ¿En qué puedo ayudarte hoy?",
            time: Date.now.formatted(date: .omitted, time: .shortened),
            senderName: "Capi",
            imageName: "hormigaWha"
        )
    ]

    
    @State private var newMessage: String = ""
    @StateObject private var voiceAssistant = VoiceAssistant()
    @State private var isLoadingResponse = false
    
    var body: some View {
        ZStack(alignment: .top) {
            
            // MARK: - SCROLL PRINCIPAL DEL CHAT
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(messages) { msg in
                            MessageBubble(message: msg)
                                .id(msg.id)
                        }
                        if isLoadingResponse {
                            ProgressView("Capi está pensando...")
                                .progressViewStyle(CircularProgressViewStyle(tint: BrandColors.primary))
                                .padding()
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.bottom, 120)
                    .padding(.top, 210)
                    .onChange(of: messages.count) { _ in
                        withAnimation(.easeOut(duration: 0.3)) {
                            if let lastID = messages.last?.id {
                                proxy.scrollTo(lastID, anchor: .bottom)
                            }
                        }
                    }
                }
                .background(Color.white)
            }
            
            // MARK: - ENCABEZADO
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    BrandColors.primary
                        .ignoresSafeArea(edges: .top)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Button { dismiss() } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        .padding(.top, 60)
                        
                        HStack(spacing: 14) {
                            Image("hormigaWha")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 42, height: 42)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("ChatBot Capi")
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Asistente financiero con IA")
                                    .font(.system(size: 15))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .frame(height: 160)
                .clipShape(BottomRoundedShape(radius: 25))
                .padding(.top, 30)
                
                Spacer()
            }
            
            // MARK: - INPUT ABAJO CON VOZ
            VStack {
                Spacer()
                
                HStack(spacing: 12) {
                    
                    // MICRÓFONO
                    Button(action: {
                        if voiceAssistant.isListening {
                            voiceAssistant.stopListening()
                        } else {
                            newMessage = ""
                            voiceAssistant.recognizedText = ""
                            voiceAssistant.requestAuthorization()
                            voiceAssistant.startListening()
                        }
                    }) {
                        Image(systemName: voiceAssistant.isListening ? "mic.fill" : "mic")
                            .foregroundColor(voiceAssistant.isListening ? .red : BrandColors.primary)
                            .font(.system(size: 20, weight: .bold))
                            .padding(14)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                    }
                    
                    // CAMPO DE TEXTO
                    TextField("Escribe o habla con Capi...", text: $newMessage)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background(Color.gray.opacity(0.08))
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.gray.opacity(0.15))
                        )
                        .onChange(of: voiceAssistant.recognizedText) { newValue in
                            newMessage = newValue
                        }
                    
                    // BOTÓN ENVIAR
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .semibold))
                            .padding(14)
                            .background(BrandColors.primary)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                    }
                    .disabled(isLoadingResponse)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.white)
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.05), radius: 2, y: -1)
            }
            
            // MARK: - BARRA AZUL FIJA SUPERIOR
            VStack {
                BrandColors.primary
                    .frame(height: 70)
                    .ignoresSafeArea(edges: .top)
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .top)
    }
    
    // MARK: - Envío con IA de Gemini
    func sendMessage() {
        guard !newMessage.isEmpty else { return }
        
        let userMsg = Message(
            role: "user",
            text: newMessage,
            time: Date.now.formatted(date: .omitted, time: .shortened),
            senderName: "Tú"
        )
        
        messages.append(userMsg)
        let userInput = newMessage
        newMessage = ""
        isLoadingResponse = true
        
        Task {
            do {
                // ✅ Llama al Orchestrator con el usuario real
                let replyText = await GeminiOrchestrator.shared.handleUserQuestion(userInput, user: loggedUser)
                
                let aiReply = Message(
                    role: "model",
                    text: replyText,
                    time: Date.now.formatted(date: .omitted, time: .shortened),
                    senderName: "Capi",
                    imageName: "hormigaWha"
                )
                
                messages.append(aiReply)
                voiceAssistant.speak(replyText)
            } catch {
                messages.append(
                    Message(
                        role: "model",
                        text: "Lo siento, no pude procesar tu pregunta.",
                        time: Date.now.formatted(date: .omitted, time: .shortened),
                        senderName: "Capi",
                        imageName: "hormigaWha"
                    )
                )
            }
            isLoadingResponse = false
        }
    }
}

#Preview {
    NavigationStack {
        ChatView(
            loggedUser: UserInfo(
                id_cliente: 1,
                nombre_completo: "Usuario de Prueba",
                email: "test@example.com",
                numero_cliente: "12345",
                segmento_cliente: "Estándar",
                fecha_ingreso_banco: "2020-01-01",
                balance: 1500.0
            )
        )
    }
}
