//
//  Interfaces.swift
//  VIPER
//
//  Created by Tibor Bödecs on 2019. 05. 16..
//  Copyright © 2019. Tibor Bödecs. All rights reserved.
//

import Foundation

// MARK: - VIPER

public protocol RouterInterface: RouterPresenterInterface {
    associatedtype PresenterRouter

    var presenter: PresenterRouter! { get set }
}

public protocol InteractorInterface: InteractorPresenterInterface {
    associatedtype PresenterInteractor

    var presenter: PresenterInteractor! { get set }
}

public protocol PresenterInterface: PresenterRouterInterface & PresenterInteractorInterface & PresenterViewInterface {
    associatedtype RouterPresenter
    associatedtype InteractorPresenter
    /*associatedtype ViewPresenter*/

    var router: RouterPresenter! { get set }
    var interactor: InteractorPresenter! { get set }
    /*var view: ViewPresenter! { get set }*/
}

public protocol ViewInterface/*: ViewPresenterInterface*/ {
    associatedtype PresenterView

    var presenter: PresenterView! { get set }
}

public protocol EntityInterface {

}

// MARK: - "i/o" transitions

public protocol RouterPresenterInterface: AnyObject {

}

public protocol InteractorPresenterInterface: AnyObject {

}

public protocol PresenterRouterInterface: AnyObject {

}

public protocol PresenterInteractorInterface: AnyObject {

}

public protocol PresenterViewInterface: AnyObject {

}
/*
public protocol ViewPresenterInterface: class {

}
*/

// MARK: - module

public protocol ModuleInterface {

    associatedtype phView where phView: ViewInterface
    associatedtype phPresenter where phPresenter: PresenterInterface
    associatedtype phRouter where phRouter: RouterInterface
    associatedtype phInteractor where phInteractor: InteractorInterface

    func assemble(/*view: View, */presenter: phPresenter, router: phRouter, interactor: phInteractor)
}

public extension ModuleInterface {

    func assemble(/*view: View, */presenter: phPresenter, router: phRouter, interactor: phInteractor) {
        /*
        view.presenter = (presenter as! Self.View.PresenterView)

        presenter.view = (view as! Self.Presenter.ViewPresenter)
        */
        presenter.interactor = (interactor as! Self.phPresenter.InteractorPresenter)
        presenter.router = (router as! Self.phPresenter.RouterPresenter)

        interactor.presenter = (presenter as! Self.phInteractor.PresenterInteractor)

        router.presenter = (presenter as! Self.phRouter.PresenterRouter)
    }
}
