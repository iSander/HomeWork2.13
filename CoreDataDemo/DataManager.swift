//
//  DataManager.swift
//  CoreDataDemo
//
//  Created by Alex Sander on 11.03.2020.
//  Copyright © 2020 Alexey Efimov. All rights reserved.
//

//import Foundation
import CoreData


class DataManager {
    
    static let shared = DataManager()
    
    private var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Work with storage
    
    func save(_ taskName: String, with completion: @escaping (Task) -> Void) {
        
        guard let entityDescription = NSEntityDescription.entity(
            forEntityName: "Task",
            in: viewContext) else { return }
        
        let task = NSManagedObject(entity: entityDescription,
                                   insertInto: viewContext) as! Task
        task.name = taskName
        completion(task)
        
        saveContext()
    }
    
    func edit(_ task: Task, with name: String, with completion: @escaping (Task) -> Void) {
        task.name = name
        completion(task)
        saveContext()
    }
    
    func delete(_ task: Task) {
        viewContext.delete(task)
        saveContext()
    }
    
    func fetchData() -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch let error {
            print("Failed to fetch data", error)
            return []
        }
    }
}
