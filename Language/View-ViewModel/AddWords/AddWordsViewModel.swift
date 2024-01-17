//
//  AddWordsViewModel.swift
//  Language
//
//  Created by Star Lord on 19/07/2023.
//

import Foundation
import Combine
import UIKit


class AddWordsViewModel {
    
    enum Output {
        case shouldPresentError(Error)
        case shouldHighlightError(String)
        case shouldPop
        case shouldUpdateText
        case shouldUpdatePlaceholder
    }
    
    private let dataModel: Dictionary_WordsManager
    private let settingModel: UserSettingsStorageProtocol
    
    private let dictionary: DictionariesEntity
    private var newArray: [WordsEntity] = []
    
    var output = PassthroughSubject<Output, Never>()
    
    init(dataModel: Dictionary_WordsManager, settingsModel: UserSettingsStorageProtocol, dictionary: DictionariesEntity){
        self.dictionary = dictionary
        self.dataModel = dataModel
        self.settingModel = settingsModel
        
        NotificationCenter.default.addObserver(self, selector: #selector(appLanguageDidChange(sender: )), name: .appLanguageDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appSeparatorDidChange(sender: )), name: .appSeparatorDidChange, object: nil)
    }
    deinit{
        NotificationCenter.default.removeObserver(self, name: .appLanguageDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .appSeparatorDidChange, object: nil)
    }
    
    func configureTextPlaceholder() -> String{
        return "viewPlaceholderWord".localized + " \(settingModel.appSeparators.value) " + "viewPlaceholderMeaning".localized
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
//        let numberOfWords = dictionary.words?.count ?? Int(dictionary.numberOfCards)
//        let lines = text.split(separator: "\n", omittingEmptySubsequences: true).map { String($0) }
//        var errorAppeared = false
        
        do {
            let newWords = try dataModel.createWordsFromText(for: dictionary, text: text)
            extendDictionary(dictionary, with: newWords)
        } catch {
            if let emptyLineError = error as? WordsErrorType {
                    switch emptyLineError {
                    case .failedToAssignEmptyString(let word):
                        output.send(.shouldHighlightError(word))
                    default: break
                    }
                }
                output.send(.shouldPresentError(error))
        }
    }
    
    //MARK: Action
    @objc func appLanguageDidChange(sender: Any){
        output.send(.shouldUpdateText)
    }
    @objc func appSeparatorDidChange(sender: Any){
        output.send(.shouldUpdatePlaceholder)
    }

}
