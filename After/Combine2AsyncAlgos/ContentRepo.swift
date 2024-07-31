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
    var chatNotificationsSubject: CurrentValueSubject<[Notification], Never> { get }
    var friendNotificationsSubject: CurrentValueSubject<[Notification], Never> { get }
    var downloadSubject: PassthroughSubject<Double, Never> { get }
    func loadUser()
    func streamChatNotifications()
    func streamFriendNotifications()
    func performDownload()
}

final class ContentRepoImpl: ContentRepo {
    
    var userChannel = AsyncThrowingChannel<User?, Error>()
    var chatNotificationsSubject = CurrentValueSubject<[Notification], Never>([])
    var friendNotificationsSubject = CurrentValueSubject<[Notification], Never>([])
    var downloadSubject = PassthroughSubject<Double, Never>()
    
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

    func performDownload() {
        Task {
            await downloadAPI.startDownload { [weak self] percentage in
                self?.downloadSubject.send(percentage)
            }
        }
    }
}
