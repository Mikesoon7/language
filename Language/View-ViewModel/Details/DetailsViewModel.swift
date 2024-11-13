//
//  DetailsViewModel.swift
//  Language
//
//  Created by Star Lord on 19/07/2023.
//

import Foundation
import Combine


class DetailsViewModel{
    
    enum Output {
        case error(Error)
        case shouldUpdateLangauge
        case shouldUpdateFont
        case shouldUpdatePicker
        case shouldPresentAddWordsView(DictionariesEntity)
        case shouldPresentGameView(DictionariesEntity, Int)
    }
    
    private var model: DictionaryFullAccess
    var dictionary: DictionariesEntity
    private var cancellable = Set<AnyCancellable>()
    
    private let cardsDivider: Int = 10
    private var numberOfCards: Int = 0
    
    private lazy var selectedNumber: Int = min(numberOfCards, cardsDivider)
    
    private var random: Bool
    private var hideTransaltion: Bool
    private var selectedDisplayNumber : Int
    
    var output = PassthroughSubject<Output, Never>()
    
    init(model: DictionaryFullAccess, dictionary: DictionariesEntity){
        self.model = model
        self.dictionary = dictionary
        self.numberOfCards = Int(dictionary.numberOfCards)
        
        let dictionaryDetails = model.fetchSettings(for: dictionary)
        self.random = dictionaryDetails?.isRandom ?? false
        self.hideTransaltion = dictionaryDetails?.isOneSideMode ?? false
        self.selectedDisplayNumber = Int(dictionaryDetails?.selectedNumber ?? dictionary.numberOfCards)
        
        model.dictionaryDidChange
            .sink { type in
                switch type {
                case .wasUpdated(_):
                    self.updateDictionary()
                default:
                    break
                }
            }
            .store(in: &cancellable)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(languageDidChange(sender: )), name: .appLanguageDidChange, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(fontDidChange(sender: )), name: .appFontDidChange, object: nil)
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    func updateDictionary(){
        if selectedNumber == numberOfCards {
            selectedNumber = Int(dictionary.numberOfCards)
            selectedDisplayNumber = Int(dictionary.numberOfCards)
        }
        self.numberOfCards = Int(dictionary.numberOfCards)
        output.send(.shouldUpdatePicker)
    }
    
    func addWordsButtonTapped(){
        output.send(.shouldPresentAddWordsView(dictionary))
    }
    
    func startButtonTapped(){
        self.incrementLogsCount(for: dictionary)
        output.send(.shouldPresentGameView(dictionary, selectedNumber))
    }
    
    
    //MARK: Modify statistic related to the selected dictionary.
    //Called when viewModel passing the values for GameVc initialization.
    func incrementLogsCount(for dict: DictionariesEntity) {
        do {
            try model.accessLog(for: dict)
        } catch {
            output.send(.error(error))
        }
    }
    //MARK: Switch related
    func isRandomOn() -> Bool {
        return self.random
    }
    func isHideTranslationOn() -> Bool {
        return hideTransaltion
    }
    func selectedNumberOfCards() -> Int {
        return selectedDisplayNumber
    }
    //MARK: Modify details related to the dictionary.
    func saveDetails(isRandom: Bool, isOneSideMode: Bool) {
        do {
            try model.accessSettings(for: dictionary, with: isRandom, numberofCards: Int64(selectedDisplayNumber), oneSideMode: isOneSideMode)
        } catch {
            output.send(.error(error))
        }
    }

    func saveDetailsTest(isRandom: Bool, isOneSideMode: Bool) {
        do {
            try model.accessSettings(for: dictionary, with: isRandom, numberofCards: Int64(selectedDisplayNumber), oneSideMode: isOneSideMode)
        } catch {
            output.send(.error(error))
        }
    }

    func configureTextPlaceholder() -> String{
        return "viewPlaceholderWord".localized + "  " + "viewPlaceholderMeaning".localized
//        \(settingModel.appSeparators.value)
    }

    
    
    //MARK: Picker related.
    func selectedRowForPicker() -> Int {
//        let number = numberOfRowsInComponent()
        let selectedRow = Int(selectedDisplayNumber / cardsDivider)
        switch selectedDisplayNumber % cardsDivider {
        case 0:
            return selectedRow - 1
        default:
            return selectedRow
        }

    }
    func numberOfRowsInComponent() -> Int {
        switch numberOfCards % cardsDivider {
        case 0: 
            return numberOfCards / cardsDivider
        default: 
            return numberOfCards / cardsDivider + 1
        }
    }
    func titleForPickerAt(row: Int) -> String{
        let numberOfOptions = Int(numberOfCards / cardsDivider)
        if row == numberOfOptions || numberOfOptions == 0 {
            return String(numberOfCards)
        } else {
             return String((row + 1) * cardsDivider)
        }
    }
    func didSelectPickerRow(row: Int){
        selectedDisplayNumber = Int(titleForPickerAt(row: row)) ?? numberOfCards
    }

    @objc func languageDidChange(sender: Any){
        output.send(.shouldUpdateLangauge)
    }
    @objc func fontDidChange(sender: Any){
        output.send(.shouldUpdateFont)
    }
}
