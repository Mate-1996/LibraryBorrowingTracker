//
//  Midterm4App.swift
//  Midterm4
//
//  Created by Mate Chachkhiani on 2026-02-10.
//

import SwiftUI
import CoreData

@main
struct Midterm4App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(LibraryHolder(persistenceController.container.viewContext))
        }
    }
}
