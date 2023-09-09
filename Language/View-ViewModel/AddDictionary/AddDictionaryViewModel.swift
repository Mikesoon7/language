//
//  AddDictionaryModel.swift
//  Language
//
//  Created by Star Lord on 14/07/2023.
//

import Foundation
import UIKit
import Combine

class AddDictionaryViewModel {
    enum Output {
        case shouldPresentError(Error)
        case shouldUpdateText
        case shouldUpdatePlaceholder
        case shouldPop
    }
    
    private var dataModel: DictionaryManaging
    private var settingsmodel: UserSettingsStorageProtocol

    var output = PassthroughSubject<Output, Never>()
    
    init(model: DictionaryManaging, settingsModel: UserSettingsStorageProtocol) {
        self.dataModel = model
        self.settingsmodel = settingsModel
        
        NotificationCenter.default.addObserver(self, selector: #selector(appLanguageDidChange(sender: )), name: .appLanguageDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appSeparatorDidChange(sender: )), name: .appSeparatorDidChange, object: nil)
        
    }
    deinit{
        NotificationCenter.default.removeObserver(self, name: .appLanguageDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .appSeparatorDidChange, object: nil)
    }
    func configureTextPlaceholder() -> String{
        return "viewPlaceholderWord".localized + " \(settingsmodel.appSeparators.value) " + "viewPlaceholderMeaning".localized
    }
    
    func createDictionary(name: String, text: String){
        do{
            try dataModel.createDictionary(language: name, text: text)
            output.send(.shouldPop)
        } catch {
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
    
}
