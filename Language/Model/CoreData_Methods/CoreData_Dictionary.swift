//
//  CoreData_Dictionary.swift
//  Language
//
//  Created by Star Lord on 22/07/2023.
//
//TODO: Polish

import Foundation
import CoreData
import Combine

protocol DictionaryManaging{

    var dictionaryDidChange : PassthroughSubject<DictionaryChangeType, Never> { get set }
    
    func fetchDictionaries() throws -> [DictionariesEntity]

    func createNewDictionary(name: String) -> DictionariesEntity
    func fillNewDictionary(dictionary: DictionariesEntity, with: [WordsEntity]) throws
    func extendDictionary(_ dictionary: DictionariesEntity, words: [WordsEntity]) throws
    func updateDictionary(_ dictionary: DictionariesEntity, words: [WordsEntity], name: String?) throws
    func deleteDictionary(_ dictionary: DictionariesEntity) throws
    
    func undoDeletion()
    func canUndo() -> Bool
    func createTutorialDictionary() throws
    func updateDictionaryOrder() throws

}

//MARK: - Working with dictioanries.
extension CoreDataHelper: DictionaryManaging{
//    func createDictionary(language: String, data: [SingleModeCellData]) throws {
//        <#code#>
//    }
    

    //MARK: Create
    func createNewDictionary(name: String) -> DictionariesEntity {
        let newDictionary = DictionariesEntity(context: context)
        newDictionary.language = name
        newDictionary.id = UUID()
        return newDictionary
    }

    func fillNewDictionary(dictionary: DictionariesEntity , with words: [WordsEntity]) throws {
                
        dictionary.id = UUID()
        dictionary.creationDate = Date().timeStripped
        dictionary.words = NSSet(array: words)
        dictionary.numberOfCards = Int64(words.count)
        dictionary.order = numberOfDictionaries
        dictionary.lastIndex = Int64(words.count)
        
        do {
            try context.save()
            dictionaryDidChange.send(.wasAdded)
            numberOfDictionaries += 1
        } catch {
            context.rollback()
            throw DictionaryErrorType.creationFailed(dictionary.language)
        }
    }
    
    
    //MARK: Update
    //Update existing dictionaries data.
    func updateDictionary(_ dictionary: DictionariesEntity, words: [WordsEntity], name: String? = nil) throws {
        if let name = name {
            dictionary.language = name
        }

        dictionary.words = Set(words) as? NSSet
        dictionary.numberOfCards = Int64(words.count)
        dictionary.lastIndex += Int64(words.count)
    
        do {
            try saveContext()
            dictionaryDidChange.send(.wasUpdated(Int(dictionary.order)))
        } catch {
            context.rollback()
            throw DictionaryErrorType.updateFailed( dictionary.language)
        }
    }

    
    //MARK: Extend
    //Add array to existing array of entities
    func extendDictionary(_ dictionary: DictionariesEntity, words: [WordsEntity]) throws {

        dictionary.addToWords(NSSet(array: words))
        dictionary.numberOfCards += Int64(words.count)
        dictionary.lastIndex += Int64(words.count)
        
        do {
            try saveContext()
            dictionaryDidChange.send(.wasUpdated(Int(dictionary.order)))
        } catch {
            context.rollback()
            throw DictionaryErrorType.additionFailed(dictionary.language)
        }
    }

    
    //MARK: Delete
    func deleteDictionary(_ dictionary: DictionariesEntity) throws {
        let order = dictionary.order
        context.undoManager?.registerUndo(withTarget: self, selector: #selector(undoDeleteEntity(entity: )), object: dictionary)
        context.delete( dictionary)
        do {
            try saveContext()
            dictionaryDidChange.send(.wasDeleted(Int(order)))
        } catch {
            context.rollback()
            throw DictionaryErrorType.deleteFailed( dictionary.language)
        }
        try updateDictionaryOrder()
    }

    
    //MARK: Tutorial
    func createTutorialDictionary() throws {
        let name = "tutorial.card.name".localized
        let text = "tutorial.card.title".localized + settingModel.appSeparators.value +  "tutorial.card.message".localized
        let dictionary = createNewDictionary(name: name)
        
        let newWord = WordsEntity(context: context)
        newWord.order = Int64(0)
        newWord.identifier = UUID()
        newWord.dictionary = dictionary
        newWord.word = name
        newWord.meaning = text
//        do {
//            words = try create
//            words = try createWordsFromText(for: dictionary, text: text)
//        } catch {
//            context.rollback()
//            throw error
//        }
        
        dictionary.id = AppLinks.tutorialUUID
        dictionary.creationDate = Date().timeStripped
        dictionary.words = NSSet(array: [newWord])
        dictionary.numberOfCards = Int64(1)
        dictionary.order = numberOfDictionaries
        dictionary.lastIndex = Int64(0)
        
        do {
            try context.save()
            dictionaryDidChange.send(.wasAdded)
            numberOfDictionaries += 1
        } catch {
            context.rollback()
            throw DictionaryErrorType.creationFailed(name)
        }

    }

//    func createDictionary(language: String, data: [SingleModeCellData]) throws {
//        guard let dictionary = createNewDictionary(language: language) else {
//            throw DictionaryErrorType.creationFailed(language)
//        }
//        
//        var words: [WordsEntity] = []
//        
//        for (index, pair) in data.enumerated() {
//            do {
//                let word = try createWordWithImage(for: dictionary, data: pair, index: index)
//                words.append(word)
//            } catch {
//                throw error
//            }
//        }
//        
//        dictionary.creationDate = Date().timeStripped
//        dictionary.words = NSSet(array: words)
//        dictionary.numberOfCards = Int64(words.count)
//        dictionary.lastIndex = Int64(words.count)
//        dictionary.order = numberOfDictionaries
//        
//        do {
//            try context.save()
//            dictionaryDidChange.send(.wasAdded)
//            numberOfDictionaries += 1
//        } catch {
//            context.rollback()
//            throw DictionaryErrorType.creationFailed(language)
//        }
//        //
//    }
    
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
    
    
    //MARK: Others
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
    
    
        
    
    
}

