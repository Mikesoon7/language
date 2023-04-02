//
//  Data.swift
//  Language
//
//  Created by Star Lord on 13/02/2023.
//

import Foundation
import UIKit

class DataForCells: Hashable {
    
    var identifier : UUID
    var word: String
    var translation: String
    
    init(word: String){
        self.identifier = UUID()
        self.word = word
        self.translation = "   "
    }
    init(word: String, translation: String){
        self.identifier = UUID()
        self.word = word
        self.translation = translation
    }
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    static func == (lhs: DataForCells, rhs: DataForCells) -> Bool{
        lhs.identifier == rhs.identifier
    }
    
}

class AppData{
    static let shared = AppData()

    var availableDictionary = [DictionaryDetails]()
    
    private init() {}

    func addDictionary(language: String, text: String){
        print(availableDictionary.count)
        availableDictionary.append(DictionaryDetails.init(language: language, dictionary: AppData().divider(text: text)))
        print(availableDictionary.count)
    }
    func divider(text: String) -> [DataForCells]{
        var results = [DataForCells]()
        let lines = text.split(separator: "\n", omittingEmptySubsequences: true)
        
        for line in lines {
            let parts = line.split(separator: " - ")
            if parts.count == 2{
                var word = String(parts[0]).trimmingCharacters(in: CharacterSet(charactersIn: "[ ] ◦ - "))
                word = word.trimmingCharacters(in: .whitespacesAndNewlines)
                let meaning = String(parts[1])
                results.append(DataForCells(word: word, translation: meaning))
            } else {
                results.append(DataForCells(word: String(parts[0]).trimmingCharacters(in: CharacterSet(charactersIn: "[ ] ◦  - "))))
            }
        }
        return results
    }
    
}
class DictionaryDetails{
    
    var dictionary : [DataForCells]?{
        didSet{
            numberOfCards = String(dictionary?.count ?? 0)
        }
    }
    
    var language = String()
    
    var numberOfCards = String()
    
    init(){
        
    }
    init(language: String){
        self.language = language
            }
    init(language: String, dictionary: [DataForCells]){
        self.language = language
        self.dictionary = dictionary
        self.numberOfCards = String(dictionary.count)
    }
}
class Statistic{
    
    static let shared = Statistic()
    
    var repeated = Int()
    var totalWords = Int()
}


