//
//  VoiceAssistant.swift
//  ANTicipa
//
//  Creado por Enmanuel Rivas Barinas el 25/10/25.
//

import Foundation
import Speech
import AVFoundation

class VoiceAssistant: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "es-MX"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private let synthesizer = AVSpeechSynthesizer()
    
    @Published var recognizedText: String = ""
    @Published var isListening = false
    
    // 🔹 Solicitar permisos
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("✅ Permiso de reconocimiento concedido")
                case .denied:
                    print("❌ Permiso de reconocimiento denegado")
                case .restricted, .notDetermined:
                    print("⚠️ Permiso de reconocimiento no disponible")
                @unknown default:
                    break
                }
            }
        }
    }
    
    // 🎤 Iniciar reconocimiento de voz
    func startListening() {
        guard !audioEngine.isRunning else { stopListening(); return }
        
        do {
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            
            let inputNode = audioEngine.inputNode
            recognitionRequest.shouldReportPartialResults = true
            
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    DispatchQueue.main.async {
                        self.recognizedText = result.bestTranscription.formattedString
                    }
                }
                if error != nil || (result?.isFinal ?? false) {
                    self.stopListening()
                }
            }
            
            let format = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            DispatchQueue.main.async { self.isListening = true }
            
        } catch {
            print("Error al iniciar reconocimiento: \(error.localizedDescription)")
        }
    }
    
    // 🛑 Detener
    func stopListening() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        audioEngine.inputNode.removeTap(onBus: 0)
        DispatchQueue.main.async { self.isListening = false }
    }
    
    // 🔊 Responder con voz
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "es-MX")
        utterance.rate = 0.48
        utterance.pitchMultiplier = 1.1
        synthesizer.speak(utterance)
    }
}
