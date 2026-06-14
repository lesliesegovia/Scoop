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
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Scoop")
                .font(.largeTitle)
            
            Text("Photos found: \(photoCount)")
            
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
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
