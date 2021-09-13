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

final class TimetableViewPresenter: PresenterInterface {

    var router: TimetableViewRouterPresenterInterface!
    var interactor: TimetableViewInteractorPresenterInterface!
    weak var viewModel: TimetableViewViewModel!

    var request: AnyCancellable?
}

extension TimetableViewPresenter: TimetableViewPresenterRouterInterface {

}

extension TimetableViewPresenter: TimetableViewPresenterInteractorInterface {

}

extension TimetableViewPresenter: TimetableViewPresenterViewInterface {

}
