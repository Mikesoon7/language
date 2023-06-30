//
//  DictionariesAccessLog+CoreDataProperties.swift
//  Language
//
//  Created by Star Lord on 25/06/2023.
//
//

import Foundation
import CoreData


extension DictionariesAccessLog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DictionariesAccessLog> {
        return NSFetchRequest<DictionariesAccessLog>(entityName: "DictionariesAccessLog")
    }

    @NSManaged public var accessDate: Date
    @NSManaged public var accessCount: Int64
    @NSManaged public var dictionary: DictionariesEntity?

}

extension DictionariesAccessLog : Identifiable {

}
