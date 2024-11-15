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
        case updateLables
        case shouldUpdateFont
        case error(Error)
    }
    
    //MARK: Properties
    private var dataModel: Dictionary_WordsManager
    
    private var dictionary: DictionariesEntity
    private var words: [WordsEntity] = []
    
//    private var isRandom: Bool
    private var selectedCardsOrder: DictionariesSettings.CardOrder
    private var isOneSideMode: Bool
    private var initialNumberOfCards = Int()
    private var selectedNumberOfWords: Int
    
    private var selectedTime: Int?
    
    var output = PassthroughSubject<Output, Never>()
    private var cancellable = Set<AnyCancellable>()
    
    //MARK: Inherited
    init(dataModel: Dictionary_WordsManager, settingsModel: UserSettingsStorageProtocol, dictionary: DictionariesEntity, selectedOrder: DictionariesSettings.CardOrder, isOneSideMode: Bool, selectedNumber: Int, selectedTime: Int?){
        self.dataModel = dataModel
        self.dictionary = dictionary
        self.selectedCardsOrder = selectedOrder
        self.isOneSideMode = isOneSideMode
        self.selectedNumberOfWords = selectedNumber
        self.selectedTime = selectedTime
        configureData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidUpdate(sender:)), name: .appLanguageDidChange,object: nil
        )
        NotificationCenter.default.addObserver(self, selector: #selector(fontDidChange(sender:)), name: .appFontDidChange,object: nil
        )

        
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: .appLanguageDidChange, object: nil)
    }
    
    //MARK: Methods
    func configureCompletionPercent() -> Float{
        Float(selectedNumberOfWords) / Float(initialNumberOfCards) * 100.0
    }
    
    func dataForDiffableDataSource() -> [WordsEntity]{
        words
    }
    
    func deleteWord(word: WordsEntity){
        do {
            try dataModel.deleteWord(word: word)
            self.words.removeAll(where: {$0 == word})
        } catch {
            output.send(.error(error))
        }
    }
    
    ///Returning dictionary and word object, conforming passed index.
    func didSelectCellAt(indexPath: IndexPath) -> DataForDetailsView {
        return DataForDetailsView(dictionary: dictionary, word: words[indexPath.row])
    }

    ///Retrieving words from dataModel and assining results of prepare method to local property
    private func configureData(){
        do {
            self.words = try dataModel.fetchWords(for: dictionary)
        } catch {
            self.output.send(.error(error))
        }

        self.initialNumberOfCards = words.count
        if selectedTime != nil {
            self.words = prepareWords(words: words, selectedOrder: selectedCardsOrder, restrictBy: selectedNumberOfWords, selectedTime: selectedTime)
        } else {
            self.words = prepareWords(words: words,
                                      selectedOrder: selectedCardsOrder,
                                      restrictBy: selectedNumberOfWords)
        }
        
    }

    ///Creating and return  new array after applying passed random value and restriction by passed number
    private func prepareWords(words: [WordsEntity], selectedOrder: DictionariesSettings.CardOrder, restrictBy number: Int, selectedTime: Int? = nil) -> [WordsEntity]{
        var wordsArray = words
        switch selectedOrder {
        case .normal:   wordsArray = words
        case .random:   wordsArray = words.shuffled()
        case .reverse:  wordsArray = words.reversed()
        }
//        if selectedTime != nil {
//            return wordsArray + wordsArray + wordsArray + wordsArray + wordsArray + wordsArray + wordsArray + wordsArray + wordsArray + wordsArray + wordsArray 
//        } else {
//            return Array(wordsArray.prefix(upTo: number))
//        }
        return Array(wordsArray.prefix(upTo: number))
    }
    
    @objc func languageDidUpdate(sender: Any){
        self.output.send(.updateLables)
    }
    @objc func fontDidChange(sender: Any){
        self.output.send(.shouldUpdateFont)
    }

}
