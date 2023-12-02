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
        case shouldUpdateText
        case shouldUpdatePicker
        case shouldPresentAddWordsView(DictionariesEntity)
        case shouldPresentGameView(DictionariesEntity, Int)
    }
    
    private var model: Dictionary_Words_LogsManager
    private var dictionary: DictionariesEntity
    private var cancellable = Set<AnyCancellable>()
    
    private let cardsDivider: Int = 10
    private var numberOfCards: Int = 0

    private lazy var selectedNumber: Int = min(numberOfCards, cardsDivider)
    
    var output = PassthroughSubject<Output, Never>()
    
    init(model: Dictionary_Words_LogsManager, dictionary: DictionariesEntity){
        self.model = model
        self.dictionary = dictionary
        self.numberOfCards = Int(dictionary.numberOfCards)
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
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func updateDictionary(){
        if selectedNumber == numberOfCards {
            selectedNumber = Int(dictionary.numberOfCards)
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
    
    //MARK: Picker related.
    func numberOfRowsInComponent() -> Int {
        switch numberOfCards % cardsDivider {
        case 0: return numberOfCards / cardsDivider
        default: return numberOfCards / cardsDivider + 1
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
        selectedNumber = Int(titleForPickerAt(row: row)) ?? numberOfCards
    }

    @objc func languageDidChange(sender: Any){
        output.send(.shouldUpdateText)
    }
}
