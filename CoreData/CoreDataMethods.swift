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

    private var numberOfDictionaries: Int64 = 0
    
    private init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<DictionariesEntity>(entityName: "DictionariesEntity")
        
        do {
            let dictionaries = try context.fetch(request)
            self.numberOfDictionaries = Int64(dictionaries.count)
        } catch {
            print("Fetch failed: \(error)")
        }
    }
    //MARK: - Crating dictionary and initializing logs
    func createDictionary(language: String, text: String) {
        let context = getContext()

        let newDictionary = DictionariesEntity(context: context)
        newDictionary.language = language

        let newLog = DictionariesAccessLog(context: context)
        newLog.accessDate = Date()
        newLog.accessCount = 0
        newLog.dictionary = newDictionary

        let words = textInitialDivider(text: text)
        newDictionary.words = NSSet(array: words)

        newDictionary.numberOfCards = String(words.count)
        newDictionary.order = numberOfDictionaries
        do {
            try context.save()
            numberOfDictionaries += 1
        } catch {
            print("Failed: \(error)")
        }
    }

    func fetchDictionaries() -> [DictionariesEntity] {
        let context = getContext()
        let fetchRequest = NSFetchRequest<DictionariesEntity>(entityName: "DictionariesEntity")

        let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
            
        fetchRequest.sortDescriptors = [sortDescriptor]

        do {
            let dictionaries = try context.fetch(fetchRequest)
            return dictionaries
        } catch {
            print("Failed to fetch dictionaries: \(error)")
            return []
        }
    }
    
    func fetchWordsForDispaying(dictionary: DictionariesEntity, number: Int, random: Bool) -> [WordsEntity]{
        createLogs(for: dictionary)
        var words = fetchWords(dictionary: dictionary)
        if random {
            words.shuffle()
        }
        return Array(words.prefix(upTo: number))
    }
    //Fetches ordered words
    func fetchWords(dictionary: DictionariesEntity) -> [WordsEntity] {
        let words = (dictionary.words as? Set<WordsEntity>)?.sorted(by: { $0.order < $1.order })
        return words ?? []
    }
    //MARK: - Updating logs for statistic
    func createLogs(for dictionary: DictionariesEntity){
        let context = getContext()
        
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
        } catch {
            print("Failed to log dictionary access: \(error)")
        }
    }
    //Fetches logs for dictioanry
    func fetchAccessLogsFor(dictionary: DictionariesEntity) -> [Date: Double] {
        guard let logs = dictionary.accessLogs as? Set<DictionariesAccessLog> else {
            return [Date(): Double()]
        }
        var accessDictionary: [Date: Double] = [:]
        for log in Array(logs) {
            accessDictionary[log.accessDate] = Double(log.accessCount)
            
        }        
        return accessDictionary
    }
        
//        let context = getContext()
//        let fetchRequest: NSFetchRequest<DictionariesAccessLog> = DictionariesAccessLog.fetchRequest()
//
//        fetchRequest.predicate = NSPredicate(format: "dictionary == %@", dictionary)
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "accessDate", ascending: true)]
//
//        do {
//            let logs = try context.fetch(fetchRequest)
//            for log in logs{
//                let log = log.
//            }
//            return logs
//        } catch {
//            print("Failed to fetch access logs: \(error)")
//            return []
//        }
//    }

    
    //Method for dividing raw text
    func textInitialDivider(text: String) -> [WordsEntity] {
        var results = [WordsEntity]()
        let lines = text.split(separator: "\n", omittingEmptySubsequences: true)
    
        for (index, line) in lines.enumerated() {
            let newWord = pairDivider(text: String(line), index: index)
            newWord.order = Int64(index)
            newWord.identifier = UUID()
            results.append(newWord)
        }
        return results
    }
    //Divide one line
    func pairDivider(text: String, index: Int) -> WordsEntity {
        let context = getContext()
        
        let newWord = WordsEntity(context: context)
        newWord.order = Int64(index)
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
        return newWord
    }
    
    //Assign new words array
    func update(dictionary: DictionariesEntity, words: [WordsEntity], name: String?) {
        let context = dictionary.managedObjectContext

        if name != nil {
            dictionary.language = name
        }
        dictionary.words = Set(words) as? NSSet
        dictionary.numberOfCards = String(words.count)
        
        do {
            try context?.save()
        } catch {
            print("Failed to update dictionary: \(error)")
        }
    }
    //MARK: - Add words array
    func addWordsTo(dictionary: DictionariesEntity, words: [WordsEntity]){
        let context = dictionary.managedObjectContext
        
        
        dictionary.addToWords(NSSet(array: words))
        dictionary.numberOfCards = String(dictionary.words!.count)
        
        do {
            try context?.save()
        } catch {
            print("AddWordsToDictionary throws \(error) ")
        }
        
    }
//    MARK: - Update order property for dictionaries
    func updateDictionaryOrder() {
        let context = getContext()
        let fetchRequest = NSFetchRequest<DictionariesEntity>(entityName: "DictionariesEntity")
        let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        do {
            let dictionaries = try context.fetch(fetchRequest)
            for (index, dictionary) in dictionaries.enumerated() {
                dictionary.order = Int64(index)
            }
            numberOfDictionaries = Int64(dictionaries.count)
            print("context.save in update func")
            try context.save()
        } catch {
            print("Failed to update dictionary order: \(error)")
        }
    }
    //MARK: - Delete dictionary with order update
    func delete(dictionary: DictionariesEntity) {
        let context = getContext()

        context.delete(dictionary)
        print("context.delete")
        do {
            try context.save()
            print("context.save in delete method")
            updateDictionaryOrder()
        } catch {
            print("Failed to delete dictionary: \(error)")
        }

    }
    
    func getContext() -> NSManagedObjectContext{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
}

