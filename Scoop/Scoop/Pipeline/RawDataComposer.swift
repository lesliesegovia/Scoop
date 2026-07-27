import Foundation

struct RawDataComposer {
    func compose(
        events: [CalendarService.CalendarEvent],
        photoCount: Int,
        stepCount: Int
    ) -> String {
        var lines: [String] = []
        
        lines.append("CALENDAR EVENTS:")
        if events.isEmpty {
            lines.append("- none")
        } else {
            for event in events {
                let when = event.startDate.formatted(date: .abbreviated, time: .shortened)
                lines.append("- \"\(event.title)\" on \(when)")
            }
        }

        lines.append("")
        lines.append("PHOTOS: \(photoCount) taken")
        lines.append("STEPS: \(stepCount) total")

        return lines.joined(separator: "\n")
    }
}

