//
//  WordsEntity+CoreDataProperties.swift
//  Language
//
//  Created by Star Lord on 22/04/2023.
//
//

import Foundation
import CoreData


extension WordsEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WordsEntity> {
        return NSFetchRequest<WordsEntity>(entityName: "WordsEntity")
    }

    @NSManaged public var identifier: UUID?
    @NSManaged public var word: String?
    @NSManaged public var meaning: String?
    @NSManaged public var dictionaries: NSSet?

}

// MARK: Generated accessors for dictionaries
extension WordsEntity {

    @objc(addDictionariesObject:)
    @NSManaged public func addToDictionaries(_ value: DictionariesEntity)

    @objc(removeDictionariesObject:)
    @NSManaged public func removeFromDictionaries(_ value: DictionariesEntity)

    @objc(addDictionaries:)
    @NSManaged public func addToDictionaries(_ values: NSSet)

    @objc(removeDictionaries:)
    @NSManaged public func removeFromDictionaries(_ values: NSSet)

}

extension WordsEntity : Identifiable {

}
