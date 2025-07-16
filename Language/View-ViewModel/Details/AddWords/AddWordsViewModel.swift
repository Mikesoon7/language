//
//  AddWordsViewModel.swift
//  Language
//
//  Created by Star Lord on 19/07/2023.
//
//  REFACTORING STATE: CHECKED

import Foundation
import Combine
import UIKit

class AddWordsViewModel {
    
    enum Output {
        case shouldPresentError(Error)
        case shouldHighlightError(String)
        case shouldPop
        case shouldUpdatePlaceholder
    }
    enum CollectionViewOutput {
        case shouldPresent(UIViewController)
        case shouldAddCellAt(IndexPath)
    }
    
    private let dataModel: DictionaryFullAccess
    private let settingsModel: UserSettingsStorageProtocol
    private lazy var updateManager: DataUpdateManager = DataUpdateManager(dataModel: dataModel)

    private let dictionary: DictionariesEntity
    private var newArray: [WordsEntity] = []
    
    var currentWords: [SingleModeCellData] = []
    var currentText: String = ""
    
    var output = PassthroughSubject<Output, Never>()
    var singleOutput = PassthroughSubject<CollectionViewOutput, Never>()

    init(dataModel: DictionaryFullAccess, settingsModel: UserSettingsStorageProtocol, dictionary: DictionariesEntity){
        self.dictionary = dictionary
        self.dataModel = dataModel
        self.settingsModel = settingsModel
        
        NotificationCenter.default.addObserver(self, selector: #selector(appSeparatorDidChange(sender: )), name: .appSeparatorDidChange, object: nil)
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
    

    
    //MARK: Single Mode related
    func splitTheText(text: String, final: Bool = false) {
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
                currentWords.append(.init(word: newWord, definition: newDefinition, imageDetails: .init()))
            }
            numberOfLines = index + 1
        }
        let numberOfCells = currentWords.count
        if currentWords.isEmpty {
            if final != true {
                addEmptyCell()
            }
        } else if numberOfCells > numberOfLines {
            for number in numberOfLines...numberOfCells - 1{
                currentWords[number].word = ""
                currentWords[number].definition = ""
            }
        }
        
    }
    
    func uniteTheText() -> String{
        var textByLines: [String] = []
        for cellData in currentWords {
            if (cellData.word + cellData.definition).isEmpty {
                
            } else {
                let line = cellData.word.trimmingCharacters(in: .whitespacesAndNewlines) + " \(settingsModel.appSeparators.value) " + cellData.definition.trimmingCharacters(in: .whitespacesAndNewlines)
                let singleLine = line.split(separator: "\n")
                textByLines.append(singleLine.joined(separator: "\r"))
            }
        }
        currentText = textByLines.joined(separator: "\n")
        return currentText
    }
    
    func addEmptyCell(){
        currentWords.append(.init(word: "", definition: "", imageDetails: .init()))
    }

    func imageDidAdd(imageDetails: ImageDetailsCheck, index: IndexPath){
        if index.item <= currentWords.count {
            currentWords[index.item].imageDetails = imageDetails
        }
    }

    //MARK: Text input view related
    func configureTextPlaceholder() -> String{
        return "viewPlaceholderWord".localized + " \(settingsModel.appSeparators.value) " + "viewPlaceholderMeaning".localized
    }
    func textSeparator() -> String{
        settingsModel.appSeparators.value
    }
    

    //MARK: Dictionary update
    func extendDictionaryWithSingleData() {
        splitTheText(text: currentText)

        do {
            try updateManager.addNewWordsFor(dictionary, from: currentWords)
            output.send(.shouldPop)
        } catch {
            if let emptyLineError = error as? WordsErrorType {
                switch emptyLineError {
                case .failedToAssignEmptyString(let word):
                    output.send(.shouldHighlightError(word))
                    output.send(.shouldPresentError(error))
                    return
                default:
                    output.send(.shouldPresentError(error))
                    break
                }
            } else {
                output.send(.shouldPresentError(error))
            }
        }
    }

    func extendDictionaryWith(_ text: String){
        do {
            try updateManager.addNewWordsFor(dictionary, from: text)
            output.send(.shouldPop)
        } catch {
            if let emptyLineError = error as? WordsErrorType {
                switch emptyLineError {
                case .failedToAssignEmptyString(let word):
                    output.send(.shouldHighlightError(word))
                    output.send(.shouldPresentError(error))
                    return
                default: 
                    output.send(.shouldPresentError(error))
                    break
                }
            } else {
                output.send(.shouldPresentError(error))
            }
        }
    }
    
    //MARK: Action
    @objc func appSeparatorDidChange(sender: Any){
        output.send(.shouldUpdatePlaceholder)
    }
}

//MARK: Single Mode Input delegate
extension AddWordsViewModel: SingleModeViewDelegate{
    func didSelectAnImage(imageDetails: ImageDetailsCheck, cell: SingleModeImageCell, index: IndexPath) {
        
        cell.addPhoto(imageDetails: imageDetails)
        imageDidAdd(imageDetails: imageDetails, index: index)
    }
    
    func deleteCell(index: IndexPath) {
        currentWords.remove(at: index.item)
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
        
    func didTapAddImage(cell: SingleModeImageCell, index: IndexPath) {
        let pair = currentWords[index.item]
        let vc = AddImageController(data: pair, delegate: self, cell: cell, index: index)

        singleOutput.send(.shouldPresent(vc))
    }


    func numberOfCells() -> Int {
        return currentWords.count
    }
    
    func dataForCellAt(index: IndexPath) -> SingleModeCellData{
        guard index.item <= currentWords.count - 1 else { return SingleModeCellData(word: "", definition: "", imageDetails: .init()) }
        let pair = currentWords[index.item]
        
        return pair
    }

}
