//
//  CoreDataProtocols.swift
//  Language
//
//  Created by Star Lord on 11/07/2023.
//

import Foundation

protocol DictionaryManaging{
    func createDictionary(language: String, text: String) throws
    func fetchDictionaries() throws -> [DictionariesEntity]
    func delete(dictionary: DictionariesEntity) throws
    func updateDictionaryOrder() throws
    func update(dictionary: DictionariesEntity, words: [WordsEntity], name: String?) throws
}
protocol WordsManaging{
    
}
protocol LogsManaging{
    
}
