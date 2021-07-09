//
//  TaskInteractor.swift
//  VIPERAndSwiftUI
//
//  Created by Tibor Bödecs on 2019. 09. 12..
//  Copyright © 2019. Tibor Bödecs. All rights reserved.
//

import Foundation
import Combine

final class ContentViewInteractor: InteractorInterface {

    weak var presenter: ContentViewPresenterInteractorInterface!
}

extension ContentViewInteractor: ContentViewInteractorPresenterInterface {

}
