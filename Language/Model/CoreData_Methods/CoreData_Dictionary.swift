//
//  CoreData_Dictionary.swift
//  Language
//
//  Created by Star Lord on 22/07/2023.
//

import Foundation
import CoreData
import Combine

protocol DictionaryManaging{

    var dictionaryDidChange : PassthroughSubject<DictionaryChangeType, Never> { get set }
    
    func createDictionary(language: String, text: String) throws
    func fetchDictionaries() throws -> [DictionariesEntity]
    func addWordsTo(dictionary: DictionariesEntity, words: [WordsEntity]) throws
    func delete(dictionary: DictionariesEntity) throws
    func updateDictionaryOrder() throws
    func update(dictionary: DictionariesEntity, words: [WordsEntity], name: String?) throws
}

//MARK: - Working with dictioanries.
extension CoreDataHelper: DictionaryManaging{
    
    func createDictionary(language: String, text: String) throws {
        guard let dictionary = createNewDictionary(language: language) else {
            throw DictionaryErrorType.creationFailed

        }
        
        var words: [WordsEntity] = []
        
        do {
            words = try createWordsFromText(for: dictionary, text: text)
        } catch {
            context.rollback()
            throw error
        }
        
        dictionary.words = NSSet(array: words)
        dictionary.numberOfCards = Int64(words.count)
        dictionary.order = numberOfDictionaries
        
        do {
            try context.save()
            dictionaryDidChange.send(.wasAdded)
            numberOfDictionaries += 1
        } catch {
            context.rollback()
            throw DictionaryErrorType.creationFailed
        }
    }
    
    func fetchDictionaries() throws -> [DictionariesEntity] {
        let fetchRequest = NSFetchRequest<DictionariesEntity>(entityName: "DictionariesEntity")
        let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let dictionaries = try context.fetch(fetchRequest)
            return dictionaries
        } catch {
            throw DictionaryErrorType.fetchFailed
        }
    }
    
    func delete(dictionary: DictionariesEntity) throws {
        let order = dictionary.order
        context.delete(dictionary)
        do {
            try saveContext()
            dictionaryDidChange.send(.wasDeleted(Int(order)))
        } catch {
            context.rollback()
            throw DictionaryErrorType.deleteFailed
        }
        try updateDictionaryOrder()
    }
    
    func updateDictionaryOrder() throws {
        let dictionaries = try fetchDictionaries()
        for (index, dictionary) in dictionaries.enumerated() {
            dictionary.order = Int64(index)
        }
        numberOfDictionaries = Int64(dictionaries.count)
        do {
            try saveContext()
        } catch {
            context.rollback()
            throw DictionaryErrorType.updateOrderFailed
        }
    }
    //Add array to existing array of entities
    func addWordsTo(dictionary: DictionariesEntity, words: [WordsEntity]) throws {
        
        dictionary.addToWords(NSSet(array: words))
        dictionary.numberOfCards = Int64(dictionary.words?.count ?? 0)
        
        do {
            try saveContext()
            print("Debug purpose: AddWordsTo(dictionary) method worked with dictionary name: \(dictionary.language)")
            dictionaryDidChange.send(.wasUpdated(Int(dictionary.order)))
        } catch {
            context.rollback()
            throw DictionaryErrorType.additionFailed
        }
    }
    
    //Takes new array of entities
    func update(dictionary: DictionariesEntity, words: [WordsEntity], name: String? = nil) throws {
        if let name = name {
            dictionary.language = name
        }
        
        
        for (index, word) in words.enumerated() {
            word.order = Int64(index)
        }

        dictionary.words = Set(words) as? NSSet
        dictionary.numberOfCards = Int64(words.count)
        
        do {
            try saveContext()
            try updateWordsOrder(for: dictionary)
            dictionaryDidChange.send(.wasUpdated(Int(dictionary.order)))
        } catch {
            context.rollback()
            throw DictionaryErrorType.updateFailed
        }
    }
}

