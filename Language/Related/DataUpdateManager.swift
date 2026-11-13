//
//  DataChangeManager.swift
//  Learny
//
//  Created by Star Lord on 18/01/2025.
//
//TODO: Polish

import Foundation
import UIKit

struct ImageDetailsCheck: Codable, Equatable {
    
    private var imageData: Data?
    
    var originalImage: UIImage?{
        get {
            if let imageData = imageData, let image = UIImage(data: imageData) {
                return image
            }
            return nil
                
        }
    }
    var image: UIImage? {
        get {
            if imageData != nil {
                let image = UIImage(data: imageData!)
                return  filterValue == .blackAndWhite ? image?.applyBlackAndWhiteFilter() : image
            }     
            return nil
        }
    }
    
    var contentMode: ImageContentMode
    var filterValue: ImageFilterMode
    
    init() {
        self.imageData = nil
        self.contentMode = .fill
        self.filterValue = .original
    }
    
    init(image: UIImage?, contentMode: ImageContentMode, filterValue: ImageFilterMode) {
        self.imageData = image != nil ? image!.jpegData(compressionQuality: 0.5) : nil
        self.contentMode = contentMode
        self.filterValue = filterValue
    }
}

enum ImageContentMode: Int, Codable {
    case fit
    case fill

    var uiViewContentMode: UIView.ContentMode {
        switch self {
        case .fit: return .scaleAspectFit
        case .fill: return .scaleAspectFill
        }
    }
}

enum ImageFilterMode: Codable {
    case original
    case blackAndWhite
    
    var original: Bool {
        get {
            switch self {
            case .original:      return true
            case .blackAndWhite: return false
            }
        }
    }
}

enum VerificationResult {
    case emptyName
    case emptyArray
    case emptyText
    case croppedText
    case success([SingleModeCellData], String)
}

enum DictionaryCreationError {
    case emptyName
    case emptyArray
    case emptyText
    case croppedText
}


class DataUpdateManager{
    
    
    private var dataModel: DictionaryFullAccess
    private var settingsModel: UserSettingsStorageProtocol
    
    init(dataModel: DictionaryFullAccess, settings: UserSettingsStorageProtocol) {
        self.dataModel = dataModel
        self.settingsModel = settings
    }
    
    func settingsDidChangeFor(_ dictionary: DictionariesEntity?,
                              isOneSideMode: Bool? = nil,
                              cardsOrderSelection: DictionariesSettings.CardOrder? = nil,
                              selectedDisplayNumber: Int64? = nil) throws {
        guard let dictionary = dictionary else { return }
        let currentSettings = dataModel.fetchSettings(for: dictionary)
        do {
            try dataModel.accessSettings(for: dictionary,
                                         selectedCardsOrder: cardsOrderSelection ?? currentSettings?.cardOrder ?? .normal,
                                         selectedNumberOfCards: selectedDisplayNumber ?? currentSettings?.selectedNumber ?? dictionary.numberOfCards,
                                         isOneSideMode: isOneSideMode ?? currentSettings?.isOneSideMode ?? false)
            
        } catch {
            throw error
        }
    }
    func wordDidDeleteFor(_ dictionary: DictionariesEntity, word: WordsEntity) throws {
        let currentSettings = dataModel.fetchSettings(for: dictionary)
        
        let numeberOfWords: Int64 = dictionary.numberOfCards
        let selectedNumberOfWords: Int64 = currentSettings?.selectedNumber ?? numeberOfWords
        
        do {
            try dataModel.deleteWord(word: word)
            guard numeberOfWords != 1 else { return }
            
            if selectedNumberOfWords == numeberOfWords {
                try settingsDidChangeFor(dictionary, selectedDisplayNumber: selectedNumberOfWords - 1)
            }
        } catch {
            throw error
        }
        
    }
    func logsDidChangeFor(_ dictionary: DictionariesEntity?, sessionTime: Int64, checkedCards: Int64) throws {
        guard let dictionary = dictionary else { return }
        do {
            try dataModel.accessLog(for: dictionary, secSpent: sessionTime, cardsChecked: checkedCards)
        } catch {
            throw error
        }
    }
    
//    func createDictionary(_ name: String, content: String ) throws {
//        let dictionary = dataModel.createNewDictionary(name: name)
//        do {
//            let wordsCollection = try dataModel.createWordsFromText(for: dictionary, text: content)
//            
//            try dataModel.fillNewDictionary(dictionary: dictionary, with: wordsCollection)
//        } catch {
//            throw error
//        }
//    }
    func createDictionary(_ name: String, content: [SingleModeCellData]) throws {
        let dictionary = dataModel.createNewDictionary(name: name)
        var wordsCollection: [WordsEntity] = []
        
        do {
            for (index, cellData) in content.enumerated() {
                do {
                    let wordsEnity = try dataModel.createWordWithImage(for: dictionary, data: cellData, index: index, id: UUID())
                    wordsCollection.append(wordsEnity)
                } catch {
                    throw error
                }
            }
            try dataModel.fillNewDictionary(dictionary: dictionary, with: wordsCollection)
        } catch {
            throw error
        }
    }
    
//    func addNewWordsFor(_ dictionary: DictionariesEntity, from text: String) throws {
//        let currentSettings = dataModel.fetchSettings(for: dictionary)
//        let currentSelectedNumber = currentSettings?.selectedNumber ?? dictionary.numberOfCards
//        let currentLastIndex = dictionary.lastIndex
//        let currentTotalNumber = dictionary.numberOfCards
//        do {
//            let words = try dataModel.createWordsFromText(for: dictionary, text: text)
//            print(currentTotalNumber, words, "AddNewWords, update manager")
//            try dataModel.extendDictionary(dictionary, words: words)
//            
//            if currentSelectedNumber == currentTotalNumber {
//                try settingsDidChangeFor(dictionary, selectedDisplayNumber: currentSelectedNumber + Int64(words.count))
//            } else {
//                
//                dataModel.settingsDidChange.send(true)
//            }
//            
//        } catch {
//            throw error
//        }
//    }
    func addNewWordsFor(_ dictionary: DictionariesEntity, from pairs: [SingleModeCellData]) throws {
        let currentSettings = dataModel.fetchSettings(for: dictionary)
        let currentSelectedNumber = currentSettings?.selectedNumber ?? dictionary.numberOfCards
        var words: [WordsEntity] = []
        let currentWordsNumber = dictionary.numberOfCards
        let currentLastIndex = dictionary.lastIndex
        do {
            for (index, pair) in pairs.enumerated() {
                do {
                    let word = try dataModel.createWordWithImage(for: dictionary, data: pair, index: index + Int(currentLastIndex), id: UUID())
                    
                    words.append(word)
                } catch {
                    throw error
                }
            }
            
            try dataModel.extendDictionary(dictionary, words: words)
            
            if currentSelectedNumber == currentWordsNumber {
                try settingsDidChangeFor(dictionary, selectedDisplayNumber: currentSelectedNumber + Int64(words.count))
            } else {
                
                dataModel.settingsDidChange.send(true)
            }
            
        } catch {
            throw error
        }
    }
    
