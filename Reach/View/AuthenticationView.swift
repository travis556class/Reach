//
//  AuthenticationView.swift
//  Reach
//
//  Created by xCode on 9/10/25.
//

import SwiftUI

/// Authentication view for user login
struct AuthenticationView: View {
    // MARK: - Properties
    
    @Binding var isPresented: Bool
    @ObservedObject var authManager: AuthenticationManager
    
    @State private var username = ""
    @State private var password = ""
    @State private var teamID = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Team Login")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                }
                .padding(.top, 40)
                
                // Login Form
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Username")
                            .font(.headline)
                        TextField("Enter your username", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.headline)
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Team ID")
                            .font(.headline)
                        TextField("Enter your team ID", text: $teamID)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                }
                .padding(.horizontal, 20)
                
                // Login Button
                Button(action: {
                    if username.isEmpty || password.isEmpty || teamID.isEmpty {
                        alertMessage = "Please fill in all fields"
                        showingAlert = true
                    } else {
                        authManager.login(username: username, password: password, teamID: teamID)
                        isPresented = false
                    }
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .alert("Login Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

#Preview {
    AuthenticationView(
        isPresented: .constant(true),
        authManager: AuthenticationManager()
    )
}

