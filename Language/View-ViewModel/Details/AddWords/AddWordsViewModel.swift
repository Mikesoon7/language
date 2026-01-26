//
//  AddWordsViewModel.swift
//  Language
//
//  Created by Star Lord on 19/07/2023.
//
//TODO: Polished

import Foundation
import Combine
import UIKit

class AddWordsViewModel {
    enum Output {
        case shouldPresentError(Error)
        case shouldHighlightError(String)
        case shouldPresentAlert(AlertType)
        case shouldPop
        case shouldUpdatePlaceholder
        case shouldReflectModeSwitch(DataInputMode)
    }
    enum CollectionViewOutput {
        case shouldPresentAddImageView(SingleModeCellData)
        case shouldInsert(SingleModeCellData)
        case shouldUpdateResult([SingleModeCellData])
    }
    
    private let dataModel: DictionaryFullAccess
    private let settingsModel: UserSettingsStorageProtocol
    private lazy var dataUpdateManager: DataUpdateManager = DataUpdateManager(
        dataModel: dataModel, settings: settingsModel)

    private let dictionary: DictionariesEntity
    private var newArray: [WordsEntity] = []
    
    var currentWords: [SingleModeCellData] = []
    var currentText: String = ""
    
    var output = PassthroughSubject<Output, Never>()
    var singleOutput = PassthroughSubject<CollectionViewOutput, Never>()
    
    
    private(set) var inputMode: DataInputMode = .regular {
        didSet {
            output.send(.shouldReflectModeSwitch(inputMode))
        }
    }

    private(set) var requiresUpdate: Bool = false

    init(dataModel: DictionaryFullAccess, settingsModel: UserSettingsStorageProtocol, dictionary: DictionariesEntity){
        self.dictionary = dictionary
        self.dataModel = dataModel
        self.settingsModel = settingsModel
        
        NotificationCenter.default.addObserver(self, selector: #selector(appSeparatorDidChange(sender: )), name: .appSeparatorDidChange, object: nil)
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
        
    
    //MARK: System
    func preselectInputMode(mode: DataInputMode) {
        switch mode {
        case .regular:
            inputMode = .regular
        case .single:
            prepareModeSwitch()
        }
    }
    
    func prepareModeSwitch(){
        self.splitTheText(text: currentText)
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


    //MARK: RegularInput related
    func configureTextPlaceholder() -> String{
        return "viewPlaceholderWord".localized + " \(settingsModel.appSeparators.value) " + "viewPlaceholderMeaning".localized
    }
    func textSeparator() -> String{
        settingsModel.appSeparators.value
    }
    
    func updateText(text: String) {
        self.currentText = text
        if !text.isEmpty {
            self.requiresUpdate = true
        } else {
            self.requiresUpdate = false
        }
    }
    
    func splitTheText(text: String) {
        
        let singleModeData = dataUpdateManager.splitTheText(text: text, trimExceptions: false)
        
        currentWords = singleModeData
        currentText = text
        inputMode = .single
        
//        print(currentWords.isEmpty)
        if currentWords.isEmpty {
//            print("was called")
//            self.addEmptyCell()
            let newEntity = SingleModeCellData(word: "", definition: "", imageDetails: .init())
            currentWords.append(newEntity)
        }
//        else {
            singleOutput.send(.shouldUpdateResult(currentWords))
//        }
    }

    //MARK: Dictionary update
    func extendDictionary(){
        var data: VerificationResult
        
        switch  inputMode{
        case .regular:
            data = dataUpdateManager.verifyTextData(data: currentText, name: dictionary.language)
        case .single:
            data = dataUpdateManager.verifySingleCellData(data: currentWords, name: dictionary.language)
        }
        
        switch data {
        case .success(let singleData, _):
            do {
                try dataUpdateManager.addNewWordsFor(dictionary, from: singleData)
                requiresUpdate = false
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
    
    
    //MARK: SingleInput Related
    func wordDidType(id: UUID, text: String) {
        guard let pairIndex = currentWords.firstIndex(where: { $0.identifier == id }) else { return }

        currentWords[pairIndex].word = text
        requiresUpdate = true
    }
    
    func definitionDidType(id: UUID, text: String) {
        guard let pairIndex = currentWords.firstIndex(where: { $0.identifier == id }) else { return }
        
            currentWords[pairIndex].definition = text
            requiresUpdate = true
        
    }

    func enteredEditingMode() { }
    
    func exitedEditingMode()  { }
    
    func nameDidType(text: String) { }


    func requestedDeletion(id: UUID) {
        currentWords.removeAll(where: {$0.identifier == id})
        
        singleOutput.send(.shouldUpdateResult(currentWords))
        requiresUpdate = true
    }
    
    
    func addEmptyCell(){
        let newEntity = SingleModeCellData(word: "", definition: "", imageDetails: .init())
        currentWords.append(newEntity)
        
        singleOutput.send(.shouldInsert(newEntity))
        
    }
    
    func imageDidAdd(imageDetails: ImageDetailsCheck, data: SingleModeCellData){
        guard let pair = currentWords.first(where: {$0.identifier == data.identifier}), let pairIndex = currentWords.firstIndex(where: {$0 == pair}) else { return }
        
        currentWords[pairIndex].imageDetails = imageDetails
        
        singleOutput.send(.shouldUpdateResult(currentWords))
    }
    
    func requestAddImage(id: UUID){
        guard let pair = currentWords.first(where: { $0.identifier == id }) else { return }
        
        singleOutput.send(.shouldPresentAddImageView(pair))
    }
    
    //MARK: Action
    @objc func appSeparatorDidChange(sender: Any){
        output.send(.shouldUpdatePlaceholder)
    }
}


