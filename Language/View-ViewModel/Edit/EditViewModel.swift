//
//  EditModel.swift
//  Language
//
//  Created by Star Lord on 11/07/2023.
//
//TODO: Polished

import Foundation
import Combine
import UIKit

class EditViewModel {
    
    enum EditState: Equatable {
        case idle
        case editingText
    }
    enum SearchState: Equatable {
        case searching
        case idle
    }
    
    enum Output{
        case shouldPop
        case shouldUpdateLabels
        case shouldUpdateFont
        case shouldUpdateName(String)
        case shouldPresentAlert(AlertType)
        case shouldPresentError(Error)
    }
    
    enum StateChangedOutput {
        case searchStateChanged(SearchState)
        case interuptSearchSession
        case continueSearchSession
    }
    
    enum CollectionViewOutput {
        case shouldUpdateResult([SingleModeCellData])
        case shouldInsert(SingleModeCellData)
        case shouldPresentAddImageView(SingleModeCellData)
    }
    
    
    //MARK: - Properties
    private let model: DictionaryFullAccess
    private let dictionary: DictionariesEntity
    private let settingsmodel: UserSettingsStorageProtocol
    
    private lazy var updateManager = DataUpdateManager(dataModel: model, settings: settingsmodel)
    
    private var dictionaryName: String = .init()
    private var words: [WordsEntity] = []
    private var oldTextByLines : [String] = []
    private var cancellables = Set<AnyCancellable>()
    
    private var currentWords: [SingleModeCellData] = []
    private var filteredWords: [SingleModeCellData] = []
    
    private var searchPrompt = ""
    
    private var editState: EditState = .idle
    
    private var searchState: SearchState = .idle {
        didSet {
            stateOutput.send(.searchStateChanged(self.searchState))
        }
    }
    
    var output = PassthroughSubject<Output, Never>()
    var stateOutput = PassthroughSubject<StateChangedOutput, Never>()
    var collectionOutput = PassthroughSubject<CollectionViewOutput, Never>()
    
    private(set) var requiresUpdate: Bool = false

