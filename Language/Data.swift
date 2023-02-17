//
//  Data.swift
//  Language
//
//  Created by Star Lord on 13/02/2023.
//

import Foundation
import UIKit

class AppData{
    
    var availableDictionary = [DictionaryDetails]()
    
    func addDictionary(language: String, text: String){
        
        availableDictionary.append(DictionaryDetails.init(language: language, dictionary: AppData().divider(text: text)))
           
    }
    
    
    func divider(text: String) -> [[String: String]]{
        var results = [[String: String]]()
        let lines = text.split(separator: "\n", omittingEmptySubsequences: true)
        
        for line in lines {
            let parts = line.split(separator: " - ")
            if parts.count == 2 {
                let word = String(parts[0]).trimmingCharacters(in: CharacterSet(arrayLiteral: "[", "]", "-"))
                let meaning = String(parts[1])
                results.append([word: meaning])
            }
        }
        return results
    }
    
}
class DictionaryDetails{
    
    var dictionary : [[String: String]]?
    
    var language = String()
    
    var numberOfCards = String()
    
    init(language: String){
        self.language = language
            }
    init(language: String, dictionary: [[String: String]]){
        self.language = language
        self.dictionary = dictionary
        self.numberOfCards = String(dictionary.count)
    }
}


