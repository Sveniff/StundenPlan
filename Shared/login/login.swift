//
//  login.swift
//  StundenPlan
//
//  Created by Sven Iffland on 31.08.20.
//

import CoreData
import SwiftUI
import Combine

struct login: View {
    @EnvironmentObject var user: UserData
    @State var name: String = ""
    @State var pass: String = ""
    @State var wrongData: Bool = false
    
    var body: some View {
        VStack{
            Image("OHSApp")
                .resizable()
                .scaledToFit()
            TextField("Benutzername", text: $name)
                .loginTextField()
            SecureField("Passwort", text: $pass, onCommit: {
                tryLogin()
            })
                .loginTextField()
            if wrongData{
                Spacer()
                    .frame(height: 15)
                Text("Benutzername oder Passwort falsch")
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .foregroundColor(.red)
                Spacer()
                    .frame(height: 10)
            }
            Button(action: {
                tryLogin()
            }) {
                Text("login")
                    .font(.system(size: 25, weight: .semibold, design: .rounded))
            }
        }
    }
    private func tryLogin() {
        user.username = name
        user.password = pass
        user.login()
        if user.sessionId != nil{
            wrongData = false
            user.loggedIn = true
        }
        else{
            wrongData = true
        }
    }
}

struct login_Previews: PreviewProvider {
    static var previews: some View {
        login()
    }
}
