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
    
    enum Output{
        case data(ParsedDictionary)
        case emtyText
        case dictionaryError(DictionaryErrorType)
        case wordsError(CoreDataHelper.WordsErrorType)
        case editSucceed
    }

    //MARK: - Properties
    private let model: CoreDataHelper
    private let dictionary: DictionariesEntity
    private var dictionaryName: String?
    private var words: [WordsEntity]!
    private var cancellables = Set<AnyCancellable>()

    @Published var data: ParsedDictionary!
    var output = PassthroughSubject<Output, Never>()
    

    init(dictionary: DictionariesEntity, model: CoreDataHelper = CoreDataHelper.shared){
        self.model = model
        self.dictionary = dictionary
        
        do {
            words = try model.fetchWords(for: dictionary)
            let parsedDictionary = parseArrayToText(with: words, name: dictionary.language)
            self.data = parsedDictionary
        } catch let error as CoreDataHelper.WordsErrorType{
            words = []
            output.send(.wordsError(error))
        } catch {
            
        }
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(separatorDidChange(sender: )), name: .appSeparatorDidChange, object: nil)
    }
    //MARK: - Methods
    //Prepairing text for edit mode.
    func parseArrayToText(with words: [WordsEntity], name: String) -> ParsedDictionary{
        var textToEdit = ""
        var textByLines = [String]()
        for pair in words {
            let line = "\(pair.word) \(UserSettings.shared.settings.separators.selectedValue) \(pair.meaning)"
            textByLines.append(line)
            textToEdit += line + "\n\n"
        }
        return ParsedDictionary(name: name, text: textToEdit, separatedText: textByLines)
    }
    
    //Converting text to WordsEntity
    func parseTextToArray(name: String?, newText: String, oldCollection: [String]){
        print(newText)
        guard !newText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            output.send(.emtyText)
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
                words.insert(model.createWordFromLine(for: dictionary, text: text, index: index), at: index)
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
            output.send(.dictionaryError(error))
        }
    }
    
    //Calls if everithing fine
    func updateDictionary(){
        do {
            try model.update(dictionary: dictionary, words: words, name: dictionaryName ?? nil)
            output.send(.editSucceed)
        } catch {
            let error = error as! DictionaryErrorType
            output.send(.dictionaryError(error))
        }
    }
    
    
    @objc func separatorDidChange(sender: Notification){
        let parsedDictionary = parseArrayToText(with: words, name: dictionary.language)
        output.send(.data(parsedDictionary))
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
