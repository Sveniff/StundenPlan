//
//  Persistence.swift
//  Shared
//
//  Created by Sven Iffland on 25.08.20.
//

import CoreData
import Combine

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let user = UserData(viewContext, viewContext.persistentStoreCoordinator!)
        
        do {
            user.store()
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Database")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}

extension Period{
    public var subjects: [Subject]{
        Array(subjectsNS as? Set<Subject> ?? [])
    }
    public var teachers: [Teacher]{
        return Array(teachersNS as? Set<Teacher> ?? [])
    }
    public var classes: [BaseClass]{
        return Array(classesNS as? Set<BaseClass> ?? [])
    }
    public var rooms: [Room]{
        return Array(roomsNS as? Set<Room> ?? [])
    }
}

extension Day{
    public var elements: [GridElement]{
        Array(elementsNS as? Set<GridElement> ?? [])
    }
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
            print("Error : \(error.localizedDescription), \(error.userInfo)")
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
            print("Error : \(error.localizedDescription), \(error.userInfo)")
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
            print("Error : \(error.localizedDescription), \(error.userInfo)")
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
            print("Error : \(error.localizedDescription), \(error.userInfo)")
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
            print("Error : \(error.localizedDescription), \(error.userInfo)")
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
            print("Error : \(error.localizedDescription), \(error.userInfo)")
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
            print("Error : \(error.localizedDescription), \(error.userInfo)")
        }
        return [Teacher]()
    }
}


