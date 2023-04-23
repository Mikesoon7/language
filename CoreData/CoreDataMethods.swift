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

    private init() {}

    func addDictionary(language: String, text: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let context = appDelegate.persistentContainer.viewContext

        let newDictionary = DictionariesEntity(context: context)
        newDictionary.language = language

        let words = divider(text: text)
        newDictionary.words = NSSet(array: words)

        newDictionary.numberOfCards = String(words.count)

        do {
            try context.save()
        } catch {
            print("Failed to save dictionary: \(error)")
        }
    }

    func divider(text: String) -> [WordsEntity] {
        var results = [WordsEntity]()
        let lines = text.split(separator: "\n", omittingEmptySubsequences: true)

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return results
        }

        let context = appDelegate.persistentContainer.viewContext

        for line in lines {
            let parts = line.split(separator: " - ")
            let newWord = WordsEntity(context: context)
            if parts.count == 2{
                var word = String(parts[0]).trimmingCharacters(in: CharacterSet(charactersIn: "[ ] ◦ - "))
                word = word.trimmingCharacters(in: .whitespacesAndNewlines)
                let meaning = String(parts[1])
                newWord.word = word
                newWord.meaning = meaning
            } else {
                newWord.word = String(parts[0]).trimmingCharacters(in: CharacterSet(charactersIn: "[ ] ◦ - "))
                newWord.meaning = ""
            }
            newWord.identifier = UUID()
            results.append(newWord)
        }
        return results
    }

    func fetchDictionaries() -> [DictionariesEntity] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return []
        }

        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<DictionariesEntity>(entityName: "DictionariesEntity")

        do {
            let dictionaries = try context.fetch(fetchRequest)
            return dictionaries
        } catch {
            print("Failed to fetch dictionaries: \(error)")
            return []
        }
    }
    
    func updateDictionary(dictionary: DictionariesEntity, text: String) {
        let context = dictionary.managedObjectContext

        let words = divider(text: text)
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

    func deleteDictionary(dictionary: DictionariesEntity) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let context = appDelegate.persistentContainer.viewContext
        context.delete(dictionary)

        do {
            try context.save()
        } catch {
            print("Failed to delete dictionary: \(error)")
        }
    }
}

