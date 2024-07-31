//
//  User.swift
//  Combine2AsyncAlgos
//
//  Created by Jacob Bartlett on 21/07/2024.
//

import Foundation

struct User {
    let id: String
    let name: String
    let age: Int
    
    init?(id: String, name: String, age: Int) {
        guard (18...100).contains(age) else {
            return nil
        }
        self.id = id
        self.name = name
        self.age = age
    }
}
