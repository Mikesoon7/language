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
    func undoDeletion()
    func canUndo() -> Bool
    func updateDictionaryOrder() throws
    func update(dictionary: DictionariesEntity, words: [WordsEntity], name: String?) throws
}

//MARK: - Working with dictioanries.
extension CoreDataHelper: DictionaryManaging{
    //MARK: Creation
    func createDictionary(language: String, text: String) throws {
        guard let dictionary = createNewDictionary(language: language) else {
            throw DictionaryErrorType.creationFailed(language)
        }
        
        var words: [WordsEntity] = []
        
        do {
            words = try createWordsFromText(for: dictionary, text: text)
        } catch {
            context.rollback()
            throw error
        }
        
        dictionary.creationDate = Date().timeStripped
        dictionary.words = NSSet(array: words)
        dictionary.numberOfCards = Int64(words.count)
        dictionary.order = numberOfDictionaries
        
        do {
            try context.save()
            dictionaryDidChange.send(.wasAdded)
            numberOfDictionaries += 1
        } catch {
            context.rollback()
            throw DictionaryErrorType.creationFailed(language)
        }
    }
    //MARK: Fetch
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
    //MARK: Deletion
    func delete(dictionary: DictionariesEntity) throws {
        let order = dictionary.order
        context.undoManager?.registerUndo(withTarget: self, selector: #selector(undoDeleteEntity(entity: )), object: dictionary)
        context.delete(dictionary)
        do {
            try saveContext()
            dictionaryDidChange.send(.wasDeleted(Int(order)))
        } catch {
            context.rollback()
            throw DictionaryErrorType.deleteFailed(dictionary.language)
        }
        try updateDictionaryOrder()
    }
    
    func canUndo() -> Bool{
        return context.undoManager?.canUndo ?? false
    }
    
    @objc private func undoDeleteEntity(entity: DictionariesEntity) {
        context.insert(entity)

        do {
            try context.save()
        } catch {
            // Handle the error
        }
    }
    func undoDeletion() {
        self.context.undoManager?.undo()
        self.dictionaryDidChange.send(.wasAdded)
    }
    //MARK: Update
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
            dictionaryDidChange.send(.wasUpdated(Int(dictionary.order)))
        } catch {
            context.rollback()
            throw DictionaryErrorType.additionFailed(dictionary.language)
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
//            try updateWordsOrder(for: dictionary)
            dictionaryDidChange.send(.wasUpdated(Int(dictionary.order)))
        } catch {
            context.rollback()
            throw DictionaryErrorType.updateFailed(dictionary.language)
        }
    }
}

