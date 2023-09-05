//
//  GameView.swift
//  Language
//
//  Created by Star Lord on 22/08/2023.
//

import Foundation
import Combine
import UIKit

class GameViewModel{
    enum Output{
        case restoreCellWithUpdate(WordsEntity)
        case restoreCellWithDeletion(WordsEntity)
        case restoreCell
        case error(Error)
    }
    enum Input{
        case wordsPairWasUpdated
        case wordsPairWasDeleted
    }
    
    private var dataModel: Dictionary_WordsManager
    private var settingsModel: UserSettingsStorageProtocol
    
    private var dictionary: DictionariesEntity
    private var words: [WordsEntity]!
    
    private var isRandom: Bool
    private var selectedNumberOfWords: Int
    
    
    var output = PassthroughSubject<Output, Never>()
    
    init(dataModel: Dictionary_WordsManager, settingsModel: UserSettingsStorageProtocol, dictionary: DictionariesEntity, isRandom: Bool, selectedNumber: Int){
        self.dataModel = dataModel
        self.settingsModel = settingsModel
        self.dictionary = dictionary
        print("\(dictionary.numberOfCards) , \(dictionary.words?.count)")
        self.isRandom = isRandom
        self.selectedNumberOfWords = selectedNumber
    }
    func configureData() -> DataForGameView{
        let words = retrieveWordsForm(dictionary)
        let preparedWords = prepareWords(words: words, isRandom: isRandom, restrictBy: selectedNumberOfWords)
        return DataForGameView(
            initialNumber: words.count,
            selectedNumber: selectedNumberOfWords,
            words: preparedWords)
    }
    func currentNumberOfWords() -> Int{
        return words.count
    }
    func currentSeparator() -> String{
        return settingsModel.appSeparators.value
    }
    func deleteWord(word: WordsEntity){
        do {
            try dataModel.deleteWord(word: word)
        } catch {
            output.send(.error(error))
        }
        
    }
    
    func editWord(word: WordsEntity, with text: String){
        do {
            try dataModel.reassignWordsProperties(for: word, from: text)
        } catch {
            output.send(.error(error))
        }
    }
    
    private func prepareWords(words: [WordsEntity], isRandom: Bool, restrictBy number: Int) -> [WordsEntity]{
        var wordsArray = words
        if isRandom {
            wordsArray = wordsArray.shuffled()
        }
        return Array(wordsArray.prefix(upTo: number))
    }
    
    private func retrieveWordsForm( _ dictionary: DictionariesEntity) -> [WordsEntity]{
        do {
            let words = try dataModel.fetchWords(for: dictionary)
            self.words = words
            return words
        } catch {
            self.words = []
            output.send(.error(error))
            return []
        }
    }

}
