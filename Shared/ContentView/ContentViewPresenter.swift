//
//  TaskPresenter.swift
//  VIPERAndSwiftUI
//
//  Created by Tibor Bödecs on 2019. 09. 12..
//  Copyright © 2019. Tibor Bödecs. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

final class ContentViewPresenter: PresenterInterface {

    var router: ContentViewRouterPresenterInterface!
    var interactor: ContentViewInteractorPresenterInterface!
    weak var viewModel: ContentViewViewModel!

    var request: AnyCancellable?
}

extension ContentViewPresenter: ContentViewPresenterRouterInterface {

}

extension ContentViewPresenter: ContentViewPresenterInteractorInterface {

}

extension ContentViewPresenter: ContentViewPresenterViewInterface {

}
