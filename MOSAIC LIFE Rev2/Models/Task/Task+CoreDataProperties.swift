//
//  Task+CoreDataProperties.swift
//  MOSAIC LIFE Rev2
//
//  Created by Toshiki Hanakawa on 2022/04/20.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var name: String?
    @NSManaged public var category: String?
    @NSManaged public var pt: Int32
    
    public static func addNewTask(context: NSManagedObjectContext!, name: String, pt: Int, category: String) -> Bool {
        let newTask = Task(context: context)
        newTask.name = name
        newTask.pt = Int32(pt)
        newTask.category = category
        do {
            try context.save()
            print("context saved")
        } catch {
            print("context not saved:\(error.localizedDescription)")
            return false
        }
        return true
    }

}

extension Task : Identifiable {

}
