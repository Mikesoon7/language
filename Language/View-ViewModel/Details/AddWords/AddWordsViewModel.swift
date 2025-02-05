//
//  AddWordsViewModel.swift
//  Language
//
//  Created by Star Lord on 19/07/2023.
//
//  REFACTORING STATE: CHECKED

import Foundation
import Combine
import UIKit

class AddWordsViewModel {
    
    enum Output {
        case shouldPresentError(Error)
        case shouldHighlightError(String)
        case shouldPop
        case shouldUpdatePlaceholder
    }
    
    private let dataModel: DictionaryFullAccess
    private let settingModel: UserSettingsStorageProtocol
    private lazy var updateManager: DataUpdateManager = DataUpdateManager(dataModel: dataModel)

    private let dictionary: DictionariesEntity
    private var newArray: [WordsEntity] = []
    
    var output = PassthroughSubject<Output, Never>()
    
    init(dataModel: DictionaryFullAccess, settingsModel: UserSettingsStorageProtocol, dictionary: DictionariesEntity){
        self.dictionary = dictionary
        self.dataModel = dataModel
        self.settingModel = settingsModel
        
        NotificationCenter.default.addObserver(self, selector: #selector(appSeparatorDidChange(sender: )), name: .appSeparatorDidChange, object: nil)
    }
    deinit{
        NotificationCenter.default.removeObserver(self, name: .appLanguageDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .appSeparatorDidChange, object: nil)
    }
    
    func configureTextPlaceholder() -> String{
        return "viewPlaceholderWord".localized + " \(settingModel.appSeparators.value) " + "viewPlaceholderMeaning".localized
    }
    func textSeparator() -> String{
        settingModel.appSeparators.value
    }
    
    private func extendDictionary(_ dictionary: DictionariesEntity, with words: [WordsEntity]){
        do {
            try dataModel.addWordsTo(dictionary: dictionary, words: words)
            output.send(.shouldPop)
        } catch {
            output.send(.shouldPresentError(error))
        }
    }

    func getNewWordsFrom(_ text: String){        
        do {
            try updateManager.addNewWordsFor(dictionary, from: text)
            output.send(.shouldPop)
//            let newWords = try dataModel.createWordsFromText(for: dictionary, text: text)
//            extendDictionary(dictionary, with: newWords)
        } catch {
            if let emptyLineError = error as? WordsErrorType {
                switch emptyLineError {
                case .failedToAssignEmptyString(let word):
                    output.send(.shouldHighlightError(word))
                    output.send(.shouldPresentError(error))
                    return
                default: 
                    output.send(.shouldPresentError(error))
                    break
                }
            } else {
                output.send(.shouldPresentError(error))
            }
        }
    }
    
    //MARK: Action
    @objc func appSeparatorDidChange(sender: Any){
        output.send(.shouldUpdatePlaceholder)
    }
}
