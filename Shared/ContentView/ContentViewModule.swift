//
//  ContentViewModule.swift
//  VIPERAndSwiftUI
//
//  Created by Tibor Bödecs on 2019. 09. 12..
//  Copyright © 2019. Tibor Bödecs. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine

protocol ContentViewRouterPresenterInterface: RouterPresenterInterface {

}

protocol ContentViewPresenterRouterInterface: PresenterRouterInterface {

}

protocol ContentViewPresenterInteractorInterface: PresenterInteractorInterface {

}

protocol ContentViewPresenterViewInterface: PresenterViewInterface {

}

protocol ContentViewInteractorPresenterInterface: InteractorPresenterInterface {
    
}

final class ContentViewModule: ModuleInterface {

    typealias phView = ContentView
    typealias phPresenter = ContentViewPresenter
    typealias phRouter = ContentViewRouter
    typealias phInteractor = ContentViewInteractor

    func build() -> some View{
        let presenter = phPresenter()
        let interactor = phInteractor()
        let router = phRouter()

        let viewModel = ContentViewViewModel()
        let view = phView(presenter: presenter, viewModel: viewModel)
            .environmentObject(ContentViewEnvironment())
        presenter.viewModel = viewModel

        self.assemble(presenter: presenter, router: router, interactor: interactor)

        return view
    }
}

