//
//  GameView.swift
//  Language
//
//  Created by Star Lord on 22/08/2023.
//
//TODO: Polish

import Foundation
import Combine
import UIKit

internal enum TimerState {
    case shouldStop
    case shouldResume
}

class GameViewModel{
    
    enum Output{
        case updateLables
        case shouldUpdateFont
        case error(Error)
        case shouldPop
        case shouldUpdateTimer(TimerState)
//        case dataReadyForDisplay
    }
    enum CollectionViewOutput {
        case shouldUpdateResult([CellDataWrapper])
//        case shouldInsert(CellDataWrapper)
    }

    //MARK: Properties
    private var dataModel: DictionaryFullAccess
    private var settingsModel: UserSettingsStorageProtocol
    private lazy var updateManager: DataUpdateManager = DataUpdateManager(dataModel: dataModel, settings: settingsModel )
    
    private var dictionary: DictionariesEntity
    private var words: [WordsEntity] = []
    
    private var selectedCardsOrder: DictionariesSettings.CardOrder = .normal
    private var isOneSideMode: Bool = true
    
    private lazy var initialNumberOfCards: Int64 = dictionary.numberOfCards
    private lazy var selectedNumberOfWords: Int64 = dictionary.numberOfCards
    
    private var selectedTime: Int?
    private var appliationEnteredBackground: Bool = false
    
    var output = PassthroughSubject<Output, Never>()
    var collectionOutput = PassthroughSubject<CollectionViewOutput, Never>()

    private var cancellable = Set<AnyCancellable>()
    //MARK: Inherited
    init(dataModel: DictionaryFullAccess, settingsModel: UserSettingsStorageProtocol, dictionary: DictionariesEntity, selectedOrder: DictionariesSettings.CardOrder, isOneSideMode: Bool, selectedNumber: Int, selectedTime: Int?){
        self.dataModel = dataModel
        self.settingsModel = settingsModel
        self.dictionary = dictionary
        self.selectedCardsOrder = selectedOrder
        self.isOneSideMode = isOneSideMode
        self.selectedNumberOfWords = Int64(selectedNumber)
        self.selectedTime = selectedTime
        
        self.initialNumberOfCards = dictionary.numberOfCards
        configureData()
        
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(languageDidUpdate(sender:)),
            name: .appLanguageDidChange, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(fontDidChange(sender:)),
            name: .appFontDidChange, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(willEnterBackground(sender: )),
            name: UIApplication.didEnterBackgroundNotification , object: nil
        )
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(willBecomeActive(sender: )),
            name: UIApplication.didBecomeActiveNotification , object: nil
        )


    }
    deinit { NotificationCenter.default.removeObserver(self)    }
    
        //MARK: Methods
    func configureCompletionPercent() -> Float{
        Float(selectedNumberOfWords) / Float(initialNumberOfCards) * 100.0
    }
    
    func dataForDiffableDataSource() -> [CellDataWrapper]{
        let words = words.map {
            let data = HashableWordsEntity(wordEntity: $0)
            return CellDataWrapper.mainCellData(data)
        }
        return words
    }
    func dataForTheLastCell() -> [CellDataWrapper]?{
        guard selectedTime == nil else { return nil }
        let number = Float(selectedNumberOfWords) / Float(initialNumberOfCards) * 100.0
        return [CellDataWrapper.lastCellData(DataForLastCell(score: number, delegate: self))]
    }
    
    func updateLogWith(time: Int, cardsChecked: Int){
        guard !words.isEmpty else { return }
        do {
            try updateManager.logsDidChangeFor(dictionary, sessionTime: Int64(time), checkedCards: Int64(cardsChecked))
        } catch {
            output.send(.error(error))
        }
    }
    //TODO: - When deleting, needs to update the selected number in cases when the biggest amount was selected.
    @discardableResult
    func deleteWord(word: WordsEntity) -> Bool {
        do {
            try updateManager.wordDidDeleteFor(dictionary, word: word)
            self.words.removeAll(where: { $0 == word })
            return true
        } catch {
            output.send(.error(error))
            return false
        }
    }
    
    ///Returning dictionary and word object, conforming passed index.
    func didSelectCellAt(cell: HashableWordsEntity) -> DataForDetailsView {
        return DataForDetailsView(dictionary: dictionary, word: cell.wordEntity)
    }

    ///Retrieving words from dataModel and assining results of prepare method to local property
    private func configureData(){
        do {
            self.words = try dataModel.fetchWords(for: dictionary)
        } catch {
            self.output.send(.error(error))
        }

        self.words = prepareWords(words: words, selectedOrder: selectedCardsOrder, restrictBy: Int(selectedNumberOfWords))
    }
    
    func viewIsReadyForTheDataDisplay() {
        var data = dataForDiffableDataSource()
        if selectedTime != nil {
            data.append(contentsOf: dataForDiffableDataSource())
        } else {
            data.append(contentsOf: dataForTheLastCell() ?? [])
        }
        collectionOutput.send(.shouldUpdateResult(data))
    }

    ///Creating and return  new array after applying passed random value and restriction by passed number
    private func prepareWords(words: [WordsEntity],
                              selectedOrder: DictionariesSettings.CardOrder,
                              restrictBy number: Int) -> [WordsEntity]{
        
        var wordsArray = words
        switch selectedOrder {
        case .normal:   wordsArray = words
        case .random:   wordsArray = words.shuffled()
        case .reverse:  wordsArray = words.reversed()
        }
        return Array(wordsArray.prefix(upTo: number))
    }
    
    @objc func languageDidUpdate(sender: Any){
        self.output.send(.updateLables)
    }
    @objc func fontDidChange(sender: Any){
        self.output.send(.shouldUpdateFont)
    }
    
    @objc func willEnterBackground(sender: Any){
        self.appliationEnteredBackground = true
        self.output.send(.shouldUpdateTimer(.shouldStop))
    }
    @objc func willBecomeActive(sender: Any){
        if self.appliationEnteredBackground {
            self.output.send(.shouldUpdateTimer(.shouldResume))
            self.appliationEnteredBackground.toggle()
        }
    }


}

extension GameViewModel: CustomCellDelegate {
    func finishButtonTap() {
        output.send(.shouldPop)
    }
}
