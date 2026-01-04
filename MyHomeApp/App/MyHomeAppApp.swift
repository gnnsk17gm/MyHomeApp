//
//  MyHomeAppApp.swift
//  MyHomeApp
//
//  Created by Gin on 2025/11/16.
//

import SwiftUI
import SwiftData

@main
struct MyHomeAppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            AssetManage.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(sharedModelContainer)
    }
}
