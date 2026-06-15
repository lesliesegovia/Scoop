import Foundation
import EventKit

@Observable
class CalendarService {
    
    private let eventStore = EKEventStore()
    var authorizationStatus: EKAuthorizationStatus = .notDetermined
    
    /// Request access to the user's calendar
    func requestAccess() async {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            await MainActor.run {
                self.authorizationStatus = granted ? .fullAccess : .denied
            }
        } catch {
            print("Calendar access error: \(error)")
        }
    }
    
    /// Calendar event
    struct CalendarEvent: Identifiable {
        let id: String
        let title: String
        let startDate: Date
        let endDate: Date
    }
    
    /// Fetch calendar events within a date range
    func fetchEvents(from startDate: Date, to endDate: Date) -> [CalendarEvent] {
        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: nil
        )
        
        let events = eventStore.events(matching: predicate)
        
        return events.map { event in
            CalendarEvent(
                id: event.eventIdentifier,
                title: event.title ?? "Untitled Event",
                startDate: event.startDate,
                endDate: event.endDate
            )
        }
    }
}
