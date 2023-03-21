//
//  Data.swift
//  Language
//
//  Created by Star Lord on 13/02/2023.
//

import Foundation
import UIKit

class DataForCards{
    var word: String
    var translation: String
    
    init(word: String){
        self.word = word
        self.translation = "   "
    }
    init(word: String, translation: String){
        self.word = word
        self.translation = translation
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
    func divider(text: String) -> [DataForCards]{
        var results = [DataForCards]()
        let lines = text.split(separator: "\n", omittingEmptySubsequences: true)
        
        for line in lines {
            let parts = line.split(separator: " - ")
            if parts.count == 2{
                let word = String(parts[0]).trimmingCharacters(in: CharacterSet(arrayLiteral: "[", "]", "-", "◦"))
                let meaning = String(parts[1])
                results.append(DataForCards(word: word.trimmingCharacters(in: .whitespacesAndNewlines), translation: meaning))
            } else {
                results.append(DataForCards(word: String(parts[0]).trimmingCharacters(in: CharacterSet(arrayLiteral: "[", "]", "-", "◦"))))
            }
        }
        return results
    }
    
}
class DictionaryDetails{
    
    var dictionary : [DataForCards]?{
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
    init(language: String, dictionary: [DataForCards]){
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


