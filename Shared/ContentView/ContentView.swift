//
//ContentView.swift
//Shared
//
//Created by Sven Iffland on 25.08.20.
//

import SwiftUI
import CoreData
import Combine

struct ContentView: ViewInterface, View {
    @Environment(\.managedObjectContext) var managedObjectContext
    var presenter: ContentViewPresenterViewInterface!
    @EnvironmentObject var env: ContentViewEnvironment
    @ObservedObject var viewModel: ContentViewViewModel
    
    var body: some View {
        VStack{
            #if os(iOS)
                DashboardMobile()
                    .onAppear{
                        if (env.user.lastQuery?.addingTimeInterval(0)) ?? Date() <= Date(){
                            env.user.store()
                        }
                    }
            #endif
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let presenter = ContentViewPresenter()
        let viewModel = ContentViewViewModel()
        presenter.viewModel = viewModel
        return ContentView(presenter: presenter,
                        viewModel: viewModel)
        .environmentObject(ContentViewEnvironment())
    }
}
