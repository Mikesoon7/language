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
        case shouldPresentEerror(Error)
        case shouldPop
        case shouldUpdateText
        case shouldUpdatePlaceholder
    }
    
    private let model: Dictionary_WordsManager
    private let dictionary: DictionariesEntity
    private var userDefault = UserSettings.shared
    private var newArray: [WordsEntity] = []
    var output = PassthroughSubject<Output, Never>()
    
    init(model: Dictionary_WordsManager = CoreDataHelper.shared, dictionary: DictionariesEntity){
        self.dictionary = dictionary
        self.model = model
        
        NotificationCenter.default.addObserver(self, selector: #selector(appLanguageDidChange(sender: )), name: .appLanguageDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appSeparatorDidChange(sender: )), name: .appSeparatorDidChange, object: nil)
    }
    
    func configureTextPlaceholder() -> String{
        return "viewPlaceholderWord".localized + " \(userDefault.settings.separators.selectedValue) " + "viewPlaceholderMeaning".localized
    }
    
    private func extendDictionary(_ dictionary: DictionariesEntity, with words: [WordsEntity]){
        do {
            try model.addWordsTo(dictionary: dictionary, words: words)
            output.send(.shouldPop)
        } catch {
            output.send(.shouldPresentEerror(error))
        }
    }

    func getNewWordsFrom(_ text: String){
        let numberOfWords = dictionary.words?.count ?? Int(dictionary.numberOfCards)
        let lines = text.split(separator: "\n", omittingEmptySubsequences: true).map { String($0) }
        for (index, line) in lines.enumerated(){
            let correctIndex = numberOfWords + index
            newArray.append(model.createWordFromLine(
                for: dictionary, text: line, index: correctIndex, id: UUID()))
        }
        extendDictionary(dictionary, with: newArray)
    }
    @objc func appLanguageDidChange(sender: Any){
        output.send(.shouldUpdateText)
    }
    @objc func appSeparatorDidChange(sender: Any){
        output.send(.shouldUpdatePlaceholder)
    }

}
