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
        case shouldPresentAlert(InvalidText)
        case shouldUpdateLabels
        case shouldPresentError(Error)
        case editSucceed
    }

    //MARK: - Properties
    private let model: Dictionary_WordsManager 
    private let dictionary: DictionariesEntity
    private var dictionaryName: String?
    private var words: [WordsEntity]!
    private var cancellables = Set<AnyCancellable>()

    @Published var data: ParsedDictionary!
    var output = PassthroughSubject<Output, Never>()
    

    init(dataModel: Dictionary_WordsManager, settingsModel: UserSettingsStorageProtocol, dictionary: DictionariesEntity){
        self.model = dataModel
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
    //MARK: - Methods
    //Prepairing text for edit mode.
    func parseArrayToText(with words: [WordsEntity], name: String) -> ParsedDictionary{
        var textToEdit = ""
        var textByLines = [String]()
        for pair in words {
            let line = "\(pair.word) \(UserSettings.shared.appSeparators.value) \(pair.meaning)"
            textByLines.append(line)
            textToEdit += line + "\n\n"
        }
        return ParsedDictionary(name: name, text: textToEdit, separatedText: textByLines)
    }
    
    //Converting text to WordsEntity
    func parseTextToArray(name: String, newText: String, oldCollection: [String]){
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            output.send(.shouldPresentAlert(.invalidName))
            return
        }
        guard !newText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            output.send(.shouldPresentAlert(.invalidText))
            return 
        }
        self.dictionaryName = name
        let lines = newText.split(separator: "\n", omittingEmptySubsequences: true)
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
    
    //Calls if submitted text is empty
    func deleteDictionary(){
        do {
            try model.delete(dictionary: dictionary)
            output.send(.editSucceed)
        } catch {
            let error = error as! DictionaryErrorType
            output.send(.shouldPresentError(error))
        }
    }
    
    //Calls if everithing fine
    func updateDictionary(){
        do {
            try model.update(dictionary: dictionary, words: words, name: dictionaryName ?? nil)
            output.send(.editSucceed)
        } catch {
            let error = error as! DictionaryErrorType
            output.send(.shouldPresentError(error))
        }
    }
    
    //MARK: Actions
    @objc func languageDidChange(sender: Notification){
        output.send(.shouldUpdateLabels)
    }
    @objc func separatorDidChange(sender: Notification){
        let parsedDictionary = parseArrayToText(with: words, name: dictionary.language)
        output.send(.shouldPresentData(parsedDictionary))
    }
}

//MARK: - EditView initial data.
struct ParsedDictionary{
    let name: String
    let text: String
    let separatedText: [String]
    
    init(name: String, text: String, separatedText: [String]){
        self.name = name
        self.text = text
        self.separatedText = separatedText
    }
}
