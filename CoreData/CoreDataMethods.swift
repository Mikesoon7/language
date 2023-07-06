//
//  CoreDataMethods.swift
//  Language
//
//  Created by Star Lord on 22/04/2023.
//

import Foundation
import CoreData
import UIKit

class CoreDataHelper {
    
    static let shared = CoreDataHelper()
    
    //MARK: - Properties
    private var numberOfDictionaries: Int64 = 0
    private var context: NSManagedObjectContext!
    
    private init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.context = appDelegate.persistentContainer.viewContext
        
        do {
            self.numberOfDictionaries = try fetchNumberOfDictionaries()
            
        } catch {
            print("Failed to initialize: \(error)")
        }
    }
    
    //MARK: - Method helpers
    //Get actual number of dictionaries.
    private func fetchNumberOfDictionaries() throws -> Int64 {
        let request = NSFetchRequest<DictionariesEntity>(entityName: "DictionariesEntity")
        let dictionaries = try context.fetch(request)
        return Int64(dictionaries.count)
    }
    // Create dicitoanry entity
    private func createNewDictionary(language: String) -> DictionariesEntity? {
        let newDictionary = DictionariesEntity(context: context)
        newDictionary.language = language
        return newDictionary
    }
    // Save context shortcut
    private func saveContext() throws {
        do {
            try context.save()
            print("Debug: Context saved.")
        } catch {
            throw CoreDataError.saveFailed
        }
    }
    
    //Error cases
    enum CoreDataError: Error {
        case fetchFailed
        case saveFailed
        case dictionaryCreationFailed
        case logCreationFailed
        case dictionaryNotFound
    }
    
    //MARK: - Working with dictioanries.
    func createDictionary(language: String, text: String) throws {
        guard let dictionary = createNewDictionary(language: language) else {
            throw CoreDataError.dictionaryCreationFailed
        }
        
        let newLog = DictionariesAccessLog(context: context)
        newLog.accessDate = Date()
        newLog.accessCount = 0
        newLog.dictionary = dictionary
        
        let words = createWordsFromText(for: dictionary, text: text)
        dictionary.words = NSSet(array: words)
        dictionary.numberOfCards = Int64(words.count)
        dictionary.order = numberOfDictionaries
        
        do {
            try context.save()
            numberOfDictionaries += 1
            print("Debug purpose: CreateDictionary method worked with dictionary number equal \(numberOfDictionaries)")
        } catch {
            throw CoreDataError.saveFailed
        }
    }
    func fetchDictionaries() throws -> [DictionariesEntity] {
        let fetchRequest = NSFetchRequest<DictionariesEntity>(entityName: "DictionariesEntity")
        let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let dictionaries = try context.fetch(fetchRequest)
            print("Debug purpose: FetchDictionaries method worked with dictionary number equal \(dictionaries.count)")
            return dictionaries
        } catch {
            throw CoreDataError.fetchFailed
        }
    }
    
    func delete(dictionary: DictionariesEntity) throws {
        context.delete(dictionary)
        try saveContext()
        try updateDictionaryOrder()
    }
    
    func updateDictionaryOrder() throws {
        let dictionaries = try fetchDictionaries()
        for (index, dictionary) in dictionaries.enumerated() {
            dictionary.order = Int64(index)
        }
        numberOfDictionaries = Int64(dictionaries.count)
        try saveContext()
        print("Debug purpose: UpdateDictionaryOrder method worked with number of dictioanries: \(numberOfDictionaries)")
    }
    
    func update(dictionary: DictionariesEntity, words: [WordsEntity], name: String? = nil) throws {
        if name != nil {
            dictionary.language = name!
        }
        
        dictionary.words = Set(words) as? NSSet
        dictionary.numberOfCards = Int64(words.count)
        
        try saveContext()
        print("Debug purpose: Update(for: dictionary) method worked with dictionary name: \(dictionary.language)")
        
    }
    
    
    //MARK: - Working with logs
    private func fetchLog(for dictionary: DictionariesEntity, at date: Date) -> DictionariesAccessLog? {
        let fetchRequest: NSFetchRequest<DictionariesAccessLog> = DictionariesAccessLog.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "dictionary == %@ AND accessDate == %@", dictionary, date as NSDate)
        
        do {
            let logs = try context.fetch(fetchRequest)
            return logs.first
        } catch {
            print("Failed to fetch log: \(error)")
            return nil
        }
    }
    
    private func createNewLog(for dictionary: DictionariesEntity, at date: Date) -> DictionariesAccessLog {
        let log = DictionariesAccessLog(context: context)
        log.accessDate = date
        log.accessCount = 0
        log.dictionary = dictionary
        return log
    }
    
    func accessLog(for dictionary: DictionariesEntity) throws {
        let today = Calendar.current.startOfDay(for: Date())
        let log = fetchLog(for: dictionary, at: today) ?? createNewLog(for: dictionary, at: today)
        log.accessCount += 1
        
        try saveContext()
    }
    
    func fetchAllLogs(for dictionary: DictionariesEntity) throws -> [DictionariesAccessLog] {
        let fetchRequest = NSFetchRequest<DictionariesAccessLog>(entityName: "DictionariesAccessLog")
        let predicate = NSPredicate(format: "dictionary == %@", dictionary)
        let sortDescriptor = NSSortDescriptor(key: "accessDate", ascending: true)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do{
            let logs = try context.fetch(fetchRequest)
            print("Debug purpose: FetchAccessLogs method worked")
            return logs
        } catch {
            throw CoreDataError.fetchFailed
        }
    }
    
    //MARK: - Working with words.
    func createWordsFromText(for dictionary : DictionariesEntity, text: String) -> [WordsEntity] {
        var results = [WordsEntity]()
        let lines = text.split(separator: "\n", omittingEmptySubsequences: true)
        
        for (index, line) in lines.enumerated() {
            let newWord = createWordFromLine(for: dictionary, text: String(line), index: index)
            results.append(newWord)
        }
        print("Debug purpose: TextInitialDivider method worked with number of returned words: \(results.count)")
        return results
    }
    func createWordFromLine(for dictionary: DictionariesEntity, text: String, index: Int, id: UUID = UUID()) -> WordsEntity {
        let newWord = WordsEntity(context: context)
        newWord.order = Int64(index)
        newWord.identifier = id
        newWord.dictionary = dictionary
        assignWordsProperties(for: newWord, from: text)
        return newWord
    }
    //Method to end initializing or update existing entity
    func assignWordsProperties(for newWord: WordsEntity, from text: String){
        var parts = text.split(separator: " \(UserSettings.shared.settings.separators.selectedValue) ")
        if parts.count == 2{
            let word = String(parts[0]).trimmingCharacters(in: CharacterSet(charactersIn: "[ ] ◦ - "))
            newWord.word = word.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
            newWord.meaning = String(parts[1])
        } else if parts.count > 2{
            newWord.word = String(parts[0]).trimmingCharacters(in: CharacterSet(charactersIn: " ")).capitalized
            newWord.meaning = parts[1...].joined(separator: " ").trimmingCharacters(in: CharacterSet(charactersIn: " "))
        } else {
            newWord.word = String(parts[0]).trimmingCharacters(in: CharacterSet(charactersIn: " ")).capitalized
            newWord.meaning = ""
        }
        print("Debug purpose: AsignProperties method worked with wordsEntity name: \(newWord.word)")
    }
    
    func reassignWordsProperties(for newWord: WordsEntity, from text: String) throws {
        assignWordsProperties(for: newWord, from: text)
        try saveContext()
    }

    func fetchWords(for dictionary: DictionariesEntity) throws -> [WordsEntity] {
        let fetchRequest = NSFetchRequest<WordsEntity>(entityName: "WordsEntity")
        let predicate = NSPredicate(format: "dictionary == %@", dictionary)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let words = try context.fetch(fetchRequest)
            print("Debug purpose: FetchWords method worked for dictionary: \(dictionary.language) with number: \(words.count)")
            return words
        } catch {
            throw CoreDataError.fetchFailed
        }
    }
    
    func addWordsTo(dictionary: DictionariesEntity, words: [WordsEntity]){
        dictionary.addToWords(NSSet(array: words))
        dictionary.numberOfCards = Int64(dictionary.words!.count)
        
        do {
            try context.save()
            print("Debug purpose: AddWordsTo(dictionary) method worked with dictionary name: \(dictionary.language)")
        } catch {
            print("AddWordsToDictionary throws \(error) ")
        }
        
    }
    func updateWordsOrder(for dictionary: DictionariesEntity) throws{
        let words = try fetchWords(for: dictionary)
        
        for (index, word) in words.enumerated() {
            word.order = Int64(index)
        }
        
        try saveContext()
        print("Debug purpose: UpdateWordsOrder method worked for dictionary: \(dictionary.language) with number of words: \(words.count)")
    }
    
    func deleteWord(word: WordsEntity) throws {
        guard let associatedDictionary = word.dictionary else {
            throw CoreDataError.dictionaryNotFound
        }
        
        if associatedDictionary.words?.count == 1 {
            try delete(dictionary: associatedDictionary)
        } else {
            context.delete(word)
            try saveContext()
        }
    }
}
