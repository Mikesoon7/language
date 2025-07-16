//
//  DataChangeManager.swift
//  Learny
//
//  Created by Star Lord on 18/01/2025.
//

import Foundation
import UIKit

struct ImageDetailsCheck: Codable {
    
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


class DataUpdateManager{
    private var dataModel: DictionaryFullAccess
    
    init(dataModel: DictionaryFullAccess) {
        self.dataModel = dataModel
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
        
    func addNewWordsFor(_ dictionary: DictionariesEntity, from text: String) throws {
        let currentSettings = dataModel.fetchSettings(for: dictionary)
        let currentSelectedNumber = currentSettings?.selectedNumber ?? dictionary.numberOfCards
        let currentTotalNumber = dictionary.numberOfCards
        do {
            let words = try dataModel.createWordsFromText(for: dictionary, text: text)
            try dataModel.addWordsTo(dictionary: dictionary, words: words)
            
            if currentSelectedNumber == currentTotalNumber {
                try settingsDidChangeFor(dictionary, selectedDisplayNumber: currentSelectedNumber + Int64(words.count))
            } else {

                dataModel.settingsDidChange.send(true)
            }
            
        } catch {
            throw error
        }
    }
    func addNewWordsFor(_ dictionary: DictionariesEntity, from pairs: [SingleModeCellData]) throws {
        let currentSettings = dataModel.fetchSettings(for: dictionary)
        let currentSelectedNumber = currentSettings?.selectedNumber ?? dictionary.numberOfCards
        var words: [WordsEntity] = []
        let currentTotalNumber = dictionary.numberOfCards
        do {
            for (index, pair) in pairs.enumerated() {
                let word = dataModel.createWordWithImage(for: dictionary, data: pair, index: index + Int(currentTotalNumber), id: UUID())

                words.append(word)
            }
            
//            let words = try dataModel.createWordsFromText(for: dictionary, text: text)
            try dataModel.addWordsTo(dictionary: dictionary, words: words)
            
            if currentSelectedNumber == currentTotalNumber {
                try settingsDidChangeFor(dictionary, selectedDisplayNumber: currentSelectedNumber + Int64(words.count))
            } else {

                dataModel.settingsDidChange.send(true)
            }
            
        } catch {
            throw error
        }
    }
//    func createWordsFromText(for dictionary : DictionariesEntity, text: String) throws -> [WordsEntity] {
//        var results = [WordsEntity]()
//        let currentNumberOfCards = Int(dictionary.numberOfCards)
//        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
//        let lines = trimmedText.split(separator: "\n", omittingEmptySubsequences: true)
//                
//        for (index, line) in lines.enumerated() {
//            guard line != "\r" else { break }
//            do {
//                //Validating line
//                let newWord = try createWordFromLine(for: dictionary, text: String(line), index:  index + currentNumberOfCards)
//                results.append(newWord)
//            } catch {
//                if let _ = error as? WordsErrorType {
//                    continue
//                } else {
//                    context.rollback()
//                    throw error
//                }
//            }
//        }
//        if results.isEmpty {
//            context.rollback()
//            throw WordsErrorType.failedToAssignEmptyString(text.prefix(20) + (text.count > 20 ? "..." : ""))
//        }
//
//        return results
//    }


    
    func updateExistingDictionary(dictionary: DictionariesEntity, with words: [WordsEntity], name: String?) throws {
        let currentSettings = dataModel.fetchSettings(for: dictionary)
        let currentNumberOfCards = dictionary.numberOfCards
        let currentSelectedNumber = currentSettings?.selectedNumber

        do {
            try dataModel.update(dictionary: dictionary, words: words, name: name)
            if currentSettings == nil || currentNumberOfCards == currentSelectedNumber || words.count < currentSelectedNumber!{
                try settingsDidChangeFor(dictionary, selectedDisplayNumber: Int64(words.count))
            }
        } catch {
            throw error
        }
    }
    func updateExistingDictionary(dictionary: DictionariesEntity, with words: [SingleModeCellData], name: String?) throws {
        let currentSettings = dataModel.fetchSettings(for: dictionary)
        let currentNumberOfCards = dictionary.numberOfCards
        let currentSelectedNumber = currentSettings?.selectedNumber

        do {
            try dataModel.updateOneByOne(dictionary: dictionary, words: words, name: name)
            
            if currentSettings == nil || currentNumberOfCards == currentSelectedNumber || words.count < currentSelectedNumber!{
                try settingsDidChangeFor(dictionary, selectedDisplayNumber: Int64(words.count))
            }
        } catch {
            throw error
        }
    }

}
