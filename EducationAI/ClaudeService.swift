import Foundation

class ClaudeService {
    static let shared = ClaudeService()
    
    func sendMessage(messages: [(role: String, content: String)]) async throws -> String {
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(APIConfig.claudeAPIKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        let body: [String: Any] = [
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 300,
            "system": "You are an ethical AI tutor inside the EducationAI app. Your job is to help students THINK, not give them answers. Rules: 1) Never give direct answers to homework or test questions. 2) Always ask what the student already knows first. 3) Break problems into steps and guide them. 4) If they ask you to just give the answer, refuse kindly and redirect them to think. 5) Keep responses short and conversational. 6) Encourage them when they make progress.",
            "messages": messages.map { ["role": $0.role, "content": $0.content] }
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let content = json?["content"] as? [[String: Any]]
        let text = content?.first?["text"] as? String
        
        return text ?? "I'm having trouble thinking right now. Try again?"
    }
}
