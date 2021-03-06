//
//  APIGetter.swift
//  StundenPlan
//
//  Created by Sven Iffland on 18.12.20.
//

import SwiftUI

struct APIGetter: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var user: UserSettings
    @FetchRequest(entity: Teacher.entity(), sortDescriptors: [])
    var storedTeachers: FetchedResults<Teacher>
    @FetchRequest(entity: Subject.entity(), sortDescriptors: [])
    var storedSubjects: FetchedResults<Subject>
    @FetchRequest(entity: BaseClass.entity(), sortDescriptors: [])
    var storedBaseClasses: FetchedResults<BaseClass>
    @FetchRequest(entity: Period.entity(), sortDescriptors: [])
    var storedPeriods: FetchedResults<Period>
    @FetchRequest(entity: Room.entity(), sortDescriptors: [])
    var storedRooms: FetchedResults<Room>
    @FetchRequest(entity: GridElement.entity(), sortDescriptors: [])
    var storedGrid: FetchedResults<GridElement>
    @FetchRequest(entity: Day.entity(), sortDescriptors: [])
    var storedays: FetchedResults<Day>
    var body: some View {
        EmptyView()
    }
    func store(){
        if user.sessionId != ""{
            var teachers: [APITeacher] = []
            var subjects: [APISubject] = []
            var baseClasses: [APIBaseClass] = []
            var periods: [APIPeriod] = []
            var rooms: [APIRoom] = []
            var grid: [APIGridElement] = []
            teachers = user.getTeachers().1!
            subjects = user.getSubjects().1!
            baseClasses = user.getKlassen().1!
            rooms = user.getRooms().1!
            periods = user.getTimetable().1!
            grid = user.getGrid().1!
            for teacher in teachers{
                if storedTeachers.contains(where: {te in te.id == teacher.id}){
                    viewContext.delete(storedTeachers.filter{$0.id == teacher.id}[0])
                }
                let newTeacher = Teacher(context: viewContext)
                newTeacher.backColor = teacher.backColor
                newTeacher.foreColor = teacher.foreColor
                newTeacher.foreName = teacher.foreName
                newTeacher.id = Int64(teacher.id)
                newTeacher.longName = teacher.longName
                newTeacher.name = teacher.name
            }

            for subject in subjects{
                if storedSubjects.contains(where: {su in su.id == subject.id}){
                    viewContext.delete(storedSubjects.filter{$0.id == subject.id}[0])
                }
                let newSubject = Subject(context: viewContext)
                newSubject.backColor = subject.backColor
                newSubject.foreColor = subject.foreColor
                newSubject.id = Int64(subject.id)
                newSubject.longName = subject.longName
                newSubject.name = subject.name
            }

            for baseClass in baseClasses{
                if storedBaseClasses.contains(where: {kl in kl.id == baseClass.id}){
                    viewContext.delete(storedBaseClasses.filter{$0.id == baseClass.id}[0])
                }
                let newBaseClass = BaseClass(context: viewContext)
                newBaseClass.backColor = baseClass.backColor
                newBaseClass.foreColor = baseClass.foreColor
                newBaseClass.id = Int64(baseClass.id)
                newBaseClass.longName = baseClass.longName
                newBaseClass.name = baseClass.name
                if baseClass.teacher1 != nil && baseClass.teacher2 != nil{
                newBaseClass.teacher1 = Int64(baseClass.teacher1!)
                newBaseClass.teacher2 = Int64(baseClass.teacher2!)
                }
            }

            for room in rooms{
                if storedRooms.contains(where: {ro in ro.id == room.id}){
                    viewContext.delete(storedRooms.filter{$0.id == room.id}[0])
                }
                let newRoom = Room(context: viewContext)
                newRoom.backColor = room.backColor
                newRoom.foreColor = room.foreColor
                newRoom.id = Int64(room.id)
                newRoom.longName = room.longName
                newRoom.name = room.name
            }
            try? viewContext.save()
            for day in 1...7{
                if storedays.contains(where: {da in da.number == day}){
                    viewContext.delete(storedays.filter({$0.number == day})[0])
                }
                let newDay = Day(context: viewContext)
                newDay.number = Int16(day)
            }
            try? viewContext.save()
            if !grid.isEmpty{
                for element in storedGrid{
                    viewContext.delete(element)
                }
                for grid in grid{
                    for element in grid.timeUnits{
                        let newElement = GridElement(context: viewContext)
                        newElement.startTime = String(element.startTime)
                        newElement.startTime!.insert(contentsOf: ":", at: newElement.startTime!.index(newElement.startTime!.endIndex, offsetBy: -2))
                        newElement.endTime = String(element.endTime)
                        newElement.endTime!.insert(contentsOf: ":", at: newElement.endTime!.index(newElement.endTime!.endIndex, offsetBy: -2))
                        newElement.name = element.name
                        newElement.day = storedays.filter({day in day.number == grid.day})[0]
                    }
                }
            }
            for period in periods{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYYMMdd"
                if storedPeriods.contains(where: {pe in pe.id == period.id}){
                    viewContext.delete(storedPeriods.filter{$0.id == period.id}[0])
                }
                let newPeriod = Period(context: viewContext)
                newPeriod.activityType = period.activityType
                newPeriod.code = period.code
                newPeriod.id = Int64(period.id)
                newPeriod.date = dateFormatter.date(from: String(period.date))
                newPeriod.endTime = String(period.endTime)
                newPeriod.endTime!.insert(contentsOf: ":", at: newPeriod.endTime!.index(newPeriod.endTime!.endIndex, offsetBy: -2))
                newPeriod.startTime = String(period.startTime)
                newPeriod.startTime!.insert(contentsOf: ":", at: newPeriod.startTime!.index(newPeriod.startTime!.endIndex, offsetBy: -2))
                newPeriod.statflags = period.statflags
                newPeriod.text = period.lstext
                newPeriod.type = period.lstype
                newPeriod.classesNS = NSSet.init(array: storedBaseClasses.filter({kl in(period.kl?.contains(where: {id in kl.id == id.id}) ?? false)}))
                newPeriod.subjectsNS = NSSet.init(array: storedSubjects.filter({su in(period.su?.contains(where: {id in su.id == id.id}) ?? false)}))
                newPeriod.teachersNS = NSSet.init(array: storedTeachers.filter({te in(period.te?.contains(where: {id in te.id == id.id}) ?? false)}))
                newPeriod.roomsNS = NSSet.init(array: storedRooms.filter({ro in(period.ro?.contains(where: {id in ro.id == id.id}) ?? false)}))
            }
            try? viewContext.save()
            for period in storedPeriods{
                var collides = 0
                for compareObj in storedPeriods.filter({$0.date == period.date}){
                    let start = Int16(period.startTime!.replacingOccurrences(of: ":", with: ""))!+1..<(Int16(period.endTime!.replacingOccurrences(of: ":", with: ""))!) ~= Int16(compareObj.startTime!.replacingOccurrences(of: ":", with: ""))!
                    let end = Int16(period.startTime!.replacingOccurrences(of: ":", with: ""))!+1..<(Int16(period.endTime!.replacingOccurrences(of: ":", with: ""))!) ~= Int16(compareObj.endTime!.replacingOccurrences(of: ":", with: ""))!
                    let overlapsStart = Int16(compareObj.startTime!.replacingOccurrences(of: ":", with: ""))! < Int16(period.startTime!.replacingOccurrences(of: ":", with: ""))!
                    let overlapsEnd = Int16(period.endTime!.replacingOccurrences(of: ":", with: ""))! < Int16(compareObj.endTime!.replacingOccurrences(of: ":", with: ""))!
                    collides += start || end || (overlapsStart && overlapsEnd) ? 1 : 0
                }
            }
        }
        try? viewContext.save()
        user.endSession()
    }
}

struct APIGetter_Previews: PreviewProvider {
    static var previews: some View {
        APIGetter()
    }
}
