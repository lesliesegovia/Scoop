import SwiftUI

struct ContentView: View {
    @State private var viewModel = FeedViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Text("Scoop")
                .font(.largeTitle)

            switch viewModel.loadingState {
            case .idle:
                Button("Generate This Week") {
                    Task { await viewModel.generateFeed() }
                }

            case .loading:
                ProgressView("Reading your week…")

            case .failed(let message):
                Text("Couldn't build your feed: \(message)")
                    .foregroundStyle(.secondary)
                Button("Try Again") {
                    Task { await viewModel.generateFeed() }
                }

            case .loaded:
                ForEach(viewModel.events.indices, id: \.self) { i in
                    let event = viewModel.events[i]
                    VStack(spacing: 4) {
                        Text(event.title).font(.headline)
                        Text(event.summary)
                    }
                    .padding(.top)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
