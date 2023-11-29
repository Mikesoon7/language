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
    func createWordsFromText(for dictionary : DictionariesEntity, text: String) throws -> [WordsEntity]
    func createWordFromLine(for dictionary: DictionariesEntity, text: String, index: Int, id: UUID) throws -> WordsEntity
    func assignWordsProperties(for newWord: WordsEntity, from text: String) throws
    func reassignWordsProperties(for newWord: WordsEntity, from text: String) throws
    func fetchWords(for dictionary: DictionariesEntity) throws -> [WordsEntity]
    func updateWordsOrder(for dictionary: DictionariesEntity) throws
    func deleteWord(word: WordsEntity) throws
}

extension CoreDataHelper: WordsManaging{
    //MARK: Creation
    /// Iterate over passed text, divided by lines. Returns array of Words Entities
    func createWordsFromText(for dictionary : DictionariesEntity, text: String) throws -> [WordsEntity] {
        var results = [WordsEntity]()
        let currentNumberOfCards = Int(dictionary.numberOfCards)
        let lines = text.split(separator: "\n", omittingEmptySubsequences: true)
        
        for (index, line) in lines.enumerated() {
            guard line != "\r" else { break }
            do {
                //Validating line
                let newWord = try createWordFromLine(for: dictionary, text: String(line), index:  index + currentNumberOfCards)
                results.append(newWord)
                
            } catch {
                context.rollback()
                throw error
            }
            print(index)
        }
        return results
    }
    ///Assigning requiered properties for Words Entity. Passes word entity and text to complete creation.
    func createWordFromLine(for dictionary: DictionariesEntity, text: String, index: Int, id: UUID = UUID()) throws -> WordsEntity {
        let newWord = WordsEntity(context: context)
        newWord.order = Int64(index)
        newWord.identifier = id
        newWord.dictionary = dictionary
        try assignWordsProperties(for: newWord, from: text)
        return newWord
    }
    ///Assigning text and description values to passed word with  devided passed text.
    internal func assignWordsProperties(for wordEntity: WordsEntity, from text: String) throws {

        var trimmedText = String()
        var newWord = String()
        var newDescription = String()
        
        print(text)
        let exceptions = settingModel.appExceptions.availableExceptionsInString
        
        trimmedText = text.trimmingCharacters(in: CharacterSet(charactersIn: exceptions + exceptions.uppercased()))

        let parts = trimmedText.split(separator: settingModel.appSeparators.value).map { $0.trimmingCharacters(in: .whitespacesAndNewlines)}

    
        guard !trimmedText.isEmpty, !parts.isEmpty else {
            throw WordsErrorType.failedToAssignEmptyString(text.prefix(20) + (text.count > 20 ? "..." : ""))
        }
        
        newWord = parts[0]

        if parts.count == 2{
            newDescription = String(parts[1]).trimmingCharacters(in: .whitespacesAndNewlines)
        } else if parts.count > 2{
            newDescription = parts[1...].joined(separator: " \(settingModel.appSeparators.value) ").trimmingCharacters(in: .whitespacesAndNewlines)
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
        
        
//        print("Debug purpose: AsignProperties method worked with wordsEntity name: \(wordEntity.word)")
    }
    //MARK: Update
    func reassignWordsProperties(for newWord: WordsEntity, from text: String) throws {
        try assignWordsProperties(for: newWord, from: text)
        try saveContext()
    }
    //Called inside the dictionary update method.
    ///Reassign words order index for passed dictionary.
    func updateWordsOrder(for dictionary: DictionariesEntity) throws{
        let words = try fetchWords(for: dictionary)
        
        for (index, word) in words.enumerated() {
            word.order = Int64(index)
        }
        
        try saveContext()
//        print("Debug purpose: UpdateWordsOrder method worked for dictionary: \(dictionary.language) with number of words: \(words.count)")
    }

    //MARK: Fetch
    func fetchWords(for dictionary: DictionariesEntity) throws -> [WordsEntity] {
        let fetchRequest = NSFetchRequest<WordsEntity>(entityName: "WordsEntity")
        let predicate = NSPredicate(format: "dictionary == %@", dictionary)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let words = try context.fetch(fetchRequest)
//            print("Debug purpose: FetchWords method worked for dictionary: \(dictionary.language) with number: \(words.count)")
            return words
        } catch {
            throw WordsErrorType.fetchFailed(dictionary.language)
//            ("coreData.wordsFetch".localized)
        }
    }
        //MARK: Delete
    func deleteWord(word: WordsEntity) throws {
        guard let associatedDictionary = word.dictionary else {
            throw WordsErrorType.deleteFailed(word.word.prefix(20) + (word.word.count > 20 ? "..." : ""))
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
