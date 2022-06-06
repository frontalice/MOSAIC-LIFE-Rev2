//
//  Item+CoreDataProperties.swift
//  MOSAIC LIFE Rev2
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var category: String
    @NSManaged public var index: Int16
    @NSManaged public var name: String
    @NSManaged public var pt: Int32
    @NSManaged public var type: String

}

extension Item : Identifiable {

}
