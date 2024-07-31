//
//  FriendsAPI.swift
//  Combine2AsyncAlgos
//
//  Created by Jacob Bartlett on 21/07/2024.
//

import Foundation

final class FriendsAPI {
    
    func getFriendNotifications() async throws -> [Notification] {
        try await Task.sleep(for: .seconds(Double.random(in: 0...1)))
        return [
            Notification(id: "4", message: "Tom"),
            Notification(id: "5", message: "Mark"),
            Notification(id: "6", message: "Jane"),
            Notification(id: "6", message: "Derek")
        ]
    }
}
