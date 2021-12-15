//
//  Data.swift
//  StundenPlan
//
//  Created by Sven Iffland on 26.08.20.
//

import Foundation
import SwiftUI
import Combine
import CoreData

class UserData: ObservableObject {
    //MARK: settings and user info
    @Published var schoolDomain: String {
        didSet {
            UserDefaults.standard.set(schoolDomain, forKey: "schoolDomain")
        }
    }
    @Published var lastQuery: Date? {
        didSet {
            UserDefaults.standard.set(lastQuery, forKey: "lastQuery")
        }
    }
    @Published var loggedIn: Bool {
        didSet {
            UserDefaults.standard.set(loggedIn, forKey: "loggedIn")
        }
    }
    @Published var username: String {
        didSet {
            UserDefaults.standard.set(username, forKey: "username")
        }
    }
    @Published var password: String {
        didSet {
            UserDefaults.standard.set(password, forKey: "password")
        }
    }
    @Published var sessionId: String?{
        didSet {
            UserDefaults.standard.set(sessionId, forKey: "sessionId")
        }
    }
    @Published var personType: Int?{
        didSet {
            UserDefaults.standard.set(personType, forKey: "personType")
        }
    }
    @Published var personId: Int?{
        didSet {
            UserDefaults.standard.set(personId, forKey: "personId")
        }
    }
    @Published var klasseId: Int?{
        didSet {
            UserDefaults.standard.set(klasseId, forKey: "klasseId")
        }
    }
    @Published var scale: Double{
        didSet {
            UserDefaults.standard.set(scale, forKey: "scale")
        }
    }
    @Published var calendar: Calendar
    private var teachers: [APITeacher] = []
    private var subjects: [APISubject] = []
    private var baseClasses: [APIBaseClass] = []
    private var periods: [APIPeriod] = []
    private var rooms: [APIRoom] = []
    private var grid: [APIGridElement] = []
    
