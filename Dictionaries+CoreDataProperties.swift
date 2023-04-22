//
//  Dictionaries+CoreDataProperties.swift
//  
//
//  Created by Star Lord on 22/04/2023.
//
//

import Foundation
import CoreData


extension Dictionaries {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Dictionaries> {
        return NSFetchRequest<Dictionaries>(entityName: "Dictionaries")
    }

    @NSManaged public var language: String?
    @NSManaged public var numberOfCards: String?
    @NSManaged public var words: Words?

}
