import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    
    private let groqService: GroqServiceProtocol
    
    init(groqService: GroqServiceProtocol = GroqService()) {
        self.groqService = groqService
        
        messages.append(ChatMessage(role: "assistant", content: "Halo! Aku LeapBot 🤖. Ada rencana liburan atau mau cari inspirasi destinasi hari ini?"))
    }
    
    // MARK: - Send Message
    func sendMessage() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        let userMsg = ChatMessage(role: "user", content: text)
        messages.append(userMsg)
        inputText = ""
        isLoading = true
        
        do {
            let replyText = try await groqService.sendMessage(chatHistory: messages)
            let botReply = ChatMessage(role: "assistant", content: replyText)
            messages.append(botReply)
            isLoading = false

        } catch {
            let errorMessage = "🚨 ERROR TEKNIS:\n\(error.localizedDescription)\n\nRAW INFO:\n\(String(describing: error))"
            
            let botReply = ChatMessage(role: "assistant", content: errorMessage)
            messages.append(botReply)
            isLoading = false
        }
    }
}