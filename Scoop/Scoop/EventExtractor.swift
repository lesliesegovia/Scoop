import Foundation
import FoundationModels

@Generable
enum EventCategory {
    case social
    case fitness
    case travel
    case work
    case milestone
    case other
}

@Generable(description: "A life event extracted from a person's data")
struct LifeEvent {
    @Guide(description: "A short title")
    var title: String

    @Guide(description: "One or two sentences describing what happened")
    var summary: String

    @Guide(description: "The category this event best fits. Use 'other' only when none of the named categories apply.")
    var category: EventCategory

    @Guide(description: "Significance from 1 (minor) to 5 (major).", .range(1...5))
    var significance: Int
}

// Lets callers swap the on-device extractor for a mock (simulator/tests)
protocol EventExtracting {
    func extract(from rawData: String) async throws -> LifeEvent
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
    
    func extract(from rawData: String) async throws -> LifeEvent {
        let session = LanguageModelSession(instructions: """
            You extract a single factual life event from raw personal data.
            Describe only what happened, plainly.
            """)

        let response = try await session.respond(to: rawData, generating: LifeEvent.self)
        return response.content
    }
}

struct MockEventExtractor: EventExtracting {
    func extract(from rawData: String) async throws -> LifeEvent {
        LifeEvent(
            title: "Dinner with friends",
            summary: "Met Kat, Justin, Andres and Danny for dinner at Trattoria Amici on Friday evening.",
            category: .social,
            significance: 3
        )
    }
}
