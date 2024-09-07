//
//  WordsEntity+CoreDataProperties.swift
//  Learny
//
//  Created by Star Lord on 29/08/2024.
//
//

import Foundation
import CoreData


extension WordsEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WordsEntity> {
        return NSFetchRequest<WordsEntity>(entityName: "WordsEntity")
    }

    @NSManaged public var identifier: UUID?
    @NSManaged public var meaning: String
    @NSManaged public var order: Int64
    @NSManaged public var word: String
    @NSManaged public var dictionary: DictionariesEntity?

}

extension WordsEntity : Identifiable {

}
