//
//  DictionariesEntity+CoreDataProperties.swift
//  Language
//
//  Created by Star Lord on 04/07/2023.
//
//

import Foundation
import CoreData


extension DictionariesEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DictionariesEntity> {
        return NSFetchRequest<DictionariesEntity>(entityName: "DictionariesEntity")
    }

    @NSManaged public var language: String
    @NSManaged public var numberOfCards: Int64
    @NSManaged public var order: Int64
    @NSManaged public var accessLogs: NSSet?
    @NSManaged public var words: NSSet?

}

// MARK: Generated accessors for accessLogs
extension DictionariesEntity {

    @objc(addAccessLogsObject:)
    @NSManaged public func addToAccessLogs(_ value: DictionariesAccessLog)

    @objc(removeAccessLogsObject:)
    @NSManaged public func removeFromAccessLogs(_ value: DictionariesAccessLog)

    @objc(addAccessLogs:)
    @NSManaged public func addToAccessLogs(_ values: NSSet)

    @objc(removeAccessLogs:)
    @NSManaged public func removeFromAccessLogs(_ values: NSSet)

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
