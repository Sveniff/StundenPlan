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

class UserSettings: ObservableObject {
    var viewContext: NSManagedObjectContext
    //MARK: User settings
    var storedTeachers: [Teacher] = []
    var storedSubjects: [Subject] = []
    var storedBaseClasses: [BaseClass] = []
    var storedPeriods: [Period] = []
    var storedRooms: [Room] = []
    var storedGrid: [GridElement] = []
    var storedays: [Day] = []
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
            UserDefaults.standard.set(personId, forKey: "personType")
        }
    }
    @Published var klasseId: Int?{
        didSet {
            UserDefaults.standard.set(klasseId, forKey: "personType")
        }
    }
    @Published var scale: Double{
        didSet {
            UserDefaults.standard.set(scale, forKey: "scale")
        }
    }
    //MARK: Requests
    func getRequest<ResultType: Decodable, APIType: Decodable & APIResult>(method: String, params: String, _: APIType.Type, _: ResultType.Type) -> (Bool, [ResultType]?){
        var result: APIType? //var of type that conforms to answer sent by the API
        var objects: [ResultType]?// var of objects to return
        let semaphore = DispatchSemaphore (value: 0)

        let parameters = "{\"id\":\"0\",\"method\":\"\(method)\",\"params\":{\(params)},\"jsonrpc\":\"2.0\"}" // String to store params of request
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: "https://neilo.webuntis.com/WebUntis/jsonrpc.do?school=ohg-bergisch-gladbach")!,timeoutInterval: 5.0)//create request
        request.addValue("\(sessionId!)", forHTTPHeaderField: "JSSESSIONID")//add headers in fields
        request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.addValue("schoolname=\"_b2hnLWJlcmdpc2NoLWdsYWRiYWNo\"; traceId=09b751ad1fd4f0eb94caf922de4f1315da752f03; JSESSIONID=\(sessionId!)", forHTTPHeaderField: "Cookie")
        
        request.httpMethod = "POST"
        request.httpBody = postData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
    //MARK: Authentication
    func auth(){
        var result: APIAuthResult?
        let semaphore = DispatchSemaphore(value: 0)
        let parameters = "{\"id\":\"1\",\"method\":\"authenticate\",\"params\":{\"user\":\"\(username)\",\"password\":\"\(password.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\""))\", \"client\":\"web\"},\"jsonrpc\":\"2.0\"}"
        let postData = parameters.data(using: .utf8)
        var request = URLRequest(url: URL(string: "https://neilo.webuntis.com/WebUntis/jsonrpc.do?school=ohg-bergisch-gladbach")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("schoolname=\"_b2hnLWJlcmdpc2NoLWdsYWRiYWNo\"; traceId=09b751ad1fd4f0eb94caf922de4f1315da752f03; JSESSIONID=ECAD7173A723E9123ADBD05F398696B1", forHTTPHeaderField: "Cookie")
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
        semaphore.wait()
        if result != nil{
            sessionId = result!.result["sessionId"] as? String
            klasseId = result!.result["klasseId"] as? Int
            personId = result!.result["personId"] as? Int
            personType = result!.result["personType"] as? Int
            loggedIn = true
        }
        else {
            sessionId = nil
            klasseId = nil
            personId = nil
            personType = nil
            loggedIn = false
        }
    }
    func endSession() -> Bool{
        var result: APIAuthResult?
        let semaphore = DispatchSemaphore (value: 0)
        let parameters = "{\"id\":\"0\",\"method\":\"logout\",\"params\":{},\"jsonrpc\":\"2.0\"}"
        let postData = parameters.data(using: .utf8)
        var request = URLRequest(url: URL(string: "https://neilo.webuntis.com/WebUntis/jsonrpc.do?school=ohg-bergisch-gladbach")!,timeoutInterval: 10)
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
            result = try? JSONDecoder().decode(APIAuthResult.self, from: data)
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        if result != nil{
            sessionId = nil
        }
        return result != nil
    }
    func logout(){
        if endSession(){
            klasseId = nil
            personId = nil
            personType = nil
            loggedIn = false
        }
    }
    //MARK: Data Requests
    func getTeachers() -> (Bool, [APITeacher]?){
        return getRequest(method: "getTeachers", params: "", APITeacherResult.self, APITeacher.self)
    }
    func getStudents() -> (Bool, [APIStudent]?){
        return getRequest(method: "getStudents", params: "", APIStudentResult.self, APIStudent.self)
    }
    func getKlassen() -> (Bool,[APIBaseClass]?){
        return getRequest(method: "getKlassen", params: "", APIBaseClassResult.self, APIBaseClass.self)
    }
    func getSubjects() -> (Bool, [APISubject]?){
        return getRequest(method: "getSubjects", params: "", APISubjectResult.self, APISubject.self)
    }
    func getRooms() -> (Bool, [APIRoom]?){
        return getRequest(method: "getRooms", params: "", APIRoomResult.self, APIRoom.self)
    }
    func getTimetable() -> (Bool, [APIPeriod]?){
        let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYYMMdd"
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HHmm"
        return getRequest(method: "getTimetable", params: "\"options\":{\"element\": {\"id\":\(personId!),\"type\":\( personType!)},\"showSubstText\":true,\"showInfo\":true,\"showLsText\":true,\"startDate\":\"\(dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -6, to: Date())!))\",\"endDate\":\"\(dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: 6, to: Date())!))\"}", APITimetableResult.self, APIPeriod.self)
    }
    func getGrid() -> (Bool,[APIGridElement]?){
        return getRequest(method: "getTimegridUnits", params: "", APIGridResult.self, APIGridElement.self)
    }
    func store(){
        var teachers: [APITeacher] = []
        var subjects: [APISubject] = []
        var baseClasses: [APIBaseClass] = []
        var periods: [APIPeriod] = []
        var rooms: [APIRoom] = []
        var grid: [APIGridElement] = []
        teachers = getTeachers().1!
        subjects = getSubjects().1!
        baseClasses = getKlassen().1!
        rooms = getRooms().1!
        periods = getTimetable().1!
        grid = getGrid().1!
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
        fetchFromStore()
        for day in 1...7{
            if storedays.contains(where: {da in da.number == day}){
                viewContext.delete(storedays.filter({$0.number == day})[0])
            }
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
        fetchFromStore()
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
        try? viewContext.save()
        endSession()
    }
    func fetchFromStore(){
        self.storedBaseClasses = BaseClass.all(viewContext, viewContext.persistentStoreCoordinator!)
        self.storedays = Day.all(viewContext, viewContext.persistentStoreCoordinator!)
        self.storedGrid = GridElement.all(viewContext, viewContext.persistentStoreCoordinator!)
        self.storedRooms = Room.all(viewContext, viewContext.persistentStoreCoordinator!)
        self.storedPeriods = Period.all(viewContext, viewContext.persistentStoreCoordinator!)
        self.storedSubjects = Subject.all(viewContext, viewContext.persistentStoreCoordinator!)
        self.storedTeachers = Teacher.all(viewContext, viewContext.persistentStoreCoordinator!)
    }
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
        self.storedBaseClasses = BaseClass.all(viewContext, viewContext.persistentStoreCoordinator!)
        self.storedays = Day.all(viewContext, viewContext.persistentStoreCoordinator!)
        self.storedGrid = GridElement.all(viewContext, viewContext.persistentStoreCoordinator!)
        self.storedRooms = Room.all(viewContext, viewContext.persistentStoreCoordinator!)
        self.storedPeriods = Period.all(viewContext, viewContext.persistentStoreCoordinator!)
        self.storedSubjects = Subject.all(viewContext, viewContext.persistentStoreCoordinator!)
        self.storedTeachers = Teacher.all(viewContext, viewContext.persistentStoreCoordinator!)
    }
}


