//
//  Multiplication_Table_for_KidsApp.swift
//  Multiplication Table for Kids
//
//  Created by Ozan AYYILDIZ on 7/1/25.
//

import SwiftUI
import SwiftData

@main
struct Multiplication_Table_for_KidsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
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
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
