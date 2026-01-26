//
//  CoreDataMethods.swift
//  Language
//
//  Created by Star Lord on 22/04/2023.
//
//TODO: Polish

import Foundation
import CoreData
import UIKit
import Combine

typealias Dictionary_WordsManager = DictionaryManaging & WordsManaging
typealias Dictionary_Words_LogsManager = DictionaryManaging & WordsManaging & LogsManaging
typealias DictionaryFullAccess = DictionaryManaging & WordsManaging & LogsManaging & SettingsManaging



class CoreDataHelper {
        
    //MARK: - Properties
    internal var numberOfDictionaries: Int64 = 0
    var settingModel: UserSettingsStorageProtocol
    internal var context: NSManagedObjectContext!
    internal var persistenContainer: NSPersistentContainer!
    
    public var dictionaryDidChange = PassthroughSubject<DictionaryChangeType, Never>()
    public var settingsDidChange = PassthroughSubject<Bool, Never>()
    
    init(settingsModel: UserSettingsStorageProtocol) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.context = appDelegate.persistentContainer.viewContext
        self.persistenContainer = appDelegate.persistentContainer
        self.settingModel = settingsModel
        self.context.undoManager = UndoManager()

        do {
            self.numberOfDictionaries = try fetchNumberOfDictionaries()
        } catch {
            print("Failed to initialize: \(error)")
        }
    }
    
    
    //MARK: - Method helpers
    //Get actual number of dictionaries.
    internal func fetchNumberOfDictionaries() throws -> Int64 {
        let request = NSFetchRequest<DictionariesEntity>(entityName: "DictionariesEntity")
        let dictionaries = try context.fetch(request)
        return Int64(dictionaries.count)
    }
    
    // Save context shortcut
    internal func saveContext() throws {
        do {
            try context.save()
            print("Debug: Context saved.")
        } catch {
            print("Debug: Context wasn't saved.")
            throw error
        }
    }
}
