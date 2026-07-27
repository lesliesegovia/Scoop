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
