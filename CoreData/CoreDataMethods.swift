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

    func createDictionary(language: String, text: String) {
        let context = getContext()

        let newDictionary = DictionariesEntity(context: context)
        newDictionary.language = language

        let words = textDivider(text: text)
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
//Working function
//    func divider(text: String) -> [WordsEntity] {
//        var results = [WordsEntity]()
//        let lines = text.split(separator: "\n", omittingEmptySubsequences: true)
//
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//            return results
//        }
//
//        let context = appDelegate.persistentContainer.viewContext
//
//        for line in lines {
//            var parts = line.split(separator: " \(UserSettings.shared.settings.separators.selectedValue) ")
//            let newWord = WordsEntity(context: context)
//            if parts.count == 2{
//                var word = String(parts[0]).trimmingCharacters(in: CharacterSet(charactersIn: "[ ] ◦ - "))
//                word = word.trimmingCharacters(in: .whitespacesAndNewlines)
//                let meaning = String(parts[1])
//                newWord.word = word.capitalized
//                newWord.meaning = meaning
//            } else if parts.count > 2{
//                let word = String(parts.removeFirst()).trimmingCharacters(in: CharacterSet(charactersIn: " "))
//                let meaning = parts.joined(separator: " ")
//                newWord.word = word.capitalized
//                newWord.meaning = meaning.trimmingCharacters(in: CharacterSet(charactersIn: " ")).capitalized
//            } else {
//                newWord.word = String(parts[0]).trimmingCharacters(in: CharacterSet(charactersIn: "[ ] ◦ - ")).capitalized
//                newWord.meaning = ""
//            }
//            newWord.identifier = UUID()
//            results.append(newWord)
//        }
//        return results
//    }

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
    
    func textDivider(text: String) -> [WordsEntity] {
        var results = [WordsEntity]()
        let lines = text.split(separator: "\n", omittingEmptySubsequences: true)

        let context = getContext()
    
        for (index, line) in lines.enumerated() {
            let newWord = pairDivider(text: String(line), index: index)
            newWord.identifier = UUID()
            results.append(newWord)
        }
        return results
    }

    func pairDivider(text: String, index: Int) -> WordsEntity {
        let context = getContext()
        
        let newWord = WordsEntity(context: context)
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

    func updateDictionary(dictionary: DictionariesEntity, words: [WordsEntity], name: String?) {
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
    func addWordsToDictionary(dictionary: DictionariesEntity, words: [WordsEntity]){
        let context = dictionary.managedObjectContext
        
        dictionary.addToWords(NSSet(array: words))
        dictionary.numberOfCards = String(dictionary.words!.count)
        
        do {
            try context?.save()
        } catch {
            print("AddWordsToDictionary throws \(error) ")
        }
        
    }
    func updateDictionary(dictionary: DictionariesEntity, text: String) {
        let context = dictionary.managedObjectContext

        let words = textDivider(text: text)
        let newWordsSet = NSSet(array: words)
        dictionary.addToWords(newWordsSet)

        if let currentNumberOfCards = Int(dictionary.numberOfCards ?? "0") {
            dictionary.numberOfCards = String(currentNumberOfCards + words.count)
        } else {
            dictionary.numberOfCards = String(words.count)
        }

        do {
            try context?.save()
        } catch {
            print("Failed to update dictionary: \(error)")
        }
    }
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
            try context.save()
        } catch {
            print("Failed to update dictionary order: \(error)")
        }
    }

//    func editDictionary(dictionary: DictionariesEntity, language: String,  text: String){
//        let context = dictionary.managedObjectContext
//
//        let words = textDivider(text: text)
//        dictionary.words = NSSet(array: words)
//        dictionary.language = language
//        dictionary.numberOfCards = String(words.count)
//
//        do {
//            try context?.save()
//        } catch {
//            print("Failed to edit dictionary: \(error)")
//        }
//
//    }
    func deleteDictionary(dictionary: DictionariesEntity) {
        let context = getContext()

        context.delete(dictionary)
        do {
            try context.save()
            updateDictionaryOrder()
        } catch {
            print("Failed to delete dictionary: \(error)")
        }

    }
//    func deleteDictionary(dictionary: DictionariesEntity) {
//        let context = getContext()
//
//        let fetchRequest = NSFetchRequest<DictionariesEntity>(entityName: "DictionariesEntity")
//        let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//
//        do {
//            var dictionaries = try context.fetch(fetchRequest)
//            context.delete(dictionary)
//
//            dictionaries.removeAll { $0 == dictionary }
//            for (index, dict) in dictionaries.enumerated(){
//                dict.order = Int64(index)
//            }
//            numberOfDictionaries -= 1
//            try context.save()
//        } catch {
//            print("This is not working cause of \(error)")
//        }
//    }
    func getContext() -> NSManagedObjectContext{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
}

