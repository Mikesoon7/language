//
//  CoreData_Words.swift
//  Language
//
//  Created by Star Lord on 23/07/2023.
//

import Foundation
import CoreData
import Combine


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
    
    /// Iterate over passed text, divided by lines. Returns array of Words Entities
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
    ///Assigning requiered properties for Words Entity. Passes word entity and text to complete creation.
    func createWordFromLine(for dictionary: DictionariesEntity, text: String, index: Int, id: UUID = UUID()) -> WordsEntity {
        let newWord = WordsEntity(context: context)
        newWord.order = Int64(index)
        newWord.identifier = id
        newWord.dictionary = dictionary
        assignWordsProperties(for: newWord, from: text)
        return newWord
    }
    ///Assigning text and description values to passed word with  devided passed text.
    internal func assignWordsProperties(for wordEntity: WordsEntity, from text: String){
        let parts = text.split(separator: " \(UserSettings.shared.appSeparators.value) ")
        
        var newWord = String()
        var newDescription = String()
        
        newWord = String(parts[0]).trimmingCharacters(in: CharacterSet(charactersIn: "[ ] ◦ - "))
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if parts.count == 2{
            newDescription = String(parts[1]).trimmingCharacters(in: .whitespacesAndNewlines)
        } else if parts.count > 2{
            newDescription = parts[1...].joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        wordEntity.word = {
            if let firstCharachter = newWord.first{
                let restOfTheString = newWord.dropFirst()
                return String(firstCharachter).capitalized + restOfTheString
            } else {
                return newWord
            }
        }()
        wordEntity.meaning = newDescription
        
        
        print("Debug purpose: AsignProperties method worked with wordsEntity name: \(wordEntity.word)")
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
        
        try context.save()
        print("Debug purpose: UpdateWordsOrder method worked for dictionary: \(dictionary.language) with number of words: \(words.count)")
    }
    
    func deleteWord(word: WordsEntity) throws {
        guard let associatedDictionary = word.dictionary else {
            throw WordsErrorType.failedToDefineDictionary("Some text")
        }
        
        if associatedDictionary.words?.count == 1 {
            try delete(dictionary: associatedDictionary)
        } else {
            associatedDictionary.removeFromWords(word)
            associatedDictionary.numberOfCards = Int64(associatedDictionary.words?.count ?? 000)

            self.dictionaryDidChange.send(.wasUpdated(Int(associatedDictionary.order)))
            try saveContext()
        }
    }

}
