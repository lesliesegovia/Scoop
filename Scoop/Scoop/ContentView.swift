//
//  ContentView.swift
//  Scoop
//
//  Created by Marisol Bueno on 6/13/26.
//

import SwiftUI

struct ContentView: View {
    @State private var photosService = PhotosService()
    @State private var photoCount: Int = 0
    
    @State private var calendarService = CalendarService()
    @State private var eventCount: Int = 0
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Scoop")
                .font(.largeTitle)
            
            Text("Photos found: \(photoCount)")
            Text("Events found: \(eventCount)")
            
            Button("Request Access & Fetch") {
                Task {
                    await photosService.requestAccess()
                    
                    let calendar = Calendar.current
                    let now = Date()
                    let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
                    
                    let photos = photosService.fetchPhotos(from: startOfMonth, to: now)
                    photoCount = photos.count
                }
            }
            
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
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
