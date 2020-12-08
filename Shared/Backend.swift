//
//  Data.swift
//  StundenPlan
//
//  Created by Sven Iffland on 26.08.20.
//

import Foundation
import SwiftUI
import Combine

class UserSettings: ObservableObject {
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
    
    func getRequest<ResultType: Decodable, APIType: Decodable & APIResult>(method: String, params: String, _: APIType.Type, _: ResultType.Type) -> (worked: Bool,result: [ResultType]?){
        var result: APIType?
        var objects: [ResultType]?
        let semaphore = DispatchSemaphore (value: 0)

        let parameters = "{\"id\":\"0\",\"method\":\"\(method)\",\"params\":{\(params)},\"jsonrpc\":\"2.0\"}"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: "https://neilo.webuntis.com/WebUntis/jsonrpc.do?school=ohg-bergisch-gladbach")!,timeoutInterval: Double.infinity)
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
            result = try? JSONDecoder().decode(APIType.self, from: data)
            objects = result?.result as? [ResultType]
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        return (objects != nil, objects)
    }
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
    
    init() {
        self.username = UserDefaults.standard.object(forKey: "username") as? String ?? ""
        self.password = UserDefaults.standard.object(forKey: "password") as? String ?? ""
        self.sessionId = UserDefaults.standard.object(forKey: "sessionId") as? String ?? ""
        self.personType = UserDefaults.standard.object(forKey: "personType") as? Int? ?? nil
        self.personId = UserDefaults.standard.object(forKey: "personId") as? Int? ?? nil
        self.klasseId = UserDefaults.standard.object(forKey: "klasseId") as? Int? ?? nil
        self.loggedIn = UserDefaults.standard.object(forKey: "loggedIn") as? Bool ?? false
        self.lastQuery = UserDefaults.standard.object(forKey: "lastQuery") as? Date? ?? nil
        self.scale = UserDefaults.standard.object(forKey: "scale") as? Double ?? 1
    }
}

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


func minutesBetweenDates(_ oldDate: Date, _ newDate: Date) -> CGFloat {

    //get both times sinces refrenced date and divide by 60 to get minutes
    let newDateMinutes = newDate.timeIntervalSinceReferenceDate/60
    let oldDateMinutes = oldDate.timeIntervalSinceReferenceDate/60

    //then return the difference
    return CGFloat(newDateMinutes - oldDateMinutes)
}

protocol APIResult{
    associatedtype ResultType: Decodable
    var result: [ResultType] { get set }
}
