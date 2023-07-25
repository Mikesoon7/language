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
    
    private var model: DictionaryManaging
//    private var cancallable = Set<AnyCancellable>()
    var output = PassthroughSubject<Output, Never>()
    
    init(model: DictionaryManaging = CoreDataHelper.shared) {
        self.model = model
        
        NotificationCenter.default.addObserver(self, selector: #selector(appLanguageDidChange(sender: )), name: .appLanguageDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appSeparatorDidChange(sender: )), name: .appSeparatorDidChange, object: nil)

        
    }
    
    func createDictionary(name: String, text: String){
        do{
            try model.createDictionary(language: name, text: text)
            output.send(.shouldPop)
        } catch {
            output.send(.shouldPresentError(error))
        }
        
    }
    @objc func appLanguageDidChange(sender: Any){
        output.send(.shouldUpdateText)
    }
    @objc func appSeparatorDidChange(sender: Any){
        output.send(.shouldUpdatePlaceholder)
    }
    
}