//
//  DictionariesAccessLog+CoreDataProperties.swift
//  Learny
//
//  Created by Star Lord on 29/08/2024.
//
//

import Foundation
import CoreData


extension DictionariesAccessLog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DictionariesAccessLog> {
        return NSFetchRequest<DictionariesAccessLog>(entityName: "DictionariesAccessLog")
    }

    @NSManaged public var accessCount: Int64
    @NSManaged public var accessDate: Date?
    @NSManaged public var dictionary: DictionariesEntity?

}

extension DictionariesAccessLog : Identifiable {

}
