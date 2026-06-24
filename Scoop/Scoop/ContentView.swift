//
//  ContentView.swift
//  Scoop
//
//  Created by Marisol Bueno on 6/13/26.
//

import SwiftUI

struct ContentView: View {
    let extractor: EventExtracting = MockEventExtractor()
    
    @State private var extractedEvent: LifeEvent?
    
    @State private var photosService = PhotosService()
    @State private var photoCount: Int = 0
    
    @State private var calendarService = CalendarService()
    @State private var eventCount: Int = 0
    
    @State private var healthKitService = HealthKitService()
    @State private var stepCount: Int = 0
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Scoop")
                .font(.largeTitle)
            
            Text("Photos found: \(photoCount)")
            Text("Events found: \(eventCount)")
            Text("Steps found: \(stepCount)")
            
            // Photos
            Button("Request Access & Fetch - Photos") {
                Task {
                    await photosService.requestAccess()
                    
                    let calendar = Calendar.current
                    let now = Date()
                    let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
                    
                    let photos = photosService.fetchPhotos(from: startOfMonth, to: now)
                    photoCount = photos.count
                }
            }
            
            // Events
            Button("Request Access & Fetch - Calender"){
                Task {
                    await calendarService.requestAccess()
                    
                    let calendar = Calendar.current
                    let now = Date()
                    let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
                    
                    let events = calendarService.fetchEvents(from: startOfMonth, to: now)
                    eventCount = events.count
                }
            }
            
            // Steps
            Button("Request Access & Fetch - Steps") {
                Task {
                    await healthKitService.requestAccess()
                    
                    let calendar = Calendar.current
                    let now = Date()
                    let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
                    
                    let steps = await healthKitService.fetchStepCount(from: startOfMonth, to: now)
                    stepCount = steps
                }
            }
            
            // Extraction (mock for now)
            Button("Extract Sample Event") {
                Task {
                    extractedEvent = try? await extractor.extract(from: "sample raw data")
                }
            }
            
            if let event = extractedEvent {
                VStack(spacing: 4) {
                    Text(event.title).font(.headline)
                    Text(event.summary)
                    Text("Category: \(event.category)")
                    Text("Significance: \(event.significance)")
                }
                .padding(.top)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
