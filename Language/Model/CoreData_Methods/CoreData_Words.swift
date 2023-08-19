//
//  CoreData_Words.swift
//  Language
//
//  Created by Star Lord on 23/07/2023.
//

import Foundation
import CoreData


//MARK: - Working with words.
protocol WordsManaging{
    func createWordsFromText(for dictionary : DictionariesEntity, text: String) -> [WordsEntity]
    func createWordFromLine(for dictionary: DictionariesEntity, text: String, index: Int, id: UUID) -> WordsEntity
    func assignWordsProperties(for newWord: WordsEntity, from text: String)
    func reassignWordsProperties(for newWord: WordsEntity, from text: String) throws
    func fetchWords(for dictionary: DictionariesEntity) throws -> [WordsEntity]
    func updateWordsOrder(for dictionary: DictionariesEntity) throws
    func deleteWord(word: WordsEntity) throws
}

extension CoreDataHelper: WordsManaging{
    enum WordsErrorType: Error {
        case creationFailed(String)
        case fetchFailed(String)
        case updateFailed(String)
        case updateOrderFailed(String)
        case deleteFailed(String)
        case failedToDefineDictionary(String)
    }
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
        let parts = text.split(separator: " \(UserSettings.shared.appSeparators.value) ")
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
            throw WordsErrorType.fetchFailed("coreData.wordsFetch".localized)
        }
    }
    
    func updateWordsOrder(for dictionary: DictionariesEntity) throws{
        let words = try fetchWords(for: dictionary)
        
        for (index, word) in words.enumerated() {
            word.order = Int64(index)
        }
        
        try update(dictionary: dictionary, words: words)
        print("Debug purpose: UpdateWordsOrder method worked for dictionary: \(dictionary.language) with number of words: \(words.count)")
    }
    
    func deleteWord(word: WordsEntity) throws {
        guard let associatedDictionary = word.dictionary else {
            throw WordsErrorType.failedToDefineDictionary("Some text")
        }
        
        if associatedDictionary.words?.count == 1 {
            try delete(dictionary: associatedDictionary)
        } else {
            context.delete(word)
            try saveContext()
        }
    }

}
