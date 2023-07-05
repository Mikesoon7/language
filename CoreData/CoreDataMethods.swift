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
        
        let request = NSFetchRequest<DictionariesEntity>(entityName: "DictionariesEntity")
        
        do {
            let dictionaries = try context.fetch(request)
            self.numberOfDictionaries = Int64(dictionaries.count)
        } catch {
            print("Fetch failed: \(error)")
        }
    }
    
    //MARK: - Creating
    //Dictionary from text.
    func createDictionary(language: String, text: String) {
//        let context = getContext()

        let newDictionary = DictionariesEntity(context: context)
        newDictionary.language = language

        let newLog = DictionariesAccessLog(context: context)
        newLog.accessDate = Date()
        newLog.accessCount = 0
        newLog.dictionary = newDictionary

        let words = textInitialDivider(for: newDictionary, text: text)
        newDictionary.words = NSSet(array: words)

        newDictionary.numberOfCards = Int64(words.count)
        newDictionary.order = numberOfDictionaries
        do {
            try context.save()
            numberOfDictionaries += 1
            print("Debug purpose: CreateDictionary method worked with dictionary number equal \(numberOfDictionaries)")
        } catch {
            print("Failed: \(error)")
        }
    }
    //Logs
    func createLogs(for dictionary: DictionariesEntity){
//        let context = getContext()
        
        let calendar = Calendar.current
        let now = Date()
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)
        dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
        
        guard let today = calendar.date(from: dateComponents) else { return }
        
        let fetchRequest: NSFetchRequest<DictionariesAccessLog> = DictionariesAccessLog.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "dictionary == %@ AND accessDate == %@", dictionary, today as NSDate)
        
        do {
            let logs = try context.fetch(fetchRequest)
            if let log = logs.first {
                log.accessCount += 1
            } else {
                let log = DictionariesAccessLog(context: context)
                log.accessDate = today
                log.accessCount = 1
                log.dictionary = dictionary
            }
            
            try context.save()
            print("Debug purpose: CreateLogs method worked")
        } catch {
            print("Failed to log dictionary access: \(error)")
        }
    }

    
    //MARK: - Fetching
    func fetchDictionaries() -> [DictionariesEntity] {
//        let context = getContext()
        let fetchRequest = NSFetchRequest<DictionariesEntity>(entityName: "DictionariesEntity")
        let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        do {
            let dictionaries = try context.fetch(fetchRequest)
            print("Debug purpose: FetchDictionaries method worked with dictionary number equal \(dictionaries.count)")
            return dictionaries
        } catch {
            print("Failed to fetch dictionaries: \(error)")
            return []
        }
    }
    //Fetches logs for dictioanry
    func fetchAccessLogsFor(dictionary: DictionariesEntity) -> [DictionariesAccessLog] {
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
            print("Failed to fetch logs because of \(error)")
            return []
        }
    
    }
    //Fetches ordered words
    func fetchWords(dictionary: DictionariesEntity) -> [WordsEntity] {
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
            print("Unable to fetch dictionaries because of \(error)")
            return []
        }
    }
    
    //Method for dividing raw text
    func textInitialDivider(for dictionary : DictionariesEntity, text: String) -> [WordsEntity] {
        var results = [WordsEntity]()
        let lines = text.split(separator: "\n", omittingEmptySubsequences: true)
    
        for (index, line) in lines.enumerated() {
            let newWord = pairDividerFor(dictionary: dictionary, text: String(line), index: index)
            results.append(newWord)
        }
        print("Debug purpose: TextInitialDivider method worked with number of returned words: \(results.count)")
        return results
    }
    //Divide one line
    func pairDividerFor(dictionary: DictionariesEntity, text: String, index: Int, id: UUID = UUID()) -> WordsEntity {
        let newWord = WordsEntity(context: context)
        newWord.order = Int64(index)
        newWord.identifier = id
        newWord.dictionary = dictionary
        var parts = text.split(separator: " \(UserSettings.shared.settings.separators.selectedValue) ")
        if parts.count == 2{
            let word = String(parts[0]).trimmingCharacters(in: CharacterSet(charactersIn: "[ ] ◦ - "))
            newWord.word = word.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
            newWord.meaning = String(parts[1])
        } else if parts.count > 2{
            newWord.word = String(parts.removeFirst()).trimmingCharacters(in: CharacterSet(charactersIn: " ")).capitalized
            newWord.meaning = parts.joined(separator: " ").trimmingCharacters(in: CharacterSet(charactersIn: " "))
        } else {
            newWord.word = String(parts[0]).trimmingCharacters(in: CharacterSet(charactersIn: "[ ] ◦ - ")).capitalized
            newWord.meaning = ""
        }
        print("Debug purpose: PairDivider method worked with wordsEntity name: \(newWord.word)")

        return newWord
    }
    
    
    func replace(oldWord: WordsEntity, with word: WordsEntity, in dictionary: DictionariesEntity){
        let words = fetchWords(dictionary: dictionary)
        let index = words.firstIndex(of: oldWord)
//        words[index] = word
        do {
            
        } catch {
            
        }
    }
    //Assign new array
    func update(dictionary: DictionariesEntity, words: [WordsEntity], name: String?) {
        if name != nil {
            dictionary.language = name!
        }
        dictionary.words = Set(words) as? NSSet
        dictionary.numberOfCards = Int64(words.count)
        
        do {
            try context?.save()
            print("Debug purpose: Update(for: dictionary) method worked with dictionary name: \(dictionary.language)")
        } catch {
            print("Failed to update dictionary: \(error)")
        }
    }
    
    //MARK: - Add words array
    func addWordsTo(dictionary: DictionariesEntity, words: [WordsEntity]){
        dictionary.addToWords(NSSet(array: words))
        dictionary.numberOfCards = Int64(dictionary.words?.count ?? 0)
        
        do {
            try context?.save()
            print("Debug purpose: AddWordsTo(dictionary) method worked with dictionary name: \(dictionary.language)")
        } catch {
            print("AddWordsToDictionary throws \(error) ")
        }
        
    }
