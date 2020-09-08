//
//  StundenPlanApp.swift
//  Shared
//
//  Created by Sven Iffland on 25.08.20.
//

import SwiftUI

@main
struct StundenPlanApp: App {
    let persistenceController = PersistenceController.shared
    @ObservedObject var user = UserSettings()
    var authResult: (Bool, APIAuthResult?) = (false, nil)
    var teachers: [APITeacher] = []
    var baseClasses: [APIBaseClass] = []
    var subjects: [APISubject] = []
    var periods: [APIPeriod] = []
    @FetchRequest(entity: Teacher.entity(), sortDescriptors: [])
    var storedTeachers: FetchedResults<Teacher>
    @FetchRequest(entity: Subject.entity(), sortDescriptors: [])
    var storedsubjects: FetchedResults<Subject>
    init() {
        if user.username != "" && user.password != "" {
            authResult = auth(user.username, user.password)
            if authResult.0{
                user.sessionId = authResult.1!.result["sessionId"] as! String
                user.klasseId = authResult.1!.result["klasseId"] as? Int
                user.personId = authResult.1!.result["personId"] as? Int
                user.personType = authResult.1!.result["personType"] as? Int
                user.loggedIn = true
                teachers = getTeachers(user.sessionId).1!
                subjects = getSubjects(user.sessionId).1!
                baseClasses = getKlassen(user.sessionId).1!
                periods = getTimetable(id: user.personId!, type: user.personType!, user.sessionId).1!
                
                
                for teacher in teachers{
                    if !storedTeachers.filter({$0.id == teacher.id}).isEmpty{
                        persistenceController.container.viewContext.delete(storedTeachers.filter{$0.id == teacher.id}[0])
                    }
                    let newTeacher = Teacher(context: persistenceController.container.viewContext)
                    newTeacher.backColor = teacher.backColor
                    newTeacher.foreColor = teacher.foreColor
                    newTeacher.foreName = teacher.foreName
                    newTeacher.id = Int64(teacher.id)
                    newTeacher.longName = teacher.longName
                    newTeacher.name = teacher.name
                }
                
                for subject in subjects{
                    if !storedsubjects.filter({$0.id == subject.id}).isEmpty{
                        persistenceController.container.viewContext.delete(storedsubjects.filter{$0.id == subject.id}[0])
                    }
                    let newSubject = Subject(context: persistenceController.container.viewContext)
                    newSubject.backColor = subject.backColor
                    newSubject.foreColor = subject.foreColor
                    newSubject.id = Int64(subject.id)
                    newSubject.longName = subject.longName
                    newSubject.name = subject.name
                }
                
            }
            else{
                user.loggedIn = false
            }
        }
        else{
            user.loggedIn = false
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if user.loggedIn{
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(user)
            }
            else{
                login()
                    .environmentObject(user)
            }
        }
    }
}
