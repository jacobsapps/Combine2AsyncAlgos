//
//  ContentRepo.swift
//  Combine2AsyncAlgos
//
//  Created by Jacob Bartlett on 21/07/2024.
//

import AsyncAlgorithms
import Combine
import Foundation

protocol ContentRepo {
    var userChannel: AsyncThrowingChannel<User?, Error> { get }
    var chatNotificationsSequence: AsyncPublisher<AnyPublisher<[Notification], Never>> { get }
    var friendNotificationsSequence: AsyncPublisher<AnyPublisher<[Notification], Never>> { get }
    func loadUser()
    func streamChatNotifications()
    func streamFriendNotifications()
    func performDownload() -> AsyncStream<Double>
}

final class ContentRepoImpl: ContentRepo {
 
    var chatNotificationsSequence: AsyncPublisher<AnyPublisher<[Notification], Never>> {
        chatNotificationsSubject.eraseToAnyPublisher().values
    }
    
    var friendNotificationsSequence: AsyncPublisher<AnyPublisher<[Notification], Never>> {
        friendNotificationsSubject.eraseToAnyPublisher().values
    }
    
    var userChannel = AsyncThrowingChannel<User?, Error>()
   
    private var chatNotificationsSubject = CurrentValueSubject<[Notification], Never>([])
    private var friendNotificationsSubject = CurrentValueSubject<[Notification], Never>([])
    
    private let userAPI = UserAPI()
    private let chatAPI = ChatAPI()
    private let friendsAPI = FriendsAPI()
    private let downloadAPI = DownloadAPI()
    
    init() { }
    
    func loadUser() {
        Task {
            do {
                let user = try await userAPI.getUser()
                await userChannel.send(user)
            } catch {
                userChannel.fail(error)
            }
        }
    }
    
    func streamChatNotifications() {
        Task {
            let chatNotifications = try? await chatAPI.getUnreadChatMessages()
            chatNotificationsSubject.send(chatNotifications ?? [])
        }
    }
    
    func streamFriendNotifications() {
        Task {
            let friendNotifications = try? await friendsAPI.getFriendNotifications()
            friendNotificationsSubject.send(friendNotifications ?? [])
        }
    }

    func performDownload() -> AsyncStream<Double> {
        AsyncStream { continuation in
            Task {
                await downloadAPI.startDownload { percentage in
                    continuation.yield(percentage)
                }
                continuation.finish()
            }
        }
    }
}
