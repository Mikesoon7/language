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
//        case restoreCellWithUpdate(WordsEntity)
//        case restoreCellWithDeletion(WordsEntity)
//        case restoreCell
        case updateLables
        case error(Error)
    }
    enum Input{
        case wordsPairWasUpdated
        case wordsPairWasDeleted
    }
    
    private var dataModel: Dictionary_WordsManager
    private var settingsModel: UserSettingsStorageProtocol
    
    var dictionary: DictionariesEntity
    var words: [WordsEntity] = []
    
    private var isRandom: Bool
    private var selectedNumberOfWords: Int
    
    var output = PassthroughSubject<Output, Never>()
    private var cancellable = Set<AnyCancellable>()
    
    init(dataModel: Dictionary_WordsManager, settingsModel: UserSettingsStorageProtocol, dictionary: DictionariesEntity, isRandom: Bool, selectedNumber: Int){
        self.dataModel = dataModel
        self.settingsModel = settingsModel
        self.dictionary = dictionary
        self.isRandom = isRandom
        self.selectedNumberOfWords = selectedNumber
        configureData()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageDidUpdate(sender:)),
            name: .appLanguageDidChange,
            object: nil
        )
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: .appLanguageDidChange, object: nil)
    }
    
    func configureCompletionPercent() -> Float{
        Float(selectedNumberOfWords) / Float(words.count) * 100.0
    }
    
    func didSelectCellAt(indexPath: IndexPath) -> DataForDetailsView {
        
        return DataForDetailsView(dictionary: dictionary, word: words[indexPath.row])
        
    }

    func configureData(){
        do {
            self.words = try retrieveWordsForm(dictionary)
        } catch {
            self.output.send(.error(error))
        }
        print(words.count)
        self.words = prepareWords(words: words, isRandom: isRandom, restrictBy: selectedNumberOfWords)
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
            self.selectedNumberOfWords -= 1
            self.configureData()
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
    
    private func retrieveWordsForm( _ dictionary: DictionariesEntity) throws -> [WordsEntity]{
        try dataModel.fetchWords(for: dictionary)
    }
    
    @objc func languageDidUpdate(sender: Notification){
        self.output.send(.updateLables)
    }

}
