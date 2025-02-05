//
//  CoreData_Settings.swift
//  Learny
//
//  Created by Star Lord on 29/08/2024.
//

import Foundation
import CoreData
import Combine


protocol SettingsManaging{
    var settingsDidChange : PassthroughSubject<Bool, Never> { get set }

    func accessSettings(for dictionary: DictionariesEntity, selectedCardsOrder order: DictionariesSettings.CardOrder, selectedNumberOfCards: Int64, isOneSideMode: Bool) throws
    func fetchSettings(for dictionary: DictionariesEntity) -> DictionariesSettings?
}

extension CoreDataHelper: SettingsManaging {
    
    func fetchSettings(for dictionary: DictionariesEntity) -> DictionariesSettings? {
        let fetchRequest: NSFetchRequest<DictionariesSettings> = DictionariesSettings.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "dictionary == %@", dictionary)

        do {
            let settings = (try context.fetch(fetchRequest)).first
            
            guard settings != nil else {

                let settings = try self.createNewSettings(for: dictionary)
                return settings
            }
            return settings
        } catch {
            return nil
        }
    }

    func accessSettings(for dictionary: DictionariesEntity, selectedCardsOrder order: DictionariesSettings.CardOrder, selectedNumberOfCards: Int64, isOneSideMode: Bool) throws {
        guard let settings = fetchSettings(for: dictionary) else {
            do {
                let settings = try createNewSettings(for: dictionary)
                settings.selectedNumber = selectedNumberOfCards
                settings.isOneSideMode = isOneSideMode
                settings.cardOrder = order
                try saveContext()
            } catch {
                throw error
            }
            return
        }
        settings.selectedNumber = selectedNumberOfCards
        settings.isOneSideMode = isOneSideMode
        settings.cardOrder = order

        do {
            try saveContext()
            settingsDidChange.send(true)
        } catch {
            throw LogsErrorType.accessFailed(dictionary.language)
        }

    }

    //MARK: Creation
    ///Creating new log entity for passed dictionary.
    private func createNewSettings(for dictionary: DictionariesEntity) throws -> DictionariesSettings {
        let settings = DictionariesSettings(context: context)
        settings.dictionary = dictionary
        settings.selectedNumber = dictionary.numberOfCards
        settings.cardOrder = .normal
        settings.isOneSideMode = false
        
        do {
            try saveContext()
        } catch {
            throw LogsErrorType.creationFailed(dictionary.language)
        }
        return settings

    }
}
