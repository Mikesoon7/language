//
//  EditModel.swift
//  Language
//
//  Created by Star Lord on 11/07/2023.
//

import Foundation
import Combine
import Differ
import UIKit

class EditViewModel {
    enum InvalidText{
        case invalidName
        case invalidText
    }
    enum Output{
        case shouldPresentData(ParsedDictionary)
        case shouldPresentAlert(UIAlertController)
        case shouldPresentError(Error)
        case shouldUpdateLabels
        case editSucceed
    }

    //MARK: - Properties
    private let model: Dictionary_WordsManager 
    private let dictionary: DictionariesEntity
    private let settingModel: UserSettingsStorageProtocol
    
    private var dictionaryName: String = .init()
    private var words: [WordsEntity] = []
    private var oldTextByLines : [String] = []
    private var cancellables = Set<AnyCancellable>()

    @Published var data: ParsedDictionary?
    var output = PassthroughSubject<Output, Never>()

    //MARK: Inhereted and initialization
    init(dataModel: Dictionary_WordsManager, settingsModel: UserSettingsStorageProtocol, dictionary: DictionariesEntity){
        self.model = dataModel
        self.settingModel = settingsModel
        self.dictionary = dictionary
        
        do {
            words = try model.fetchWords(for: dictionary)
            let parsedDictionary = parseArrayToText(with: words, name: dictionary.language)
            self.data = parsedDictionary
        } catch {
            words = []
            output.send(.shouldPresentError(error))
        }
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(separatorDidChange(sender: )), name: .appSeparatorDidChange, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(languageDidChange(sender: )), name: .appLanguageDidChange, object: nil)
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: .appSeparatorDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .appLanguageDidChange, object: nil)
    }
    
    //MARK: Open methods
    func updateDictionaryWith(name: String?, text: String?){
        parseTextToArray(name: name, newText: text, oldCollection: oldTextByLines)
    }

    
    //MARK: Private Methods
    ///Converting passed Words objects  into string.
    private func parseArrayToText(with words: [WordsEntity], name: String) -> ParsedDictionary{
        var textToEdit = ""
        for pair in words {
            let line = "\(pair.word) \(settingModel.appSeparators.value) \(pair.meaning)"
            oldTextByLines.append(line)
            textToEdit += line + "\n\n"
        }
        return ParsedDictionary(name: name, text: textToEdit)
    }
    
    ///Validating passed values. Parsing passed text into compatible format. Initiating update if succeed.
    private func parseTextToArray(name: String?, newText: String?, oldCollection: [String]){
        guard let name = name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            configureAlertFor(.invalidName)
            return
        }
        guard let text = newText, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            configureAlertFor(.invalidText)
            return 
        }
        self.dictionaryName = name
        let lines = text.split(separator: "\n", omittingEmptySubsequences: true)
        let newCollection = lines.map({ String($0) })
        let patch = patch(from: oldCollection, to: newCollection)
        
        for i in patch{
            switch i {
            case .deletion(index: let index):
                words.remove(at: index)
            case .insertion(index: let index, element: let text):
                words.insert(model.createWordFromLine(for: dictionary, text: text, index: index, id: UUID()), at: index)
            }
        }
        updateDictionary()
    }
    
    private func configureAlertFor(_ errorType: InvalidText){
        let isForEmtyText = errorType == .invalidText ? true : false
        let alert = UIAlertController
            .alertWithAction(
                alertTitle: (isForEmtyText ? "edit.emptyText.title" : "edit.emptyField.title").localized,
                alertMessage: (isForEmtyText ? "edit.emptyText.message" : "edit.emptyField.message").localized,
                alertStyle: .actionSheet,
                action1Title: "system.cancel".localized,
                action1Style: .cancel
            )
        if isForEmtyText {
            let deleteAction = UIAlertAction(title: "system.delete".localized, style: .destructive){ [weak self] _ in
                self?.deleteDictionary()
            }
            alert.addAction(deleteAction)
        }
        output.send(.shouldPresentAlert(alert))
    }

    
    ///Delete current dictionary.
    private func deleteDictionary(){
        do {
            try model.delete(dictionary: dictionary)
            output.send(.editSucceed)
        } catch {
            output.send(.shouldPresentError(error))
        }
    }
    ///Update current dictionary with existing local properties.
    private func updateDictionary(){
        do {
            try model.update(dictionary: dictionary, words: words, name: dictionaryName ?? nil)
            output.send(.editSucceed)
        } catch {
            let error = error as! DictionaryErrorType
            output.send(.shouldPresentError(error))
        }
    }
    
    //MARK: Actions
    @objc private func languageDidChange(sender: Notification){
        output.send(.shouldUpdateLabels)
    }
    @objc private func separatorDidChange(sender: Notification){
        let parsedDictionary = parseArrayToText(with: words, name: dictionary.language)
        output.send(.shouldPresentData(parsedDictionary))
    }
}

//MARK: - EditView initial data.
struct ParsedDictionary{
    let name: String
    let text: String
    
    init(name: String, text: String){
        self.name = name
        self.text = text
    }
}
