//
//  StundenPlanApp.swift
//  Shared
//
//  Created by Sven Iffland on 25.08.20.
//

import CoreData
import SwiftUI

@main
struct StundenPlanApp: App {
    let persistenceController = PersistenceController.shared
    @ObservedObject var user = UserSettings()
    var authResult: (Bool, APIAuthResult?) = (false, nil)
    init() {
        user.auth()
    }
    
    var body: some Scene {
        WindowGroup {
            if user.loggedIn{
                ContentView()
                    .environmentObject(user)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
            else{
                login()
                    .preferredColorScheme(.light)
                    .environmentObject(user)
            }
        }
    }
}
