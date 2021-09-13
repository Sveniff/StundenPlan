//
//  TaskRouter.swift
//  VIPERAndSwiftUI
//
//  Created by Tibor Bödecs on 2019. 09. 12..
//  Copyright © 2019. Tibor Bödecs. All rights reserved.
//

import Foundation
import UIKit

final class TimetableViewRouter: RouterInterface {

    weak var presenter: TimetableViewPresenterRouterInterface!

    weak var viewController: UIViewController?
}

extension TimetableViewRouter: TimetableViewRouterPresenterInterface {

}
