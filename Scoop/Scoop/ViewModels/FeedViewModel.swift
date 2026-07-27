import Foundation

@MainActor
@Observable
final class FeedViewModel {

    // MARK: - Dependencies (injected)
    private let photosService: PhotoService
    private let calendarService: CalendarService
    private let healthKitService: HealthKitService
    private let composer: RawDataComposer
    private let extractor: EventExtracting

    init(
        photosService: PhotoService = PhotoService(),
        calendarService: CalendarService = CalendarService(),
        healthKitService: HealthKitService = HealthKitService(),
        composer: RawDataComposer = RawDataComposer(),
        extractor: EventExtracting = MockEventExtractor()
    ) {
        self.photosService = photosService
        self.calendarService = calendarService
        self.healthKitService = healthKitService
        self.composer = composer
        self.extractor = extractor
    }
}
