//
//  ContentViewModel.swift
//  Combine2AsyncAlgos
//
//  Created by Jacob Bartlett on 21/07/2024.
//

import AsyncAlgorithms
import Combine
import Foundation

@Observable
final class ContentViewModel {
    
    var user: User?
    var notificationCount: Int = 0
    var downloadPercentage: Double = 0
    
    private let repo: ContentRepo = ContentRepoImpl()
    
    init() {
        configureSubscriptions()
        loadData()
    }
    
    private func configureSubscriptions() {
        Task { await handleUserValues() }
        Task { await performDownload() }
        Task { await streamNotificationCount() }
    }
    
    private func loadData() {
        repo.loadUser()
        repo.streamChatNotifications()
        repo.streamFriendNotifications()
    }
    
    @MainActor
    private func handleUserValues() async {
        do {
            for try await user in repo.userChannel.compacted() {
                self.user = user
            }
                    
        } catch {
            print(error)
        }
    }
    
    @MainActor
    private func streamNotificationCount() async {
        for await notificationsCount in combineLatest(
            repo.chatNotificationsSequence,
            repo.friendNotificationsSequence
        ).map({
            $0.0.count + $0.1.count
        }) {
            self.notificationCount = notificationsCount
        }
    }

    @MainActor
    private func performDownload() async {
        for await percentage in repo
            .performDownload()
            ._throttle(for: .seconds(0.05), latest: true) {
                self.downloadPercentage = percentage
            }
    }
}
