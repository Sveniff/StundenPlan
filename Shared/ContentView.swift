//
//ContentView.swift
//Shared
//
//Created by Sven Iffland on 25.08.20.
//

import SwiftUI
import CoreData
import Combine

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var user: UserData
    
    var body: some View {
        VStack{
            #if os(iOS)
                DashboardMobile()
                    .onAppear(perform: {
                        if !user.loggedIn{
                            user.startSession()
                        }
                        user.store()
                        user.endSession()
                    })
            #endif
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView()
    }
}
