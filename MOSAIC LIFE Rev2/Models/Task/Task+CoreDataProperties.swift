//
//  Task+CoreDataProperties.swift
//  MOSAIC LIFE Rev2
//
//  Created by Toshiki Hanakawa on 2022/05/15.
//
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var category: String?
    @NSManaged public var name: String?
    @NSManaged public var pt: Int32
    @NSManaged public var index: Int16

}

extension Task : Identifiable {

}
