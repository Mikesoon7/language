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
    
    enum Input{
        case viewWillAppear
        case reciveText(String)
    }

    enum Output{
        case shouldPresentData(ParsedDictionary)
        case shouldPresentAlert(UIAlertController)
        case shouldPresentError(Error)
        case shouldHighlightErrorLine(String)
        case shouldUpdateLabels
        case shouldUpdateFont
        case editSucceed
        case shouldUpdateResults
        case shouldPresentController(UIViewController)
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
    
    private var currentWords: [SingleModeCellData] = []
    private var filteredWords: [SingleModeCellData] = []
    
    private var searchPromt = ""

    @Published var data: ParsedDictionary?
    @Published var collectionData: [SingleModeCellData]?
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
            
            DispatchQueue.global(qos: .background).async(execute: {
                for word in self.words {
                    var imageDetails: ImageDetailsCheck? = nil
                    if let imageData = word.image {
                        imageDetails = try? JSONDecoder().decode(ImageDetailsCheck.self, from: imageData)
                    }
                    self.currentWords.append(SingleModeCellData(word: word.word, definition: word.meaning, imageDetails: imageDetails))
                }
                self.filteredWords = self.currentWords
                self.collectionData = self.currentWords
            })
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

    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .receive(on: DispatchQueue.main)
            .sink { inputType in
                switch inputType{
                    //                case .viewWillAppear:
                    //                    self.output.send(.shouldUpdateResults)
                case .reciveText(let text):
                    self.filter(for: text)
                case .viewWillAppear:
                    return
                    
                }
            }
            .store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }

    
    //MARK: Open methods
    func updateDictionaryWith(name: String?, text: String?){
//        parseTextToArray(name: name, newText: text, oldCollection: oldTextByLines)
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
    
//    ///Validating passed values. Parsing passed text into compatible format. Initiating update if succeed.
//    private func parseTextToArray(name: String?, newText: String?, oldCollection: [String]){
//        guard let name = name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
//            configureAlertFor(.invalidName)
//            return
//        }
//        guard let text = newText, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
//            configureAlertFor(.invalidText)
//            return 
//        }
//        self.dictionaryName = name
//        let lines = text.split(separator: "\n", omittingEmptySubsequences: true)
//        let newCollection = lines.map({ String($0)})
//        let difference = newCollection.difference(from: oldCollection)
//
//        var errorAppeared = false
//        for i in difference {
//            if errorAppeared {
//                break
//            }
//            switch i {
//            case .remove(offset: let index, element: _ , associatedWith: _):
//                words.remove(at: index)
//                oldTextByLines.remove(at: index)
//            case .insert(offset: let index, element: let text, associatedWith: _):
//                do {
//                    words.insert( try model.createWordFromLine(for: dictionary, text: text, index: index, id: UUID()), at: index)
//                    oldTextByLines.insert(text, at: index)
//                } catch {
//                    errorAppeared = true
//                    output.send(.shouldPresentError(error))
//                    output.send(.shouldHighlightErrorLine(text))
//                }
//            }
//        }
//        updateDictionary()
//    }
    
    private func filter(for text: String){
        if text.isEmpty {
            filteredWords = currentWords
        } else {
            if text.count > searchPromt.count {
                var filteredArray: [SingleModeCellData] = []
                
                
//                filter.forEach { dictionary in
                     let filtered = filteredWords.filter { word in
                        word.word.lowercased().contains(text.lowercased()) ||
                        word.definition.lowercased().contains(text.lowercased())
                    }
                
                    if filtered.count != 0 {
//                        filteredArray.append(filteredWords)
                        filteredArray.append(contentsOf: filtered )
                    }
                filteredWords = filteredArray

            } else if text.count <= searchPromt.count {
                var filteredArray: [SingleModeCellData] = []
                
                     let filtered = currentWords.filter { word in
                        word.word.lowercased().contains(text.lowercased()) ||
                        word.definition.lowercased().contains(text.lowercased())
                    }
                    if filtered.count != 0 {
                        filteredArray.append(contentsOf: filtered)
                    }
                
                filteredWords = filteredArray
            }
        }
        searchPromt = text
        output.send(.shouldUpdateResults)
    }

    func addEmptyCell(){
        filteredWords.append(.init(word: "", definition: "", imageDetails: .init()))
        currentWords.append(.init(word: "", definition: "", imageDetails: .init()))
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

    func imageDidAdd(imageDetails: ImageDetailsCheck, index: IndexPath){
        
        let pair = filteredWords[index.item]
        let mainIndex = currentWords.firstIndex(where: {$0 == pair})
        if let mainIndex = mainIndex {
            filteredWords[index.item].imageDetails = imageDetails
            currentWords[mainIndex].imageDetails = imageDetails
        }

        
//        let currentPair = filteredWords[index.item]
//        filteredWords[index.item].imageDetails = imageDetails
////        let index = currentWords.firstIndex { pair in
////            pair == currentPair
////        }
////        currentWords.firstIndex(of: currentPair)
//        
//        currentWords[currentWords.firstIndex(of: currentPair)!].imageDetails = imageDetails
        

//        if index.item <= currentWords.count {
//            currentWords[index.item].imageDetails = imageDetails
//        }
    }
    
    //MARK: Dictionary update
    func extendDictionaryWithSingleData(name: String?) {
//        splitTheText(text: currentText)
        guard let name = name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    configureAlertFor(.invalidName)
                    return
                }


        do {
            try updateManager.updateExistingDictionary(dictionary: dictionary, with: currentWords, name: name)
            output.send(.editSucceed)
        } catch {
            if let emptyLineError = error as? WordsErrorType {
                switch emptyLineError {
                case .failedToAssignEmptyString(let word):
//                    output.send(.shouldHighlightError(word))
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

extension EditViewModel: SingleModeViewDelegate {
    func numberOfCells() -> Int {
        
        return filteredWords.count
    }
    
    func dataForCellAt(index: IndexPath) -> SingleModeCellData {
        guard index.item <= filteredWords.count - 1 else {
            return SingleModeCellData(word: "", definition: "", imageDetails: .init())
        }
        var pair = filteredWords[index.item]
        
        return pair
    }
    
    func deleteCell(index: IndexPath) {
        let word = filteredWords.remove(at: index.item)
        currentWords.removeAll(where: { $0 == word })
    }
    
    func wordDidType(index: IndexPath, text: String) { 
        let pair = filteredWords[index.item]
        let mainIndex = currentWords.firstIndex(where: {$0 == pair})
        if let mainIndex = mainIndex {
            filteredWords[index.item].word = text
            currentWords[mainIndex].word = text
        }
    }
    
    func definitionDidTye(index: IndexPath, text: String) { 
        let pair = filteredWords[index.item]
        let mainIndex = currentWords.firstIndex(where: {$0 == pair})
        if let mainIndex = mainIndex {
            filteredWords[index.item].definition = text
            currentWords[mainIndex].definition = text
        }

//        filteredWords[index.item].definition = text
    }
    
    func didSelectAnImage(imageDetails: ImageDetailsCheck, cell: SingleModeImageCell, index: IndexPath) {
        cell.addPhoto(imageDetails: imageDetails)
        imageDidAdd(imageDetails: imageDetails, index: index)
    }

    func didTapAddImage(cell: SingleModeImageCell, index: IndexPath) {
        let pair = filteredWords[index.item]
        let vc = AddImageController(data: pair, delegate: self, cell: cell, index: index)

        output.send(.shouldPresentController(vc))
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
