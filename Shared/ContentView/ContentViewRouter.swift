//
//  TaskRouter.swift
//  VIPERAndSwiftUI
//
//  Created by Tibor Bödecs on 2019. 09. 12..
//  Copyright © 2019. Tibor Bödecs. All rights reserved.
//

import Foundation
import UIKit

final class ContentViewRouter: RouterInterface {

    weak var presenter: ContentViewPresenterRouterInterface!

    weak var viewController: UIViewController?
}

extension ContentViewRouter: ContentViewRouterPresenterInterface {

}
