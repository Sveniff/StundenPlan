//
//  TimetableViewEnvironment.swift
//  VIPERAndSwiftUI
//
//  Created by Tibor Bödecs on 2019. 09. 13..
//  Copyright © 2019. Tibor Bödecs. All rights reserved.
//

import Foundation
import Combine

final class TimetableViewEnvironment: ObservableObject {

    let objectWillChange = ObservableObjectPublisher()

    @Published var user: UserData = UserData(PersistenceController.preview.container.viewContext, PersistenceController.preview.container.viewContext.persistentStoreCoordinator!){
       willSet {
            self.objectWillChange.send()
        }
    }
}