//MARK: API Types
struct APIAuthResult: Decodable{
    var jsonrpc: String
    var id: String
    var result: Dictionary<String, Any>
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StaticCodingKeys.self)
        self.jsonrpc = try container.decode(String.self, forKey: .jsonrpc)
        self.id = try container.decode(String.self, forKey: .id)
        self.result = try APIAuthResult.decodeResult(from: container.superDecoder(forKey: .result))
    }
    func encode(to encoder: Encoder) throws {
       var container = encoder.container(keyedBy: StaticCodingKeys.self)
       try container.encode(self.jsonrpc, forKey: .jsonrpc)
       try container.encode(self.id, forKey: .id)
       try encodeResult(to: container.superEncoder(forKey: .result))
   }
    static func decodeResult(from decoder: Decoder) throws -> [String: Any] {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var decodingResult: [String: Any] = [:]
        for key in container.allKeys {
            if let int = try? container.decode(Int.self, forKey: key) {
                decodingResult[key.stringValue] = int
            } else if let string = try? container.decode(String.self, forKey: key) {
                decodingResult[key.stringValue] = string
            }
        }
        return decodingResult
    }
    func encodeResult(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKeys.self)
        for (key, value) in result {
            switch value {
            case let int as Int:
                try container.encode(int, forKey: DynamicCodingKeys(stringValue: key)!)
            case let string as String:
                try container.encode(string, forKey: DynamicCodingKeys(stringValue: key)!)
            default:
                fatalError("unexpected type")
            }
        }
    }
    private enum StaticCodingKeys: String, CodingKey {
           case jsonrpc, id, result
       }

       private struct DynamicCodingKeys: CodingKey {
           var stringValue: String

           init?(stringValue: String) {
               self.stringValue = stringValue
           }

           var intValue: Int?

           init?(intValue: Int) {
               self.init(stringValue: "")
               self.intValue = intValue
           }
       }
}
struct APITeacherResult: Decodable, APIResult{
    var jsonrpc: String
    var id: String
    var result: [APITeacher]
}
struct APITeacher: Decodable{
    var id: Int
    var name: String
    var foreName: String?
    var longName: String?
    var foreColor: String?
    var backColor: String?
}
struct APIStudentResult: Decodable, APIResult{
    var jsonrpc: String
    var id: String
    var result: [APIStudent]
}
struct APIStudent: Decodable{
    var id: Int
    var key: String
    var name: String
    var foreName: String?
    var longName: String?
    var gender: String?
}
struct APIBaseClassResult: Decodable, APIResult{
    var jsonrpc: String
    var id: String
    var result: [APIBaseClass]
}
struct APIBaseClass: Decodable{
    var id: Int
    var name: String
    var longName: String?
    var foreColor: String?
    var backColor: String?
    var teacher1: Int?
    var teacher2: Int?
}
struct APISubjectResult: Decodable, APIResult{
    var jsonrpc: String
    var id: String
    var result: [APISubject]
}
struct APISubject: Decodable{
    var id: Int
    var name: String
    var longName: String?
    var alternateName: String?
    var active: Bool?
    var foreColor: String?
    var backColor: String?
}
struct APIRoomResult: Decodable, APIResult{
    var jsonrpc: String
    var id: String
    var result: [APIRoom]
}
struct APIRoom: Decodable{
    var id: Int
    var name: String
    var longName: String?
    var foreColor: String?
    var backColor: String?
}
struct APITimetableResult: Decodable, APIResult{
    var jsonrpc: String
    var id: String
    var result: [APIPeriod]
}
struct APIPeriod: Decodable{
    var id: Int
    var date: Int
    var startTime: Int
    var endTime: Int
    var kl: [ID]?
    var te: [ID]?
    var su: [ID]?
    var ro: [ID]?
    var info: String?
    var subsText: String?
    var lstype: String?
    var code: String?
    var lstext: String?
    var statflags: String?
    var activityType: String?
}

