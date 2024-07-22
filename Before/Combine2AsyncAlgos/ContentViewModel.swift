//
//  ContentViewModel.swift
//  Combine2AsyncAlgos
//
//  Created by Jacob Bartlett on 21/07/2024.
//

import Foundation
import Combine

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
        subscribeToUser()
        subscribeToNotifications()
        subscribeToDownloadTask()
    }
    
    private func loadData() {
        repo.loadUser()
        repo.streamChatNotifications()
        repo.streamFriendNotifications()
        repo.performDownload()
    }
    
    private func subscribeToUser() {
        repo.userSubject
            .compactMap { $0 }
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print(error)
                }
            }, receiveValue: { [weak self] user in
                self?.user = user
            })
            .store(in: &cancellables)
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