//    MARK: - Update order property for dictionaries
    func updateDictionaryOrder() {
        let fetchRequest = NSFetchRequest<DictionariesEntity>(entityName: "DictionariesEntity")
        let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        do {
            let dictionaries = try context.fetch(fetchRequest)
            for (index, dictionary) in dictionaries.enumerated() {
                dictionary.order = Int64(index)
            }
            numberOfDictionaries = Int64(dictionaries.count)
            try context.save()
            print("Debug purpose: UpdateDictionaryOrder method worked with number of dictioanries: \(numberOfDictionaries)")
        } catch {
            print("Failed to update dictionary order: \(error)")
        }
    }
    func updateWordsOrder(for dictionary: DictionariesEntity){
        let fetchRequest = NSFetchRequest<WordsEntity>(entityName: "WordsEntity")
        let predicate = NSPredicate(format: "dictionary == %@", dictionary)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        do {
            let words = try context.fetch(fetchRequest)
            for (index, word) in words.enumerated() {
                word.order = Int64(index)
            }
            try context.save()
            print("Debug purpose: UpdateWordsOrder method worked for dictionary: \(dictionary.language) with number of words: \(words.count)")
        } catch {
            print("Failed to update words order: \(error)")
        }
    }
    //MARK: - Delete dictionary with order update
    func delete(dictionary: DictionariesEntity) {
        context.delete(dictionary)
        do {
            try context.save()
            print("Debug purpose: DeleteDictionary method worked with dictionary name: \(dictionary.language)")
            updateDictionaryOrder()
        } catch {
            print("Failed to delete dictionary: \(error)")
        }
    }
    func delete(words: WordsEntity) {
        let dictionary = words.dictionary
        
        context.delete(words)
        do {
            try context.save()
            print("Debug purpose: DelteWords method worked with word : \(words.word)")
            guard dictionary != nil else {
                context.rollback()
                return
            }
            updateWordsOrder(for: dictionary!)
        } catch {
            print("Failed to delete dictionary: \(error)")
        }
    }
    
    func getContext() -> NSManagedObjectContext{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
}

