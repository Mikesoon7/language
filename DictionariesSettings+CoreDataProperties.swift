//
//  DictionariesSettings+CoreDataProperties.swift
//  Learny
//
//  Created by Star Lord on 29/08/2024.
//
//

import Foundation
import CoreData


extension DictionariesSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DictionariesSettings> {
        return NSFetchRequest<DictionariesSettings>(entityName: "DictionariesSettings")
    }

    @NSManaged public var number: Int64
    @NSManaged public var oneSideMode: Bool
    @NSManaged public var random: Bool
    @NSManaged public var dictionary: DictionariesEntity?

}

extension DictionariesSettings : Identifiable {

}