    func updateDictionary(dictionary: DictionariesEntity, with data: [SingleModeCellData], name: String) throws {
        let currentSettings = dataModel.fetchSettings(for: dictionary)
        let currentNumberOfCards = dictionary.numberOfCards
        let currentSelectedNumber = currentSettings?.selectedNumber
        let currentLastIndex = dictionary.lastIndex
        
        var words: [WordsEntity] = []
        
        for (index, pair) in data.enumerated() {
            do {
                let word = try dataModel.createWordWithImage(for: dictionary, data: pair, index: index + Int(currentLastIndex), id: UUID())
                
                words.append(word)
            } catch {
                throw error
            }
        }
        
        do {
            try dataModel.updateDictionary(dictionary, words: words, name: name)
            
            if currentSettings == nil || currentNumberOfCards == currentSelectedNumber || words.count < currentSelectedNumber!{
                try settingsDidChangeFor(dictionary, selectedDisplayNumber: Int64(words.count))
            }
        } catch {
            throw error
        }
    }
    
    func updateSingleEntry(entry: WordsEntity, data: SingleModeCellData) throws {
        do {
            try dataModel.updateWordEntity(entity: entry, data: data)
        } catch {
            throw error
        }
    }
    
    func splitTheText(text: String, trimExceptions: Bool) -> [SingleModeCellData]{
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let lines = trimmedText.split(separator: "\n", omittingEmptySubsequences: true)
        
        var data: [SingleModeCellData] = []
        
        for (_, line) in lines.enumerated() {
            guard line != "\r" else { break }
            
            var newWord = String()
            var newDefinition = String()
            var trimmedText = String()
            
            let exceptions = settingsModel.appExceptions.availableExceptionsInString
            
            if trimExceptions {
                trimmedText = line.trimmingCharacters(in: CharacterSet(charactersIn: exceptions + exceptions.uppercased()))
            } else {
                trimmedText = String(line)
            }
            let parts = trimmedText.split(separator: settingsModel.appSeparators.value).map { $0.trimmingCharacters(in: .whitespacesAndNewlines)}
            
            guard !trimmedText.isEmpty, !parts.isEmpty else { break }
            
            ///Validating line
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
            
            data.append(.init(word: newWord, definition: newDefinition, imageDetails: .init()))
        }
        print(data, "in split")
        return data
    }
    
    func splitSingleExpressionData(data: String) -> SingleModeCellData {
        let trimmedText = data.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var newWord = String()
        var newDefinition = String()
        var finalText = String()
        
        let exceptions = settingsModel.appExceptions.availableExceptionsInString
        
        finalText = trimmedText.trimmingCharacters(in: CharacterSet(charactersIn: exceptions + exceptions.uppercased()))
        
        let parts = finalText.split(separator: settingsModel.appSeparators.value).map { $0.trimmingCharacters(in: .whitespacesAndNewlines)}
        
        ///Validating line
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
        return SingleModeCellData(word: newWord, definition: newDefinition)
    }
    
    func verifySingleCellData(data: [SingleModeCellData], name: String?) -> VerificationResult {
        guard let name = name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .emptyName
        }
        
        let validData = data.filter { $0.isValid }
        
        guard !validData.isEmpty else {
            return .emptyArray
        }
        
        return .success(validData, name)
    }
    
    func verifyTextData(data: String?, name: String?) -> VerificationResult {
        guard let name = name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .emptyName
        }
        
        guard let text = data, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .emptyText
        }
        
        let singleData = self.splitTheText(text: text, trimExceptions: true)
        let validData = singleData.filter { $0.isValid }
        
        guard !validData.isEmpty else {
            return .croppedText
        }
        
        return .success(validData, name)
    }
    
    func verifySingleEntryTextData(data: String?) -> VerificationResult {
        guard let text = data, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .emptyText
        }
        
        let singleData = self.splitSingleExpressionData(data: text)
        
        guard singleData.isValid else {
            return .croppedText
        }
        
        return .success([singleData], "")


    }
}


