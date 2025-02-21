//
//  DataChangeManager.swift
//  Learny
//
//  Created by Star Lord on 18/01/2025.
//

import Foundation

class DataUpdateManager{
    private var dataModel: DictionaryFullAccess
    
    init(dataModel: DictionaryFullAccess) {
        self.dataModel = dataModel
    }
    
    func settingsDidChangeFor(_ dictionary: DictionariesEntity?,
                              isOneSideMode: Bool? = nil,
                              cardsOrderSelection: DictionariesSettings.CardOrder? = nil,
                              selectedDisplayNumber: Int64? = nil) throws {
        guard let dictionary = dictionary else { return }
        let currentSettings = dataModel.fetchSettings(for: dictionary)
        do {
           try dataModel.accessSettings(for: dictionary,
                                     selectedCardsOrder: cardsOrderSelection ?? currentSettings?.cardOrder ?? .normal,
                                     selectedNumberOfCards: selectedDisplayNumber ?? currentSettings?.selectedNumber ?? dictionary.numberOfCards,
                                     isOneSideMode: isOneSideMode ?? currentSettings?.isOneSideMode ?? false)
            
        } catch {
            throw error
        }
    }
    func wordDidDeleteFor(_ dictionary: DictionariesEntity, word: WordsEntity) throws {
        let currentSettings = dataModel.fetchSettings(for: dictionary)
        
        let numeberOfWords: Int64 = dictionary.numberOfCards
        let selectedNumberOfWords: Int64 = currentSettings?.selectedNumber ?? numeberOfWords
        
        do {
            try dataModel.deleteWord(word: word)
            guard numeberOfWords != 1 else { return }
            
            if selectedNumberOfWords == numeberOfWords {
                try settingsDidChangeFor(dictionary, selectedDisplayNumber: selectedNumberOfWords - 1)
            }
        } catch {
            throw error
        }

    }
    func logsDidChangeFor(_ dictionary: DictionariesEntity?, sessionTime: Int64, checkedCards: Int64) throws {
        guard let dictionary = dictionary else { return }
        do {
            try dataModel.accessLog(for: dictionary, secSpent: sessionTime, cardsChecked: checkedCards)
        } catch {
            throw error
        }
    }
        
    func addNewWordsFor(_ dictionary: DictionariesEntity, from text: String) throws {
        let currentSettings = dataModel.fetchSettings(for: dictionary)
        let currentSelectedNumber = currentSettings?.selectedNumber ?? dictionary.numberOfCards
        let currentTotalNumber = dictionary.numberOfCards
        do {
            let words = try dataModel.createWordsFromText(for: dictionary, text: text)
            try dataModel.addWordsTo(dictionary: dictionary, words: words)
            
            if currentSelectedNumber == currentTotalNumber {
                try settingsDidChangeFor(dictionary, selectedDisplayNumber: currentSelectedNumber + Int64(words.count))
            } else {

                dataModel.settingsDidChange.send(true)
            }
            
        } catch {
            throw error
        }
    }
    
    func updateExistingDictionary(dictionary: DictionariesEntity, with words: [WordsEntity], name: String?) throws {
        let currentSettings = dataModel.fetchSettings(for: dictionary)
        let currentNumberOfCards = dictionary.numberOfCards
        let currentSelectedNumber = currentSettings?.selectedNumber

        do {
            try dataModel.update(dictionary: dictionary, words: words, name: name)
            if currentSettings == nil || currentNumberOfCards == currentSelectedNumber || words.count < currentSelectedNumber!{
                try settingsDidChangeFor(dictionary, selectedDisplayNumber: Int64(words.count))
            }
        } catch {
            throw error
        }
    }
}
