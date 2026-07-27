import Foundation

/// turns extracted events + raw counts into an EditorialBrief.
struct BriefBuilder {
    func build(
        events: [LifeEvent],
        weekStart: Date,
        weekEnd: Date,
        totalSteps: Int,
        totalPhotos: Int
    ) -> EditorialBrief {

        // Count events per category ["social": 3, "fitness": 1]
        var categoryCounts: [String: Int] = [:]
        for event in events {
            let name = String(describing: event.category)
            categoryCounts[name, default: 0] += 1
        }

        // Standouts: the 3 most significant events, highest first
        let standouts = events
            .sorted { $0.significance > $1.significance }
            .prefix(3)
            .map { event in
                EditorialBrief.Standout(
                    title: event.title,
                    summary: event.summary,
                    category: String(describing: event.category),
                    significance: event.significance
                )
            }

        return EditorialBrief(
            weekStart: weekStart,
            weekEnd: weekEnd,
            totalEvents: events.count,
            totalSteps: totalSteps,
            totalPhotos: totalPhotos,
            categoryCounts: categoryCounts,
            standouts: Array(standouts)
        )
    }
}
