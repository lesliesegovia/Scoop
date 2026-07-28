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
    private let briefBuilder: BriefBuilder
    private let claude: ClaudeGenerating
    
    // MARK: - Published state
        enum LoadingState {
            case idle
            case loading
            case loaded
            case failed(String)
        }

    private(set) var events: [LifeEvent] = []
    private(set) var copy: WeeklyNewsFeedCopy?
    private(set) var loadingState: LoadingState = .idle
    
    // MARK: - Pipeline
    func generateFeed() async {
        loadingState = .loading
        
        // 1. Permissions
        await photosService.requestAccess()
        await calendarService.requestAccess()
        await healthKitService.requestAccess()
        
        // 2. This week's window (last 7 days) — computed ONCE
        let now = Date()
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        
        // 3. Fetch raw data from the three services
        let photos = photosService.fetchPhotos(from: weekAgo, to: now)
        let calendarEvents = calendarService.fetchEvents(from: weekAgo, to: now)
        let steps = await healthKitService.fetchStepCount(from: weekAgo, to: now)
        
        // 4. Deterministic digest (Swift owns this)
        let rawData = composer.compose(
            events: calendarEvents,
            photoCount: photos.count,
            stepCount: steps
        )
        
        // 5. Structured extraction (FoundationModels owns this)
        do {
            events = try await extractor.extract(from: rawData)
            
            // Deterministic Swift builds the brief Claude will write from
            let brief = briefBuilder.build(
                events: events,
                weekStart: weekAgo,
                weekEnd: now,
                totalSteps: steps,
                totalPhotos: photos.count
            )
            
            // Editorial writing: Claude turns the brief into newsfeed prose
            copy = try await claude.generateCopy(from: brief)

            loadingState = .loaded
        } catch {
            loadingState = .failed(error.localizedDescription)
        }
    }

    init(
        photosService: PhotoService = PhotoService(),
        calendarService: CalendarService = CalendarService(),
        healthKitService: HealthKitService = HealthKitService(),
        composer: RawDataComposer = RawDataComposer(),
        extractor: EventExtracting = MockEventExtractor(),
        briefBuilder: BriefBuilder = BriefBuilder(),
        claude: ClaudeGenerating = MockClaudeService()
    ) {
        self.photosService = photosService
        self.calendarService = calendarService
        self.healthKitService = healthKitService
        self.composer = composer
        self.extractor = extractor
        self.briefBuilder = briefBuilder
        self.claude = claude
    }
}
