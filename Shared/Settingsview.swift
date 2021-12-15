//
//  Settingsview.swift
//  StundenPlan
//
//  Created by Sven Iffland on 02.12.20.
//

import SwiftUI

struct Settingsview: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var user: UserData
    @State var scale = 1.0
    var body: some View {
        ScrollView{
            Spacer().frame(height: 100)
            HStack{
                Text("scale:")
                Slider(value: $scale, in: 0.5...3)
            }
            Spacer()
            Button(action: {
                user.store()
            }){
                Text("update")
            }
            Button(action: {
                user.username = ""
                user.password = ""
                user.loggedIn = false
                user.sessionId = nil
                user.klasseId = nil
                user.personId = nil
                user.personType = nil
                user.lastQuery = nil

            }){
                Text("Ausloggen")
            }
        }
        .onAppear{
            scale = user.scale
        }
        .onDisappear{
            user.scale = scale
        }
    }
}

struct Settingsview_Previews: PreviewProvider {
    static var previews: some View {
        Settingsview()
    }
}
