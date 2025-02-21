//
//  DetailsViewModel.swift
//  Language
//
//  Created by Star Lord on 19/07/2023.
//
//  REFACTORING STATE: CHECKED

import Foundation
import Combine


class DetailsViewModel{
    
    enum Output {
        case error(Error)
        case shouldUpdateLangauge
        case shouldUpdateFont
        case shouldUpdatePicker
    }
    
    private var model: DictionaryFullAccess
    private var updateManager: DataUpdateManager
    var dictionary: DictionariesEntity
    
    private var cancellable = Set<AnyCancellable>()
    
    private let cardsDivider: Int = 10
    private var numberOfCards: Int = 0
    
    
    private var selectedOrder: DictionariesSettings.CardOrder
    private var hideTransaltion: Bool
    private var selectedDisplayNumber : Int
    
    var output = PassthroughSubject<Output, Never>()
    
    init(model: DictionaryFullAccess, dictionary: DictionariesEntity){
        self.model = model
        self.updateManager = DataUpdateManager(dataModel: model)
        self.dictionary = dictionary
        self.numberOfCards = Int(dictionary.numberOfCards)
        
        let dictionaryDetails = model.fetchSettings(for: dictionary)
        self.selectedOrder = dictionaryDetails?.cardOrder ?? .normal
        self.hideTransaltion = dictionaryDetails?.isOneSideMode ?? false
        self.selectedDisplayNumber = Int(dictionaryDetails?.selectedNumber ?? Int64(min(numberOfCards, cardsDivider)))

        guard selectedDisplayNumber <= numberOfCards else {
            selectedDisplayNumber = numberOfCards
            return
        }

        model.settingsDidChange
            .sink { [weak self] type in
                if type {
                    self?.updateDictionary()
                }
            }
            .store(in: &cancellable)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(languageDidChange(sender: )), name: .appLanguageDidChange, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(fontDidChange(sender: )), name: .appFontDidChange, object: nil)
        
    }
    deinit { NotificationCenter.default.removeObserver(self) }

    
    func updateDictionary(){
        guard let settings = model.fetchSettings(for: dictionary) else {
            return
        }
        
        selectedDisplayNumber =     Int(settings.selectedNumber)
        selectedOrder =             settings.cardOrder
        hideTransaltion =           settings.isOneSideMode
        numberOfCards =             Int(dictionary.numberOfCards)


        output.send(.shouldUpdatePicker)
    }
    
    
    
    //MARK: Switch related
    func selectedCardsOrder() -> DictionariesSettings.CardOrder {
        return self.selectedOrder
    }
    func isHideTranslationOn() -> Bool {
        return hideTransaltion
    }
    func selectedNumberOfCards() -> Int {
        return selectedDisplayNumber
    }
    
    func hideTranslationDidChange(on: Bool){
        do {
            try updateManager.settingsDidChangeFor(dictionary, isOneSideMode: on)
        } catch {
            output.send(.error(error))
        }
    }
    func cardOrderDidChange(order: DictionariesSettings.CardOrder){
        do {
            try updateManager.settingsDidChangeFor(dictionary, cardsOrderSelection: order)
        } catch {
            output.send(.error(error))
        }
    }
    
//    //MARK: Modify details related to the dictionary.
//    func saveDetails(orderSelection: DictionariesSettings.CardOrder, isOneSideMode: Bool) {
//        do {
//            try updateManager.settingsDidChangeFor(dictionary,
//                                                   isOneSideMode: isOneSideMode,
//                                                   cardsOrderSelection: orderSelection,
//                                                   selectedDisplayNumber: Int64(selectedDisplayNumber)
//            )
//        } catch {
//            output.send(.error(error))
//        }
//    }

    
    //MARK: Picker related.
    func selectedRowForPicker() -> Int {
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
        do {
            try updateManager.settingsDidChangeFor(dictionary, selectedDisplayNumber: Int64(titleForPickerAt(row: row)) ?? Int64(numberOfCards))
        } catch {
            output.send(.error(error))
        }
    }

    //MARK: Actions
    @objc func languageDidChange(sender: Any){
        output.send(.shouldUpdateLangauge)
    }
    @objc func fontDidChange(sender: Any){
        output.send(.shouldUpdateFont)
    }
}