struct APIGridResult: Decodable, APIResult{
    var jsonrpc: String
    var id: String
    var result: [APIGridElement]
}
struct APIGridElement: Decodable{
    var day: Int
    var timeUnits: [APITimeStamp]
}
struct APITimeStamp: Decodable{
    var name: String
    var startTime: Int
    var endTime: Int
}
struct ID: Decodable{
    var id: Int
    var orgid: Int?
}


//MARK: extensions functions and protocols
protocol APIResult{
    associatedtype ResultType: Decodable
    var result: [ResultType] { get set }
}


extension BaseClass {
    static func all(_ viewContext: NSManagedObjectContext,_ coordinator: NSPersistentStoreCoordinator) -> [BaseClass] {
        let context = viewContext
        context.persistentStoreCoordinator = coordinator
        let fetchRequest: NSFetchRequest<BaseClass> = BaseClass.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            return items
        }
        catch let error as NSError {
            print("Error getting ShoppingItems: \(error.localizedDescription), \(error.userInfo)")
        }
        return [BaseClass]()
    }
}

extension Day {
    static func all(_ viewContext: NSManagedObjectContext,_ coordinator: NSPersistentStoreCoordinator) -> [Day] {
        let context = viewContext
        let fetchRequest: NSFetchRequest<Day> = Day.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            return items
        }
        catch let error as NSError {
            print("Error getting ShoppingItems: \(error.localizedDescription), \(error.userInfo)")
        }
        return [Day]()
    }
}

extension GridElement {
    static func all(_ viewContext: NSManagedObjectContext,_ coordinator: NSPersistentStoreCoordinator) -> [GridElement] {
        let context = viewContext
        let fetchRequest: NSFetchRequest<GridElement> = GridElement.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            return items
        }
        catch let error as NSError {
            print("Error getting ShoppingItems: \(error.localizedDescription), \(error.userInfo)")
        }
        return [GridElement]()
    }
}

extension Period {
    static func all(_ viewContext: NSManagedObjectContext,_ coordinator: NSPersistentStoreCoordinator) -> [Period] {
        let context = viewContext
        let fetchRequest: NSFetchRequest<Period> = Period.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            return items
        }
        catch let error as NSError {
            print("Error getting ShoppingItems: \(error.localizedDescription), \(error.userInfo)")
        }
        return [Period]()
    }
}

extension Room {
    static func all(_ viewContext: NSManagedObjectContext,_ coordinator: NSPersistentStoreCoordinator) -> [Room] {
        let context = viewContext
        let fetchRequest: NSFetchRequest<Room> = Room.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            return items
        }
        catch let error as NSError {
            print("Error getting ShoppingItems: \(error.localizedDescription), \(error.userInfo)")
        }
        return [Room]()
    }
}

extension Subject {
    static func all(_ viewContext: NSManagedObjectContext,_ coordinator: NSPersistentStoreCoordinator) -> [Subject] {
        let context = viewContext
        let fetchRequest: NSFetchRequest<Subject> = Subject.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            return items
        }
        catch let error as NSError {
            print("Error getting ShoppingItems: \(error.localizedDescription), \(error.userInfo)")
        }
        return [Subject]()
    }
}

extension Teacher {
    static func all(_ viewContext: NSManagedObjectContext,_ coordinator: NSPersistentStoreCoordinator) -> [Teacher] {
        let context = viewContext
        let fetchRequest: NSFetchRequest<Teacher> = Teacher.fetchRequest()
        do {
            let items = try context.fetch(fetchRequest)
            return items
        }
        catch let error as NSError {
            print("Error getting ShoppingItems: \(error.localizedDescription), \(error.userInfo)")
        }
        return [Teacher]()
    }
}


