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
    
    // Создание объекта Managed Object Context
    //private let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Work with storage
    
    func save(_ taskName: String, with completion: @escaping (Task) -> Void) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: persistentContainer.viewContext) else { return }
        let task = NSManagedObject(entity: entityDescription, insertInto: persistentContainer.viewContext) as! Task
        task.name = taskName
        
        do {
            try persistentContainer.viewContext.save()
            completion(task)
        } catch let error {
            print(error)
        }
    }
    
    func edit(_ task: Task, with name: String, with completion: @escaping (Task) -> Void) {
        do {
            task.setValue(name, forKey: "name")
            try persistentContainer.viewContext.save()
            completion(task)
        } catch let error {
            print(error)
        }
    }
    
    func delete(_ task: Task, with completion: @escaping (Bool) -> Void) {
        do {
            persistentContainer.viewContext.delete(task)
            try persistentContainer.viewContext.save()
            completion(true)
        } catch let error {
            completion(false)
            print(error)
        }
    }
    
    func fetchData(with completion: @escaping ([Task]) -> Void) {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()

        do {
            let tasks = try persistentContainer.viewContext.fetch(fetchRequest)
            completion(tasks)
        } catch let error {
            print(error)
        }
    }
}
