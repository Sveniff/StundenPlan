//
//  TimetableViewModule.swift
//  VIPERAndSwiftUI
//
//  Created by Tibor Bödecs on 2019. 09. 12..
//  Copyright © 2019. Tibor Bödecs. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine

protocol TimetableViewRouterPresenterInterface: RouterPresenterInterface {

}

protocol TimetableViewPresenterRouterInterface: PresenterRouterInterface {

}

protocol TimetableViewPresenterInteractorInterface: PresenterInteractorInterface {

}

protocol TimetableViewPresenterViewInterface: PresenterViewInterface {

}

protocol TimetableViewInteractorPresenterInterface: InteractorPresenterInterface {
    
}

final class TimetableViewModule: ModuleInterface {
    typealias phView = TimetableView
    typealias phPresenter = TimetableViewPresenter
    typealias phRouter = TimetableViewRouter
    typealias phInteractor = TimetableViewInteractor

    func build() -> some View{
        let presenter = phPresenter()
        let interactor = phInteractor()
        let router = phRouter()

        let viewModel = TimetableViewViewModel()
        let view = phView(presenter: presenter, viewModel: viewModel)
            .environmentObject(TimetableViewEnvironment())
        
        presenter.viewModel = viewModel

        self.assemble(presenter: presenter, router: router, interactor: interactor)

        return view
    }
}

