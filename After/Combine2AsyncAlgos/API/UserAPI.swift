//
//  UserAPI.swift
//  Combine2AsyncAlgos
//
//  Created by Jacob Bartlett on 21/07/2024.
//

import Foundation

final class UserAPI {
    
    func getUser() async throws -> User? {
        try await Task.sleep(for: .seconds(Double.random(in: 0...1)))
        return User(id: "0", name: "John", age: 41)
    }
}
