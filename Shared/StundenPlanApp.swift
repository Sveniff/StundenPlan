//
//  StundenPlanApp.swift
//  Shared
//
//  Created by Sven Iffland on 25.08.20.
//

import CoreData
import SwiftUI
import Combine

@main
struct StundenPlanApp: App {
    let persistenceController = PersistenceController.shared
    @ObservedObject var user: UserData
    init() {
        user = UserData(persistenceController.container.viewContext, persistenceController.container.viewContext.persistentStoreCoordinator!)
        user.login()
    }
    
    var body: some Scene {
        WindowGroup {
            if user.password != "" && user.username != "" && user.loggedIn{
                ContentView()
                    .environmentObject(user)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
            else{
                login()
                    .environmentObject(user)
            }
        }
    }
}
