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


struct IndividualCellData {
    var word: String
    var definition: String
    
    var image: UIImage?
}

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
    private var settingsModel: UserSettingsStorageProtocol

    
    var currentWords: [IndividualCellData] = []
    var currentText: String = ""
    
    var output = PassthroughSubject<Output, Never>()
    
    init(model: DictionaryManaging, settingsModel: UserSettingsStorageProtocol) {
        self.dataModel = model
        self.settingsModel = settingsModel
        
        NotificationCenter.default.addObserver(self, selector: #selector(appLanguageDidChange(sender: )), name:
                .appLanguageDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appSeparatorDidChange(sender: )), name:
                .appSeparatorDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appFontDidChange(sender: )), name:
                .appFontDidChange, object: nil)
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
    func splitTheText(text: String) {
        currentText = text
        
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let lines = trimmedText.split(separator: "\n", omittingEmptySubsequences: true)
            
        let numberOfPairs = currentWords.count
        var numberOfLines = 0
        for (index, line) in lines.enumerated() {
            guard line != "\r" else { break }
            
            print(line)
            var newWord = String()
            var newDefinition = String()
            var trimmedText = String()

            let exceptions = settingsModel.appExceptions.availableExceptionsInString

            trimmedText = line.trimmingCharacters(in: CharacterSet(charactersIn: exceptions + exceptions.uppercased()))
            let parts = trimmedText.split(separator: settingsModel.appSeparators.value).map { $0.trimmingCharacters(in: .whitespacesAndNewlines)}

            guard !trimmedText.isEmpty, !parts.isEmpty else { break }

//                //Validating line
            newWord = parts[0]
            
            if parts.count == 2{
                newDefinition = String(parts[1]).trimmingCharacters(in: .whitespacesAndNewlines)
            } else if parts.count > 1{
                newDefinition = parts[1...].joined(separator: " \(settingsModel.appSeparators.value) ").trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            newWord = {
                if let firstCharachter = newWord.first{
                    let restOfTheString = newWord.dropFirst()
                    return String(firstCharachter).capitalized + restOfTheString
                } else {
                    return newWord
                }
            }()
            if numberOfPairs >= index + 1 {
                currentWords[index].word = newWord
                currentWords[index].definition = newDefinition
            } else {
                currentWords.append(.init(word: newWord, definition: newDefinition))
            }
            numberOfLines = index + 1
//            wordsResult.append(trimmedText)
        }

        if currentWords.isEmpty {
            addEmptyCell()
        } else if currentWords.count > numberOfLines {
            currentWords.removeLast(currentWords.count - numberOfLines)
        }
        
    }
    
    func uniteTheText() -> String{
        var textByLines: [String] = []
        for cellData in currentWords {
            if cellData.word.isEmpty && cellData.word.isEmpty {
                break
            }
            let line = cellData.word.trimmingCharacters(in: .whitespacesAndNewlines) + " \(settingsModel.appSeparators.value) " + cellData.definition.trimmingCharacters(in: .whitespacesAndNewlines)
            let singleLine = line.split(separator: "\n")
            textByLines.append(singleLine.joined(separator: "\r"))
        }
        currentText = textByLines.joined(separator: "\n")
        return currentText
    }
    
    func addEmptyCell(){
        currentWords.append(.init(word: "", definition: "", image: nil))
    }
    
    func numberOfCells(text: String) -> Int{
        return currentWords.count + 2
    }
    func dataForCellAt(index: IndexPath) -> MultiCardsData{
        guard index.item <= currentWords.count - 1 else { return MultiCardsData(word: "", translation: "", image: nil) }
        var pair = currentWords[index.item]
        
        return MultiCardsData(word: pair.word, translation: pair.definition, image: pair.image)
            
        
    }
    func definitionDidTye(index: IndexPath, text: String) {
        if index.item <= currentWords.count {
            currentWords[index.item].definition = text
        }
    }
    
    func wordDidType(index: IndexPath, text: String) {
        if index.item <= currentWords.count {
            currentWords[index.item].word = text
        }
    }
    func imageDidAdd(image: UIImage?, index: IndexPath){
        if index.item <= currentWords.count && image != nil {
            currentWords[index.item].image = image
        }
    }

    
    func configureTextPlaceholder() -> String{
        return "viewPlaceholderWord".localized + " \(settingsModel.appSeparators.value) " + "viewPlaceholderMeaning".localized
    }
    func textSeparator() -> String{
        settingsModel.appSeparators.value
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
    func createDictionaryByCards(name: String) {
        do {
            
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


