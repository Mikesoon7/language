//
//  Words+CoreDataProperties.swift
//  
//
//  Created by Star Lord on 22/04/2023.
//
//

import Foundation
import CoreData


extension Words {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Words> {
        return NSFetchRequest<Words>(entityName: "Words")
    }

    @NSManaged public var identifier: UUID?
    @NSManaged public var word: String?
    @NSManaged public var meaning: String?
    @NSManaged public var dictionaries: Dictionaries?

}
