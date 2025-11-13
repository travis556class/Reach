//
//  AuthenticationView.swift
//  Reach
//
//  Enhanced following Apple HIG
//

import SwiftUI

struct AuthenticationView: View {
    // MARK: - Properties
    
    @Binding var isPresented: Bool
    @ObservedObject var authManager: AuthenticationManager
    
    @State private var username = ""
    @State private var password = ""
    @State private var teamID = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) private var dismiss
    
    enum Field: Hashable {
        case username, password, teamID
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    headerSection
                    
                    // Login Form
                    loginFormSection
                    
                    // Login Button
                    loginButton
                }
                .padding()
            }
            .navigationTitle("Team Login")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            focusedField = nil
                        }
                        .fontWeight(.semibold)
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
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)
                .symbolEffect(.bounce, value: isPresented)
            
            VStack(spacing: 8) {
                Text("Sign In to Your Team")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Enter your credentials to access team features and sync your data")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical)
    }
    
    private var loginFormSection: some View {
        VStack(spacing: 20) {
            // Username Field
            VStack(alignment: .leading, spacing: 8) {
                Label("Username", systemImage: "person.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                TextField("Enter your username", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.username)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .username)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .password
                    }
            }
            
            // Password Field
            VStack(alignment: .leading, spacing: 8) {
                Label("Password", systemImage: "lock.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                SecureField("Enter your password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .teamID
                    }
            }
            
            // Team ID Field
            VStack(alignment: .leading, spacing: 8) {
                Label("Team ID", systemImage: "number")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                TextField("Enter your team ID", text: $teamID)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .teamID)
                    .submitLabel(.go)
                    .onSubmit {
                        attemptLogin()
                    }
            }
        }
    }
    
    private var loginButton: some View {
        Button {
            attemptLogin()
        } label: {
            HStack {
                Image(systemName: "arrow.right.circle.fill")
                Text("Sign In")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .disabled(!isFormValid)
    }
    
    // MARK: - Helper Properties
    
    private var isFormValid: Bool {
        !username.isEmpty && !password.isEmpty && !teamID.isEmpty
    }
    
    // MARK: - Helper Methods
    
    private func attemptLogin() {
        focusedField = nil
        
        guard isFormValid else {
            alertMessage = "Please fill in all fields"
            showingAlert = true
            return
        }
        
        authManager.login(username: username, password: password, teamID: teamID)
        dismiss()
    }
}

#Preview {
    AuthenticationView(
        isPresented: .constant(true),
        authManager: AuthenticationManager()
    )
}
