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
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        configureSubscriptions()
        loadData()
    }
    
    private func configureSubscriptions() {
        Task {
            await handleUserValues()
        }
        subscribeToNotifications()
        subscribeToDownloadTask()
    }
    
    private func loadData() {
        repo.loadUser()
        repo.streamChatNotifications()
        repo.streamFriendNotifications()
        repo.performDownload()
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
    
    private func subscribeToNotifications() {
        repo.chatNotificationsSubject
            .combineLatest(repo.friendNotificationsSubject)
            .map { $0.0.count + $0.1.count }
            .receive(on: RunLoop.main)
            .assign(to: \.notificationCount, on: self)
            .store(in: &cancellables)
    }
    
    private func subscribeToDownloadTask() {
        repo.downloadSubject
            .throttle(for: .seconds(0.05), scheduler: RunLoop.main, latest: true)
            .receive(on: RunLoop.main)
            .assign(to: \.downloadPercentage, on: self)
            .store(in: &cancellables)
    }
}
