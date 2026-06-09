import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    
    // Dependency Injection pakai Protocol
    private let geminiService: GeminiServiceProtocol
    
    init(geminiService: GeminiServiceProtocol = GeminiService()) {
        self.geminiService = geminiService
        
        // Pesan sapaan pertama kali saat user buka layar Chat
        messages.append(ChatMessage(role: "model", content: "Halo! Aku LeapBot 🤖. Ada rencana liburan atau mau cari inspirasi destinasi hari ini?"))
    }
    
    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        // 1. Munculin chat user di layar
        let userMsg = ChatMessage(role: "user", content: text)
        messages.append(userMsg)
        inputText = ""
        isLoading = true
        
        do {
            // 2. Minta AI mikir balesan (passing history chat)
            let replyText = try await geminiService.sendMessage(chatHistory: messages)
            let botReply = ChatMessage(role: "model", content: replyText)
            messages.append(botReply)
            isLoading = false

        //hvdsahbvdkjahbd
        } catch {
            // Nampilin pesan error TEKNIS langsung ke layar chat
            let errorMessage = "🚨 ERROR TEKNIS:\n\(error.localizedDescription)\n\nRAW INFO:\n\(String(describing: error))"
            
            let botReply = ChatMessage(role: "model", content: errorMessage)
            messages.append(botReply)
            isLoading = false
        }
        //kfdsankasldnlads
    }
}