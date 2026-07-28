import Foundation

/// Turns an EditorialBrief into newsfeed copy. Cloud-only (Claude API).
protocol ClaudeGenerating {
    func generateCopy(from brief: EditorialBrief) async throws -> WeeklyNewsFeedCopy
}

/// Hardcoded copy for the simulator / tests
struct MockClaudeService: ClaudeGenerating {
    func generateCopy(from brief: EditorialBrief) async throws -> WeeklyNewsFeedCopy {
        WeeklyNewsFeedCopy(
            headline: "A Week of Quiet Momentum",
            subheadline: "Three events, one flight, and a treadmill that asked no questions.",
            body: "Our subject logged a modest but respectable week..."
        )
    }
}

/// Real Claude API call over URLSession. Device-only (needs the key + network).
struct ClaudeService: ClaudeGenerating {
    private let apiKey: String
    private let model = "claude-opus-4-8"
    private let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!

    init(apiKey: String = Secrets.anthropicAPIKey) {
        self.apiKey = apiKey
    }

    func generateCopy(from brief: EditorialBrief) async throws -> WeeklyNewsFeedCopy {
        // 1. Encode the brief to JSON — this is the user message content
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let briefJSON = String(data: try encoder.encode(brief), encoding: .utf8) ?? "{}"

        // 2. Request body: model + system voice + brief + a schema that forces
        //    Claude to return exactly WeeklyNewsFeedCopy's shape
        let body: [String: Any] = [
            "model": model,
            "max_tokens": 2048,
            "system": Self.systemPrompt,
            "messages": [["role": "user", "content": briefJSON]],
            "output_config": [
                "format": [
                    "type": "json_schema",
                    "schema": [
                        "type": "object",
                        "properties": [
                            "headline": ["type": "string"],
                            "subheadline": ["type": "string"],
                            "body": ["type": "string"]
                        ],
                        "required": ["headline", "subheadline", "body"],
                        "additionalProperties": false
                    ]
                ]
            ]
        ]

        // 3. Build the POST with the three required headers
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        // 4. Fire it (async/await)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            let text = String(data: data, encoding: .utf8) ?? "unknown"
            throw ClaudeError.badResponse(text)
        }

        // 5. Two-step decode: envelope → the text block → WeeklyNewsFeedCopy
        let envelope = try JSONDecoder().decode(AnthropicResponse.self, from: data)
        guard let jsonText = envelope.content.first(where: { $0.type == "text" })?.text,
              let copyData = jsonText.data(using: .utf8) else {
            throw ClaudeError.noContent
        }
        return try JSONDecoder().decode(WeeklyNewsFeedCopy.self, from: copyData)
    }

    // The editorial voice — and the guardrail that protects your architecture
    private static let systemPrompt = """
        You are the editor of a private weekly newsfeed about one person's life, \
        written in a dry, wry, deadpan editorial voice.

        You will receive a JSON brief of the week's facts. Write ONLY from those \
        facts. Never invent, infer, or alter events, names, dates, or numbers that \
        are not present in the brief. The numbers are already correct — do not \
        recompute or change them.

        Return a headline, a subheadline, and a short body (2–4 sentences).
        """
}

// Supporting types
private struct AnthropicResponse: Decodable {
    let content: [Block]
    struct Block: Decodable {
        let type: String
        let text: String?
    }
}

enum ClaudeError: Error {
    case badResponse(String)
    case noContent
}