    //MARK: Inhereted and initialization
    init(dataModel: DictionaryFullAccess, settingsModel: UserSettingsStorageProtocol, dictionary: DictionariesEntity){
        self.model = dataModel
        self.settingsmodel = settingsModel
        self.dictionary = dictionary
        self.dictionaryName = dictionary.language

        do {
            words = try model.fetchWords(for: dictionary)
            for word in self.words {
                var imageDetails: ImageDetailsCheck? = nil
                if let imageData = word.image {
                    imageDetails = try? JSONDecoder().decode(ImageDetailsCheck.self, from: imageData)
                }
                self.currentWords.append(SingleModeCellData(word: word.word, definition: word.meaning, imageDetails: imageDetails))
            }
            self.filteredWords = self.currentWords
            
//            self.output.send(.shouldUpdateName(self.dictionaryName))
//            self.collectionOutput.send(.shouldUpdateResult( self.filteredWords))
//            
        } catch {
            words = []
            output.send(.shouldPresentError(error))
        }
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(languageDidChange(sender: )), name: .appLanguageDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fontDidChange(sedner: )), name: .appFontDidChange, object: nil)
    }
    deinit { NotificationCenter.default.removeObserver(self) }

    //MARK: Private Methods
    private func filter(for text: String){
        searchPrompt = text
        
        if searchPrompt.isEmpty {
            filteredWords = currentWords
        } else {
            filteredWords = currentWords.filter {
                $0.word.localizedCaseInsensitiveContains(searchPrompt) ||
                $0.definition.localizedCaseInsensitiveContains(searchPrompt)
            }
        }

        collectionOutput.send(.shouldUpdateResult(filteredWords))
    }
    

    //MARK: Data Model
    func extendDictionary() {
        let verificationResult = updateManager.verifySingleCellData(data: currentWords, name: dictionaryName)
        
        switch verificationResult {
        case .success(let data, let name):
            do {
                try updateManager.updateDictionary(dictionary: dictionary, with: data, name: name)
                self.requiresUpdate = false
                output.send(.shouldPop)
            } catch {
                output.send(.shouldPresentError(error))
            }
        case .emptyName:
            output.send(.shouldPresentAlert(.emptyName))
        case .emptyText:
            output.send(.shouldPresentAlert(.emptyText))
        case .croppedText:
            output.send(.shouldPresentAlert(.invalidContent))
        case .emptyArray:
            output.send(.shouldPresentAlert(.emptyArray))
        }
    }
    
    //MARK: State Change Related
    private func deleteDictionary(){
        self.requiresUpdate = false
        do {
            try model.deleteDictionary(dictionary)
            output.send(.shouldPop)
        } catch {
            output.send(.shouldPresentError(error))
        }
    }

    func viewRequestToClose(){
        if requiresUpdate {
            output.send(.shouldPresentAlert(.saveAlert))
        } else {
            self.requiresUpdate = false
            self.output.send(.shouldPop)
        }
    }
    func userPermitedToClose(){
        self.requiresUpdate = false
        self.output.send(.shouldPop)
    }

    func updateName(name: String) {
        self.dictionaryName = name
        if !name.isEmpty {
            self.requiresUpdate = true
        }
    }
    func currentName() -> String {
        return dictionaryName
    }

    func configureTextPlaceholder() -> String{
        return "viewPlaceholderWord".localized + " \(settingsmodel.appSeparators.value) " + "viewPlaceholderMeaning".localized
    }
    func textSeparator() -> String{
        settingsmodel.appSeparators.value
    }
    
    func viewIsReadyForTheDataDisplay() {
        self.output.send(.shouldUpdateName(self.dictionaryName))

        self.collectionOutput.send(.shouldUpdateResult( self.filteredWords))
    }

    
    //MARK: Actions
    @objc private func languageDidChange(sender: Notification){
        output.send(.shouldUpdateLabels)
    }
    @objc private func fontDidChange(sedner: Notification){
        output.send(.shouldUpdateFont)
    }
    
    
    //MARK: SingleInputView Related
    func addEmptyCell(){
        let emptyEntity = SingleModeCellData(word: "", definition: "", imageDetails: .init())
        filteredWords.append(emptyEntity)
        currentWords.append(emptyEntity)
        
        collectionOutput.send(.shouldInsert(emptyEntity))
    }

    func requestAddImage(id: UUID) {
        guard let pair = currentWords.first(where: { $0.identifier == id }) else { return }
        
        collectionOutput.send(.shouldPresentAddImageView(pair))
    }
    
    func didSelectAnImage(imageDetails: ImageDetailsCheck, data: SingleModeCellData) {
        guard let pair = filteredWords.first(where: { $0.identifier == data.identifier }), let pairIndex = filteredWords.firstIndex(where: {$0.identifier == pair.identifier}) else { return }
        
        let mainIndex = currentWords.firstIndex(where: {$0 == pair})
        if let mainIndex = mainIndex {
            filteredWords[pairIndex].imageDetails = imageDetails
            currentWords[mainIndex].imageDetails = imageDetails
            requiresUpdate = true
        }
        
        collectionOutput.send(.shouldUpdateResult(filteredWords))
        
    }
    
    func wordDidType(id: UUID, text: String) {
        guard let pairIndex = filteredWords.firstIndex(where: {$0.identifier == id}) else {
            return
        }
        
        let mainIndex = currentWords.firstIndex(where: {$0.identifier == id})
        if let mainIndex = mainIndex {
            filteredWords[pairIndex].word = text
            currentWords[mainIndex].word = text
            requiresUpdate = true
        }

    }
    
    func definitionDidType(id: UUID, text: String) {
        guard let pairIndex = filteredWords.firstIndex(where: {$0.identifier == id}) else {
            return
        }
        
        let mainIndex = currentWords.firstIndex(where: {$0.identifier == id})
        if let mainIndex = mainIndex {
            filteredWords[pairIndex].definition = text
            currentWords[mainIndex].definition = text
            requiresUpdate = true
        }

    }
    
    func nameDidType(text: String) {
        self.dictionaryName = text
        if !text.isEmpty {
            self.requiresUpdate = true
        }
    }
    
    func enteredEditingMode() {
        if searchState == .searching {
            stateOutput.send(.interuptSearchSession)
        }
        self.editState = .editingText
        
    }
    
    func exitedEditingMode() {
        editState = .idle
    }
        
    func requestedDeletion(id: UUID) {
        filteredWords.removeAll(where: { $0.identifier == id })
        currentWords.removeAll(where: {$0.identifier == id})
        
        collectionOutput.send(.shouldUpdateResult(filteredWords))
        requiresUpdate = true

    }
}


//MARK: SearchView Intents
extension EditViewModel {
    func search(query: String) {
        searchPrompt = query
        searchState = .searching
        filter(for: query)
    }

    func cancelSearch() {
        searchPrompt = ""
        searchState = .idle
        filter(for: searchPrompt)
    }

    func setSearchActive(_ active: Bool, query: String) {
        searchState = active ?
            .searching :  (query.isEmpty ? .idle : .searching)
    }
    
    func finishEditing() {
        if case .searching = searchState{
            stateOutput.send(.continueSearchSession)
        }
    }
}


//MARK: - EditView initial data.
struct ParsedArray {
    let name: String
    let data: [SingleModeCellData]
    
    init(name: String, data: [SingleModeCellData]){
        self.name = name
        self.data = data
    }

}

