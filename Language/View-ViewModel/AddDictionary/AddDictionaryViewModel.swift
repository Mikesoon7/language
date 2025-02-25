//
//  AddDictionaryModel.swift
//  Language
//
//  Created by Star Lord on 14/07/2023.
//
//  REFACTORING STATE: CHECKED

import Foundation
import UIKit
import Combine

class AddDictionaryViewModel {
    enum Output {
        case shouldPresentError(Error)
        case shouldUpdateText
        case shouldUpdateFont
        case shouldUpdatePlaceholder
        case shouldHighlightError(String)
        case shouldPop
    }
    
    private var dataModel: DictionaryManaging
    private var settingsmodel: UserSettingsStorageProtocol

    var output = PassthroughSubject<Output, Never>()
    
    init(model: DictionaryManaging, settingsModel: UserSettingsStorageProtocol) {
        self.dataModel = model
        self.settingsmodel = settingsModel
        
        NotificationCenter.default.addObserver(self, selector: #selector(appLanguageDidChange(sender: )), name:
                .appLanguageDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appSeparatorDidChange(sender: )), name:
                .appSeparatorDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appFontDidChange(sender: )), name:
                .appFontDidChange, object: nil)
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
    func configureTextPlaceholder() -> String{
        return "viewPlaceholderWord".localized + " \(settingsmodel.appSeparators.value) " + "viewPlaceholderMeaning".localized
    }
    func textSeparator() -> String{
        settingsmodel.appSeparators.value
    }
    
    func createDictionary(name: String, text: String){
        do{
            try dataModel.createDictionary(language: name, text: text)
            output.send(.shouldPop)
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
    
    //MARK: Actions
    @objc func appLanguageDidChange(sender: Any){
        output.send(.shouldUpdateText)
    }
    @objc func appSeparatorDidChange(sender: Any){
        output.send(.shouldUpdatePlaceholder)
    }
    @objc func appFontDidChange(sender: Any){
        output.send(.shouldUpdateFont)
    }

    
}
