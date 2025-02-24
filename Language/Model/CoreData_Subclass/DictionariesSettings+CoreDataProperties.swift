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

    @NSManaged public var selectedNumber: Int64
    @NSManaged public var isOneSideMode: Bool
    @NSManaged public var cardsOrderRawValue: Int64
    @NSManaged public var dictionary: DictionariesEntity?

}

extension DictionariesSettings : Identifiable {
    
}
//Custom properties extension
extension DictionariesSettings {
    enum CardOrder: Int64 {
            case normal = 0
            case random = 1
            case reverse = 2
        }

    var cardOrder: CardOrder {
            get { CardOrder(rawValue: cardsOrderRawValue) ?? .normal }
            set { cardsOrderRawValue = newValue.rawValue }
        }

}
