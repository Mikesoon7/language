//
//  CoreData_Settings.swift
//  Learny
//
//  Created by Star Lord on 29/08/2024.
//

import Foundation
import CoreData


protocol SettingsManaging{
    func accessSettings(for dictionary: DictionariesEntity, with random: Bool, numberofCards: Int64, oneSideMode: Bool) throws
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

    func accessSettings(for dictionary: DictionariesEntity, with random: Bool, numberofCards: Int64, oneSideMode: Bool) throws {
        guard let settings = fetchSettings(for: dictionary) else {
            do {
                let settings = try createNewSettings(for: dictionary)
                settings.selectedNumber = numberofCards
                settings.isOneSideMode = oneSideMode
                settings.isRandom = random
                try saveContext()
            } catch {
                throw error
            }
            return
        }
        settings.selectedNumber = numberofCards
        settings.isOneSideMode = oneSideMode
        settings.isRandom = random

        do {
            try saveContext()
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
        settings.isRandom = false
        settings.isOneSideMode = false
        
        do {
            try saveContext()
        } catch {
            throw LogsErrorType.creationFailed(dictionary.language)
        }
        return settings

    }
}
