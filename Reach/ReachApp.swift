//
//  ReachApp.swift
//  Reach
//
//  Updated with SwiftData container
//

import SwiftUI
import SwiftData

@main
struct ReachApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: PinData.self)
    }
}
