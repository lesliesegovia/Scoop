import Foundation

/// The editorial copy Claude writes from an EditorialBrief.
struct WeeklyNewsFeedCopy: Codable {
    let headline: String       // masthead front-page headline
    let subheadline: String    // the deck under it
    let body: String           // the lead story prose
}

