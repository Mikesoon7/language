//
//  EditModel.swift
//  Language
//
//  Created by Star Lord on 11/07/2023.
//
//  REFACTORING STATE: CHECKED

import Foundation
import Combine
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
        case shouldHighlightErrorLine(String)
        case shouldUpdateLabels
        case shouldUpdateFont
        case editSucceed
    }

    //MARK: - Properties
    private let model: DictionaryFullAccess
    private let dictionary: DictionariesEntity
    private let settingsmodel: UserSettingsStorageProtocol
    private lazy var updateManager = DataUpdateManager(dataModel: model)
    
    private var dictionaryName: String = .init()
    private var words: [WordsEntity] = []
    private var oldTextByLines : [String] = []
    private var cancellables = Set<AnyCancellable>()

    @Published var data: ParsedDictionary?
    var output = PassthroughSubject<Output, Never>()

    //MARK: Inhereted and initialization
    init(dataModel: DictionaryFullAccess, settingsModel: UserSettingsStorageProtocol, dictionary: DictionariesEntity){
        self.model = dataModel
        self.settingsmodel = settingsModel
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
        NotificationCenter.default.addObserver(self, selector: #selector(fontDidChange(sedner: )), name: .appFontDidChange, object: nil)
    }
    deinit { NotificationCenter.default.removeObserver(self) }

    //MARK: Open methods
    func updateDictionaryWith(name: String?, text: String?){
        parseTextToArray(name: name, newText: text, oldCollection: oldTextByLines)
    }

    
    //MARK: Private Methods
    ///Converting passed Words objects  into string.
    private func parseArrayToText(with words: [WordsEntity], name: String) -> ParsedDictionary{
        var textToEdit = ""
        var textByLines = [String]()
        for pair in words {
            let line = "\(pair.word) \(settingsmodel.appSeparators.value) \(pair.meaning)"
            textByLines.append(line)
            textToEdit += line + "\n\n"
        }
        oldTextByLines = textByLines
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
        let newCollection = lines.map({ String($0)})
        let difference = newCollection.difference(from: oldCollection)

        var errorAppeared = false
        for i in difference {
            if errorAppeared {
                break
            }
            switch i {
            case .remove(offset: let index, element: _ , associatedWith: _):
                words.remove(at: index)
                oldTextByLines.remove(at: index)
            case .insert(offset: let index, element: let text, associatedWith: _):
                do {
                    words.insert( try model.createWordFromLine(for: dictionary, text: text, index: index, id: UUID()), at: index)
                    oldTextByLines.insert(text, at: index)
                } catch {
                    errorAppeared = true
                    output.send(.shouldPresentError(error))
                    output.send(.shouldHighlightErrorLine(text))
                }
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
            try updateManager.updateExistingDictionary(dictionary: dictionary, with: words, name: dictionaryName)
            output.send(.editSucceed)
        } catch {
            output.send(.shouldPresentError(error))
        }
    }
    
    func configureTextPlaceholder() -> String{
        return "viewPlaceholderWord".localized + " \(settingsmodel.appSeparators.value) " + "viewPlaceholderMeaning".localized
    }
    func textSeparator() -> String{
        settingsmodel.appSeparators.value
    }

    
    //MARK: Actions
    @objc private func languageDidChange(sender: Notification){
        output.send(.shouldUpdateLabels)
    }
    @objc private func separatorDidChange(sender: Notification){
        let parsedDictionary = parseArrayToText(with: words, name: dictionary.language)
        output.send(.shouldPresentData(parsedDictionary))
    }
    @objc private func fontDidChange(sedner: Notification){
        output.send(.shouldUpdateFont)
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
