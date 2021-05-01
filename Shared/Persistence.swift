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
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Stundenplan")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
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


