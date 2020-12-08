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
    @EnvironmentObject var user: UserSettings
    @State var name: String = ""
    @State var pass: String = ""
    @State var wrongData: Bool = false
    var body: some View {
        ZStack{
            Color(red: 0.2588, green: 0.5568, blue: 0.7843, opacity: 1)
                .edgesIgnoringSafeArea(.all)
                .zIndex(0)
            VStack{
                VStack{
                    VStack{
                        Image("OttoHahnLogo")
                            .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .scaleEffect(x: 0.1, y: 0.1, anchor: .center)
                        Text("Otto-Hahn Gymnasium Bensberg")
                            .multilineTextAlignment(.center)
                            .font(.system(size: 30, weight: .semibold, design: .default))
                            .foregroundColor(Color(red: 0.1019, green: 0.1921, blue: 0.3327, opacity: 1))
                    }
                    .padding()
                    TextField("Benutzername", text: $name)
                        .multilineTextAlignment(.center)
                        .frame(width: 250, height: 40, alignment: .center)
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke())
                    SecureField("Passwort", text: $pass)
                        .multilineTextAlignment(.center)
                        .frame(width: 250, height: 40, alignment: .center)
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke())
                    if wrongData{
                        Spacer().frame(height: 15)
                        Text("Benutzername oder Passwort falsch")
                            .font(.system(size: 15, weight: .regular, design: .default))
                            .foregroundColor(.red)
                        Spacer().frame(height: 10)
                    } 
                    Button(action: {
                        user.username = name
                        user.password = pass
                        user.auth()
                        if user.sessionId != nil{
                            wrongData = false
                            user.loggedIn = true
                        }
                        else{
                            wrongData = true
                        }
                    }) {
                        Text("anmelden")
                            .font(.system(size: 15, weight: .regular, design: .default))
                            .foregroundColor(Color(red: 0, green: 0.6784, blue: 0.9372, opacity: 1))
                    }
                }
                .padding()
                .frame(width: 300)
                .background(RoundedRectangle(cornerRadius: 5)
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 5, x: 0, y: 5))
                .zIndex(1)
                Spacer()
                    .frame(height: 0)
                RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(Color(red: 0.1019, green: 0.1921, blue: 0.3327, opacity: 1))
                    .frame(width: 300, height: 50)
                    .offset(x: 0, y: -10)
                    .shadow(color: .black, radius: 5, x: 0, y: 5)
                    .zIndex(0)
            }
        }
    }
}

struct login_Previews: PreviewProvider {
    static var previews: some View {
        return login()
            .environmentObject(UserSettings())
//            .frame(width: 500, height: 500, alignment: .center)
    }
}
