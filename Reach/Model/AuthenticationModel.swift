//
//  AuthenticationModel.swift
//  Reach
//
//  Created by xCode on 9/10/25.
//

import Foundation
import SwiftUI

// MARK: - Authentication Manager

/// Manages authentication state and user sessions
class AuthenticationManager: ObservableObject {
    // MARK: - Published Properties
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    
    // MARK: - Methods
    
    /// Authenticates a user with username, password, and team ID
    /// - Parameters:
    ///   - username: User's username
    ///   - password: User's password
    ///   - teamID: User's team identifier
    func login(username: String, password: String, teamID: String) {
        // Simple authentication logic - in a real app, this would validate against a server
        guard !username.isEmpty && !password.isEmpty && !teamID.isEmpty else {
            return
        }
        
        currentUser = User(username: username, teamID: teamID)
        isAuthenticated = true
    }
    
    /// Logs out the current user
    func logout() {
        currentUser = nil
        isAuthenticated = false
    }
}

// MARK: - User Model

/// Model representing a logged-in user
struct User: Identifiable, Codable {
    let id: UUID
    let username: String
    let teamID: String
    let loginDate: Date
    
    init(username: String, teamID: String) {
        self.id = UUID()
        self.username = username
        self.teamID = teamID
        self.loginDate = Date()
    }
}

