//
//  ChatAPI.swift
//  Combine2AsyncAlgos
//
//  Created by Jacob Bartlett on 21/07/2024.
//

import Foundation

final class ChatAPI {
    
    func getUnreadChatMessages() async throws -> [Notification] {
        try await Task.sleep(for: .seconds(Double.random(in: 1...2)))
        return [
            Notification(id: "1", message: "Hello"),
            Notification(id: "2", message: "Hi"),
            Notification(id: "3", message: "Hey")
        ]
    }
}