    //MARK: public methods
    func startSession(){
        var result: APIAuthResult?
        let semaphore = DispatchSemaphore(value: 0)
        let parameters = "{\"id\":\"1\",\"method\":\"authenticate\",\"params\":{\"user\":\"\(username)\",\"password\":\"\(password.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\""))\", \"client\":\"web\"},\"jsonrpc\":\"2.0\"}"
        let postData = parameters.data(using: .utf8)
        var request = URLRequest(url: URL(string: "https://neilo.webuntis.com/WebUntis/jsonrpc.do?school=ohg-bergisch-gladbach")!,timeoutInterval: 1.0)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            print(String(data: data, encoding: .utf8)!)
            result = try? JSONDecoder().decode(APIAuthResult.self, from: data)
            semaphore.signal()
        }
        task.resume()
        semaphore.wait(timeout: DispatchTime(uptimeNanoseconds: 1000))
        if result != nil{
            sessionId = result!.result.sessionId
            klasseId = result!.result.klasseId
            personId = result!.result.personId
            personType = result!.result.personType
            loggedIn = true
        }
        else {
            sessionId = nil
        }
    }
    
    func logout(){
        endSession()
        klasseId = nil
        personId = nil
        personType = nil
        loggedIn = false
    }
    
    func store() {
        fetchFromAPI()
        for teacher in storedTeachers{
            viewContext.delete(teacher)
        }
        for teacher in teachers{
            let newTeacher = Teacher(context: viewContext)
            newTeacher.backColor = teacher.backColor
            newTeacher.foreColor = teacher.foreColor
            newTeacher.foreName = teacher.foreName
            newTeacher.id = Int64(teacher.id)
            newTeacher.longName = teacher.longName
            newTeacher.name = teacher.name
        }
        for subject in storedSubjects{
            viewContext.delete(subject)
        }
        for subject in subjects{
            let newSubject = Subject(context: viewContext)
            newSubject.backColor = subject.backColor
            newSubject.foreColor = subject.foreColor
            newSubject.id = Int64(subject.id)
            newSubject.longName = subject.longName
            newSubject.name = subject.name
        }
        for baseclass in storedBaseClasses{
            viewContext.delete(baseclass)
        }
        for baseClass in baseClasses{
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
        for room in storedRooms {
            viewContext.delete(room)
        }
        for room in rooms{
            let newRoom = Room(context: viewContext)
            newRoom.backColor = room.backColor
            newRoom.foreColor = room.foreColor
            newRoom.id = Int64(room.id)
            newRoom.longName = room.longName
            newRoom.name = room.name
        }
        try? viewContext.save()
        fetchFromStore()
        for day in storedays{
            viewContext.delete(day)
        }
        for day in 1...7{
            let newDay = Day(context: viewContext)
            newDay.number = Int16(day)
        }
        try? viewContext.save()
        fetchFromStore()
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
        for period in storedPeriods{
            viewContext.delete(period)
        }
        for period in periods{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYYMMdd"
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
        lastQuery = Date()
    }

    func endSession(){
        let semaphore = DispatchSemaphore (value: 0)
        let parameters = "{\"id\":\"0\",\"method\":\"logout\",\"params\":{},\"jsonrpc\":\"2.0\"}"
        let postData = parameters.data(using: .utf8)
        var request = URLRequest(url: URL(string: schoolDomain)!,timeoutInterval: 1)
        request.addValue("\(sessionId!)", forHTTPHeaderField: "JSSESSIONID")
        request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.addValue("schoolname=\"_b2hnLWJlcmdpc2NoLWdsYWRiYWNo\"; traceId=09b751ad1fd4f0eb94caf922de4f1315da752f03; JSESSIONID=\(sessionId!)", forHTTPHeaderField: "Cookie")
        request.httpMethod = "POST"
        request.httpBody = postData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            print(String(data: data, encoding: .utf8)!)
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        sessionId = nil
    }
    
    //MARK: private member
    private var viewContext: NSManagedObjectContext
    private var storedTeachers: [Teacher] = []
    private var storedSubjects: [Subject] = []
    private var storedBaseClasses: [BaseClass] = []
    private var storedPeriods: [Period] = []
    private var storedRooms: [Room] = []
    private var storedGrid: [GridElement] = []
    private var storedays: [Day] = []

    //MARK: helper methods
    private func getRequest<ResultType: Codable, APIType: Codable & APIResult>(method: String, params: String, _: APIType.Type, _: ResultType.Type) -> (Bool, [ResultType]?){
        var result: APIType? //var of type that conforms to answer sent by the API
        var objects: [ResultType]?// var of objects to return
        let semaphore = DispatchSemaphore (value: 0)

        let parameters = "{\"id\":\"0\",\"method\":\"\(method)\",\"params\":{\(params)},\"jsonrpc\":\"2.0\"}" // String to store params of request
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: schoolDomain)!,timeoutInterval: 1)//create request
        request.addValue("\(sessionId!)", forHTTPHeaderField: "JSSESSIONID")//add headers in fields
        request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard let data = data else {//execute if the request was succesful
            print(String(describing: error))//print error
            return
        }
            print(String(data: data, encoding: .utf8)!)//print data response of server
            result = try? JSONDecoder().decode(APIType.self, from: data)//decode result into
            objects = result?.result as? [ResultType]
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        return (objects != nil, objects)
    }
    
    private func getTeachers() -> (Bool, [APITeacher]?){
        return getRequest(method: "getTeachers", params: "", APITeacherResult.self, APITeacher.self)
    }
    private func getStudents() -> (Bool, [APIStudent]?){
        return getRequest(method: "getStudents", params: "", APIStudentResult.self, APIStudent.self)
    }
    private func getKlassen() -> (Bool,[APIBaseClass]?){
        return getRequest(method: "getKlassen", params: "", APIBaseClassResult.self, APIBaseClass.self)
    }
    private func getSubjects() -> (Bool, [APISubject]?){
        return getRequest(method: "getSubjects", params: "", APISubjectResult.self, APISubject.self)
    }
    private func getRooms() -> (Bool, [APIRoom]?){
        return getRequest(method: "getRooms", params: "", APIRoomResult.self, APIRoom.self)
    }
    private func getGrid() -> (Bool,[APIGridElement]?){
        return getRequest(method: "getTimegridUnits", params: "", APIGridResult.self, APIGridElement.self)
    }
    private func getTimetable() -> (Bool, [APIPeriod]?){
        let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYYMMdd"
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HHmm"
        return getRequest(method: "getTimetable", params: "\"options\":{\"element\": {\"id\":\(personId!),\"type\":\( personType!)},\"showSubstText\":true,\"showInfo\":true,\"showLsText\":true,\"startDate\":\"\(dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -(7+calendar.component(.weekday, from: Date())), to: Date())!))\",\"endDate\":\"\(dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: 14-calendar.component(.weekday, from: Date()), to: Date())!))\"}", APITimetableResult.self, APIPeriod.self)
    }
    private func fetchFromStore(){
        self.storedBaseClasses = BaseClass.all(viewContext, viewContext.persistentStoreCoordinator!)
        self.storedays = Day.all(viewContext, viewContext.persistentStoreCoordinator!)
        self.storedGrid = GridElement.all(viewContext, viewContext.persistentStoreCoordinator!)
        self.storedRooms = Room.all(viewContext, viewContext.persistentStoreCoordinator!)
        self.storedPeriods = Period.all(viewContext, viewContext.persistentStoreCoordinator!)
        self.storedSubjects = Subject.all(viewContext, viewContext.persistentStoreCoordinator!)
        self.storedTeachers = Teacher.all(viewContext, viewContext.persistentStoreCoordinator!)
    }
    private func fetchFromAPI() {
        teachers = getTeachers().1!
        subjects = getSubjects().1!
        baseClasses = getKlassen().1!
        rooms = getRooms().1!
        periods = getTimetable().1!
        grid = getGrid().1!
    }

    //MARK: Initializer
    init(_ viewContext: NSManagedObjectContext,_ coordinator: NSPersistentStoreCoordinator) {
        self.viewContext = viewContext
        self.viewContext.persistentStoreCoordinator = coordinator
        self.username = UserDefaults.standard.object(forKey: "username") as? String ?? ""
        self.password = UserDefaults.standard.object(forKey: "password") as? String ?? ""
        self.sessionId = UserDefaults.standard.object(forKey: "sessionId") as? String ?? ""
        self.personType = UserDefaults.standard.object(forKey: "personType") as? Int? ?? nil
        self.personId = UserDefaults.standard.object(forKey: "personId") as? Int? ?? nil
        self.klasseId = UserDefaults.standard.object(forKey: "klasseId") as? Int? ?? nil
        self.loggedIn = UserDefaults.standard.object(forKey: "loggedIn") as? Bool ?? false
        self.lastQuery = UserDefaults.standard.object(forKey: "lastQuery") as? Date? ?? nil
        self.scale = UserDefaults.standard.object(forKey: "scale") as? Double ?? 1
        self.schoolDomain = UserDefaults.standard.object(forKey: "schoolDoamin") as? String ?? "https://neilo.webuntis.com/WebUntis/jsonrpc.do?school=ohg-bergisch-gladbach"
        self.storedBaseClasses = BaseClass.all(viewContext, viewContext.persistentStoreCoordinator!)
        self.storedays = Day.all(viewContext, viewContext.persistentStoreCoordinator!)
        self.storedGrid = GridElement.all(viewContext, viewContext.persistentStoreCoordinator!)
        self.storedRooms = Room.all(viewContext, viewContext.persistentStoreCoordinator!)
        self.storedPeriods = Period.all(viewContext, viewContext.persistentStoreCoordinator!)
        self.storedSubjects = Subject.all(viewContext, viewContext.persistentStoreCoordinator!)
        self.storedTeachers = Teacher.all(viewContext, viewContext.persistentStoreCoordinator!)
        self.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        self.calendar.firstWeekday = 7
        self.calendar.locale = Locale(identifier: "de_DE")
    }

    private struct APIAuthResult: Codable {
        var jsonrpc: String
        var id: String
        var result: APIAuth
    }
    private struct APIAuth: Codable{
        let sessionId: String
        let personType: Int
        let klasseId: Int
        let personId: Int
    }
    private struct APITeacherResult: Codable, APIResult{
        let jsonrpc: String
        let id: String
        var result: [APITeacher]
    }
    private struct APITeacher: Codable{
        let id: Int
        let name: String
        let foreName: String?
        let longName: String?
        let foreColor: String?
        let backColor: String?
    }
    private struct APIStudentResult: Codable, APIResult{
        let jsonrpc: String
        let id: String
        var result: [APIStudent]
    }
    private struct APIStudent: Codable{
        let id: Int
        let key: String
        let name: String
        let foreName: String?
        let longName: String?
        let gender: String?
    }
    private struct APIBaseClassResult: Codable, APIResult{
        let jsonrpc: String
        let id: String
        var result: [APIBaseClass]
    }
    private struct APIBaseClass: Codable{
        let id: Int
        let name: String
        let longName: String?
        let foreColor: String?
        let backColor: String?
        let teacher1: Int?
        let teacher2: Int?
    }
    private struct APISubjectResult: Codable, APIResult{
        let jsonrpc: String
        let id: String
        var result: [APISubject]
    }
    private struct APISubject: Codable{
        let id: Int
        let name: String
        let longName: String?
        let alternateName: String?
        let active: Bool?
        let foreColor: String?
        let backColor: String?
    }
    private struct APIRoomResult: Codable, APIResult{
        let jsonrpc: String
        let id: String
        var result: [APIRoom]
    }
    private struct APIRoom: Codable{
        let id: Int
        let name: String
        let longName: String?
        let foreColor: String?
        let backColor: String?
    }
    private struct APITimetableResult: Codable, APIResult{
        let jsonrpc: String
        let id: String
        var result: [APIPeriod]
    }
    private struct APIPeriod: Codable{
        let id: Int
        let date: Int
        let startTime: Int
        let endTime: Int
        let kl: [ID]?
        let te: [ID]?
        let su: [ID]?
        let ro: [ID]?
        let info: String?
        let subsText: String?
        let lstype: String?
        let code: String?
        let lstext: String?
        let statflags: String?
        let activityType: String?
    }

    private struct APIGridResult: Codable, APIResult{
        let jsonrpc: String
        let id: String
        var result: [APIGridElement]
    }
    private struct APIGridElement: Codable{
        let day: Int
        let timeUnits: [APITimeStamp]
    }
    private struct APITimeStamp: Codable{
        let name: String
        let startTime: Int
        let endTime: Int
    }
    private struct ID: Codable{
        let id: Int
        let orgid: Int?
    }
}

fileprivate protocol APIResult{
    associatedtype ResultType: Codable
    var result: [ResultType] { get set }
}
