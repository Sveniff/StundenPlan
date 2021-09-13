//
//  TaskInteractor.swift
//  VIPERAndSwiftUI
//
//  Created by Tibor Bödecs on 2019. 09. 12..
//  Copyright © 2019. Tibor Bödecs. All rights reserved.
//

import Foundation
import Combine

final class TimetableViewInteractor: InteractorInterface {

    weak var presenter: TimetableViewPresenterInteractorInterface!
}

extension TimetableViewInteractor: TimetableViewInteractorPresenterInterface {

}
