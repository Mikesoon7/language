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
                print ("settings are empty and we trying to create new one")

                let settings = try self.createNewSettings(for: dictionary)
                print("Settings were created and returning new sequence")
                return settings
            }
            print("Settings seems to exist")
            return settings
        } catch {
            return nil
        }
    }

    func accessSettings(for dictionary: DictionariesEntity, with random: Bool, numberofCards: Int64, oneSideMode: Bool) throws {
        guard let settings = fetchSettings(for: dictionary) else {
            do {
                print( " the error is here ")
                let settings = try createNewSettings(for: dictionary)
                settings.number = numberofCards
                settings.oneSideMode = oneSideMode
                settings.random = random
                try saveContext()
            } catch {
                throw error
            }
            return
        }
//        let settings = fetchSettings(for: dictionary)
        print("the settings exist, but does not save properly")
        settings.number = numberofCards
        settings.oneSideMode = oneSideMode
        settings.random = random

        
        print(settings)
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
        settings.number = dictionary.numberOfCards
        print(settings.number)
        settings.random = false
        settings.oneSideMode = false
        
        print("settings were initialized")
        do {
            try saveContext()
        } catch {
            throw LogsErrorType.creationFailed(dictionary.language)
        }
        return settings

    }
}
