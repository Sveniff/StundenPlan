//
//  StundenPlanApp.swift
//  Shared
//
//  Created by Sven Iffland on 25.08.20.
//

import SwiftUI

@main
struct StundenPlanApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
