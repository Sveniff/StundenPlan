//
//  ContentView.swift
//  Shared
//
//  Created by Sven Iffland on 25.08.20.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var user: UserSettings
    var body: some View {
        Text(user.sessionId)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let user = UserSettings()
        return ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(user)
    }
}
