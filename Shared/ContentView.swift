//
//  ContentView.swift
//  Shared
//
//  Created by Sven Iffland on 25.08.20.
//

import SwiftUI
import CoreData

struct ContentView: View {
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
    var body: some View {
        List{
            ForEach(storedPeriods, id: \.self){
                period in
                ForEach(period.subjects, id: \.self){
                    su in
                    Text(su.longName ?? "")
                }
            }
        }
        .onAppear{
            if user.sessionId != ""{
                var teachers: [APITeacher] = []
                var subjects: [APISubject] = []
                var baseClasses: [APIBaseClass] = []
                var periods: [APIPeriod] = []
                var rooms: [APIRoom] = []
                teachers = getTeachers(user.sessionId).1!
                subjects = getSubjects(user.sessionId).1!
                baseClasses = getKlassen(user.sessionId).1!
                rooms = getRooms(user.sessionId).1!
                periods = getTimetable(id: user.personId!, type: user.personType!, user.sessionId).1!
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
                for period in periods{
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "YYYYMMdd"
                    let timeFormatter = DateFormatter()
                    timeFormatter.dateFormat = "HHmm"
                    if storedPeriods.contains(where: {pe in pe.id == period.id}){
                        viewContext.delete(storedPeriods.filter{$0.id == period.id}[0])
                    }
                    let newPeriod = Period(context: viewContext)
                    newPeriod.activityType = period.activityType
                    newPeriod.code = period.code
                    newPeriod.id = Int64(period.id)
                    newPeriod.date = dateFormatter.date(from: String(period.date))
                    newPeriod.endTime = timeFormatter.date(from: String(period.endTime))
                    newPeriod.startTime = timeFormatter.date(from: String(period.startTime))
                    newPeriod.statflags = period.statflags
                    newPeriod.text = period.lstext
                    newPeriod.type = period.lstype
                    newPeriod.classesNS = NSSet.init(array: storedBaseClasses.filter({kl in(period.kl?.contains(where: {id in kl.id == id.id}) ?? false)}))
                    newPeriod.subjectsNS = NSSet.init(array: storedSubjects.filter({su in(period.su?.contains(where: {id in su.id == id.id}) ?? false)}))
                    newPeriod.teachersNS = NSSet.init(array: storedTeachers.filter({te in(period.te?.contains(where: {id in te.id == id.id}) ?? false)}))
                    newPeriod.roomsNS = NSSet.init(array: storedRooms.filter({ro in(period.ro?.contains(where: {id in ro.id == id.id}) ?? false)}))
                }
            }
            try? viewContext.save()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let user = UserSettings()
        return ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(user)
    }
}
