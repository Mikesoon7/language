//
//  DictionariesEntity+CoreDataProperties.swift
//  Language
//
//  Created by Star Lord on 22/04/2023.
//
//

import Foundation
import CoreData


extension DictionariesEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DictionariesEntity> {
        return NSFetchRequest<DictionariesEntity>(entityName: "DictionariesEntity")
    }

    @NSManaged public var language: String?
    @NSManaged public var numberOfCards: String?
    @NSManaged public var words: NSSet?
    @NSManaged public var order: Int64?

}

// MARK: Generated accessors for words
extension DictionariesEntity {

    @objc(addWordsObject:)
    @NSManaged public func addToWords(_ value: WordsEntity)

    @objc(removeWordsObject:)
    @NSManaged public func removeFromWords(_ value: WordsEntity)

    @objc(addWords:)
    @NSManaged public func addToWords(_ values: NSSet)

    @objc(removeWords:)
    @NSManaged public func removeFromWords(_ values: NSSet)

}

extension DictionariesEntity : Identifiable {

}
