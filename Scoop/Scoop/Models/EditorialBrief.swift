import Foundation

/// Swift to Claude hand off
struct EditorialBrief: Codable {
    let weekStart: Date
    let weekEnd: Date

    // Hard numbers: Swift owns these, Claude never computes them
    let totalEvents: Int
    let totalSteps: Int
    let totalPhotos: Int

    // The week broke down by category ["social": 3, "fitness": 1]
    let categoryCounts: [String: Int]

    // The few events worth a headline, ranked by significance
    let standouts: [Standout]

    /// A trimmed, JSON-clean event, decoupled from the @Generable LifeEvent.
    struct Standout: Codable {
        let title: String
        let summary: String
        let category: String
        let significance: Int
    }
}
