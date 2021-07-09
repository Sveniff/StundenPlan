//
//  TaskView.swift
//  VIPERAndSwiftUI
//
//  Created by Tibor Bödecs on 2019. 09. 12..
//  Copyright © 2019. Tibor Bödecs. All rights reserved.
//

import Combine
import SwiftUI

final class ContentViewViewModel: ObservableObject {

    let objectWillChange = ObservableObjectPublisher()

    @FetchRequest(entity: Teacher.entity(), sortDescriptors: [])
    var storedTeachers: FetchedResults<Teacher>{
        willSet {
            self.objectWillChange.send()
        }
    }
    @FetchRequest(entity: Subject.entity(), sortDescriptors: [])
    var storedSubjects: FetchedResults<Subject>{
        willSet {
            self.objectWillChange.send()
        }
    }
    @FetchRequest(entity: BaseClass.entity(), sortDescriptors: [])
    var storedBaseClasses: FetchedResults<BaseClass>{
        willSet {
            self.objectWillChange.send()
        }
    }
    @FetchRequest(entity: Period.entity(), sortDescriptors: [])
    var storedPeriods: FetchedResults<Period>{
        willSet {
            self.objectWillChange.send()
        }
    }
    @FetchRequest(entity: Room.entity(), sortDescriptors: [])
    var storedRooms: FetchedResults<Room>
    {
        willSet {
            self.objectWillChange.send()
        }
    }
    @FetchRequest(entity: GridElement.entity(), sortDescriptors: [])
    var storedGrid: FetchedResults<GridElement>{
        willSet {
            self.objectWillChange.send()
        }
    }
    @FetchRequest(entity: Day.entity(), sortDescriptors: [])
    var storedays: FetchedResults<Day>{
        willSet {
            self.objectWillChange.send()
        }
    }
}
