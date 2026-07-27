import Foundation
import FoundationModels

// Lets callers swap the on-device extractor for a mock (simulator/tests)
protocol EventExtracting {
    func extract(from rawData: String) async throws -> [LifeEvent]
}

struct OnDeviceEventExtractor: EventExtracting {
    private let model = SystemLanguageModel.default
    
    func availabilityStatus() -> String {
        switch model.availability {
        case .available:
            return "Ready"
        case .unavailable(.deviceNotEligible):
            return "This device doesn't support Apple Intelligence."
        case .unavailable(.appleIntelligenceNotEnabled):
            return "Turn on Apple Intelligence in Settings."
        case .unavailable(.modelNotReady):
            return "The model is still downloading. Try again later."
        case .unavailable(let other):
            return "Unavailable: \(other)"
        }
    }
    
    func extract(from rawData: String) async throws -> [LifeEvent] {
        let session = LanguageModelSession(instructions: """
            You extract the distinct factual life events from raw personal data.
            Describe only what happened, plainly.
            """)

        let response = try await session.respond(to: rawData, generating: [LifeEvent].self)
        return response.content
    }
}

struct MockEventExtractor: EventExtracting {
    func extract(from rawData: String) async throws -> [LifeEvent] {
        [
            LifeEvent(
            title: "Dinner with friends",
            summary: "Met Kat, Justin, Andres and Danny for dinner at Trattoria Amici on Friday evening.",
            category: .social,
            significance: 3
            ),
            LifeEvent(
                title: "Flight to Edinburgh",
                summary: "Traveled to Edinburgh for a week long trip",
                category: .travel,
                significance: 4
            ),
            LifeEvent(
                title: "Gym day",
                summary: "Hit 6,000 steps on the treadmill at the gym Friday morning.",
                category: .fitness,
                significance: 2
            )
        ]
    }
}
