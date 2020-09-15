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
    @ObservedObject var user = UserSettings()
    var authResult: (Bool, APIAuthResult?) = (false, nil)
    init() {
        if user.username != "" && user.password != "" {
            authResult = auth(user.username, user.password)
            if authResult.0{
                user.sessionId = authResult.1!.result["sessionId"] as! String
                user.klasseId = authResult.1!.result["klasseId"] as? Int
                user.personId = authResult.1!.result["personId"] as? Int
                user.personType = authResult.1!.result["personType"] as? Int
                user.loggedIn = true
            }
            else{
                user.loggedIn = false
            }
        }
        else{
            user.loggedIn = false
        }
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
