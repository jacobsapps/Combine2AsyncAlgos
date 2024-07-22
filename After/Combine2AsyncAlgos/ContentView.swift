//
//  ContentView.swift
//  Combine2AsyncAlgos
//
//  Created by Jacob Bartlett on 21/07/2024.
//

import SwiftUI

struct ContentView: View {
    
    @State private var viewModel = ContentViewModel()
    
    var body: some View {
        NavigationStack {
            ProgressBar(progress: viewModel.downloadPercentage)
                .frame(maxHeight: .infinity, alignment: .center)
                .padding()
                .navigationTitle("Hello \(viewModel.user?.name ?? "")")
                .navigationBarItems(trailing: Button(action: { }) {
                    NotificationButton(badgeCount: viewModel.notificationCount)
                })
        }
    }
}

struct ProgressBar: View {
    let progress: Double
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Download \(String(format: "%.2f", progress))% complete")
            GeometryReader { geo in
                let proportionalWidth = geo.size.width * (progress / 100)
                RoundedRectangle(cornerRadius: 2)
                    .foregroundStyle(.green)
                    .frame(width: proportionalWidth, height: 4, alignment: .leading)
            }
        }
    }
}

struct NotificationButton: View {
    let badgeCount: Int
    
    var body: some View {
        Image(systemName: "tray")
            .font(.system(size: 16, weight: .semibold))
            .overlay(alignment: .topTrailing) {
                if badgeCount > 0 {
                    Text("\(badgeCount)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .frame(width: 18, height: 18)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 10, y: -10)
                }
            }
    }
}

#Preview {
    ContentView()
}
