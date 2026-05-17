import Foundation

enum ClaudeError: LocalizedError {
    case missingAPIKey
    case httpError(Int)
    case invalidResponse
    case noQuestionsGenerated

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "No API key found. Add your Claude API key in Settings."
        case .httpError(let code):
            return "API error (HTTP \(code)). Check your API key in Settings."
        case .invalidResponse:
            return "Unexpected response from Claude. Please try again."
        case .noQuestionsGenerated:
            return "Claude couldn't generate questions for that topic. Try a different one."
        }
    }
}

class ClaudeService {
    static let shared = ClaudeService()

    private let apiURL = URL(string: "https://api.anthropic.com/v1/messages")!
    private let model = "claude-sonnet-4-6"

    private func baseRequest(maxTokens: Int, system: String, userMessage: String) throws -> URLRequest {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue(APIConfig.claudeAPIKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")

        let body: [String: Any] = [
            "model": model,
            "max_tokens": maxTokens,
            "system": system,
            "messages": [["role": "user", "content": userMessage]]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return request
    }

    private func requestWithHistory(maxTokens: Int, system: String, messages: [(role: String, content: String)]) throws -> URLRequest {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue(APIConfig.claudeAPIKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")

        let body: [String: Any] = [
            "model": model,
            "max_tokens": maxTokens,
            "system": system,
            "messages": messages.map { ["role": $0.role, "content": $0.content] }
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return request
    }

    private func fetchResponseText(from request: URLRequest) async throws -> String {
        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw ClaudeError.httpError(httpResponse.statusCode)
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let text = content.first?["text"] as? String else {
            throw ClaudeError.invalidResponse
        }
        return text
    }

    func sendMessage(messages: [(role: String, content: String)]) async throws -> String {
        guard APIConfig.hasAPIKey else { throw ClaudeError.missingAPIKey }

        let system = """
        You are an ethical AI tutor inside the EducationAI app. Your job is to help students THINK, not give them answers.
        Rules:
        1) Never give direct answers to homework or test questions.
        2) Always ask what the student already knows first.
        3) Break problems into steps and guide them.
        4) If they ask you to just give the answer, refuse kindly and redirect them to think.
        5) Keep responses short and conversational.
        6) Encourage them when they make progress.
        """

        let request = try requestWithHistory(maxTokens: 400, system: system, messages: messages)
        return try await fetchResponseText(from: request)
    }

    func generateQuizQuestions(topic: String) async throws -> [Question] {
        guard APIConfig.hasAPIKey else { throw ClaudeError.missingAPIKey }

        let prompt = """
        Generate exactly 5 multiple choice questions about "\(topic)" for a high school student.
        Return ONLY a valid JSON array — no markdown, no explanation, no other text.
        Each object must have exactly these fields:
        - "text": the question string
        - "options": array of exactly 4 answer strings
        - "correctIndex": integer 0-3 indicating the correct answer
        - "explanation": one sentence explaining the correct answer
        """

        let request = try baseRequest(
            maxTokens: 1500,
            system: "You are a quiz generator. Respond with only valid JSON, nothing else.",
            userMessage: prompt
        )

        let responseText = try await fetchResponseText(from: request)
        let questions = try parseQuestions(from: responseText)

        guard !questions.isEmpty else { throw ClaudeError.noQuestionsGenerated }
        return questions
    }

    func generateQuizFromChatHistory(messages: [(role: String, content: String)]) async throws -> [Question] {
        guard APIConfig.hasAPIKey else { throw ClaudeError.missingAPIKey }

        let transcript = messages.map { "\($0.role.capitalized): \($0.content)" }.joined(separator: "\n\n")

        let prompt = """
        Below is a tutoring conversation between a student and an AI. Generate exactly 5 multiple choice questions that test understanding of the specific topics and concepts discussed.

        Conversation:
        \(transcript)

        Return ONLY a valid JSON array — no markdown, no explanation, no other text.
        Each object must have exactly these fields:
        - "text": the question string
        - "options": array of exactly 4 answer strings
        - "correctIndex": integer 0-3 indicating the correct answer
        - "explanation": one sentence explaining the correct answer
        """

        let request = try baseRequest(
            maxTokens: 1500,
            system: "You are a quiz generator. Respond with only valid JSON, nothing else.",
            userMessage: prompt
        )

        let responseText = try await fetchResponseText(from: request)
        let questions = try parseQuestions(from: responseText)
        guard !questions.isEmpty else { throw ClaudeError.noQuestionsGenerated }
        return questions
    }

    private func parseQuestions(from text: String) throws -> [Question] {
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // Strip markdown code fences if present
        if cleaned.hasPrefix("```") {
            let lines = cleaned.components(separatedBy: "\n")
            cleaned = lines.dropFirst().joined(separator: "\n")
        }
        if cleaned.hasSuffix("```") {
            let lines = cleaned.components(separatedBy: "\n")
            cleaned = lines.dropLast().joined(separator: "\n")
        }
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = cleaned.data(using: .utf8),
              let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw ClaudeError.invalidResponse
        }

        return array.compactMap { obj in
            guard let text = obj["text"] as? String,
                  let options = obj["options"] as? [String],
                  let correctIndex = obj["correctIndex"] as? Int,
                  let explanation = obj["explanation"] as? String,
                  options.count == 4,
                  (0..<4).contains(correctIndex) else { return nil }
            return Question(text: text, options: options, correctIndex: correctIndex, explanation: explanation)
        }
    }
}
