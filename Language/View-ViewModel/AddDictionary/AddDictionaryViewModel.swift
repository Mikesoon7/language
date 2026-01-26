//
//  AddDictionaryModel.swift
//  Language
//
//  Created by Star Lord on 14/07/2023.
//
//TODO: Polished

import Foundation
import Combine


class AddDictionaryViewModel {    
    enum Output {
        case shouldPresentError(Error)
        case shouldPresentAlert(AlertType)
        case shouldHighlightError(String)
        case shouldReflectInputModeChange(DataInputMode)
        case shouldReflectLanugageChange
        case shouldReflectFontChange
        case shouldUpdatePlaceholder
        case shouldPop
    }
    
    enum CollectionViewOutput {
        case shouldPresentAddImageView(SingleModeCellData)
        case shouldInsert(SingleModeCellData)
        case shouldReloadData([SingleModeCellData])
    }
    
    private var dataModel: DictionaryFullAccess
    private var settingsModel: UserSettingsStorageProtocol
    private var dataUpdateManager: DataUpdateManager
    
    
    private var currentText: String = ""
    private var dictionaryName: String = ""
    private var currentWords: [SingleModeCellData] = []

    private var inputMode: DataInputMode = .regular {
        didSet {
//            guard oldValue != inputMode else { return }
            output.send(.shouldReflectInputModeChange(inputMode))
        }
    }
//    private var editState: EditState = .idle {
//        didSet {
//            output.send(.shouldReflectEditStateChange(self.editState))
//        }
//    }
    
    private(set) var requiresUpdate: Bool = false
    
    var output = PassthroughSubject<Output, Never>()
    var singleOutput = PassthroughSubject<CollectionViewOutput, Never>()

    init(model: DictionaryFullAccess, settingsModel: UserSettingsStorageProtocol) {
        self.dataModel = model
        self.settingsModel = settingsModel
        
        self.dataUpdateManager = DataUpdateManager(dataModel: model, settings: settingsModel)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appLanguageDidChange(sender: )), name:
                .appLanguageDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appSeparatorDidChange(sender: )), name:
                .appSeparatorDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appFontDidChange(sender: )), name:
                .appFontDidChange, object: nil)
        
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
    
    
    //MARK: Single Mode Methods
    ///Transforms text from textView into an array of text pairs.
    func splitTheText(text: String) {
        let singleModeData = dataUpdateManager.splitTheText(text: text, trimExceptions: false)
        
        currentWords = singleModeData
        currentText = text
        inputMode = .single
        
        if currentWords.isEmpty {
            let newEntity = SingleModeCellData(word: "", definition: "", imageDetails: .init())
            currentWords.append(newEntity)

//            self.addEmptyCell()
        }
//        else {
            singleOutput.send(.shouldReloadData(currentWords))
//        }
    }
    
    func prepareModeSwitch(){
        self.splitTheText(text: currentText)
    }
    
    func preselectInputMode(mode: DataInputMode){
        switch mode {
        case .regular:
            inputMode = .regular
        case .single:
            prepareModeSwitch()
        }
    }
    

    func addEmptyCell(){
        let newEntity = SingleModeCellData(word: "", definition: "", imageDetails: .init())
        currentWords.append(newEntity)
        
        singleOutput.send(.shouldInsert(newEntity))
    }
    
    //MARK: Image Handling
    func requestAddImage(id: UUID) {
        guard let pair = currentWords.first(where: { $0.identifier == id }) else { return }

        singleOutput.send(.shouldPresentAddImageView(pair))
    }

    func didSelectAnImage(imageDetails: ImageDetailsCheck, data: SingleModeCellData) {
        guard let pair = currentWords.first(where: {$0.identifier == data.identifier}), let pairIndex = currentWords.firstIndex(where: {$0 == pair}) else { return }
        
        currentWords[pairIndex].imageDetails = imageDetails
        requiresUpdate = true
        
        
        singleOutput.send(.shouldReloadData(currentWords))
        
    }
    
    func currentName() -> String {
        return dictionaryName
    }


    
    
    //MARK: TextView
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
        }
    }
    
    func updateName(name: String) {
        self.dictionaryName = name
        if !name.isEmpty {
            self.requiresUpdate = true
        }
    }
    
    //MARK: Dictionary Creation
    func createDictionary(){
        var data: VerificationResult
        
        switch inputMode {
        case .regular:
            data = dataUpdateManager.verifyTextData(data: currentText, name: dictionaryName)
        case .single:
            data = dataUpdateManager.verifySingleCellData(data: currentWords, name: dictionaryName)
        }
        
        switch data {
        case .success(let singleData, let name):
            do {
                try dataUpdateManager.createDictionary(name, content: singleData)
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
    
    func viewRequestedToClose(){
        if requiresUpdate {
            output.send(.shouldPresentAlert( .saveAlert))
        } else {
            self.requiresUpdate = false
            self.output.send(.shouldPop)
        }
    }
    func userPermitedToClose(){
        self.requiresUpdate = false
        self.output.send(.shouldPop)
    }
    
    
    
    func wordDidType(id: UUID, text: String) {
        guard let pairIndex = currentWords.firstIndex(where: {$0.identifier == id}) else { return }
        
        currentWords[pairIndex].word = text
        requiresUpdate = true

    }
    
    func definitionDidType(id: UUID, text: String) {
        guard let pairIndex = currentWords.firstIndex(where: { $0.identifier == id }) else { return }
        
        currentWords[pairIndex].definition = text
        requiresUpdate = true
    }
    
    func nameDidType(text: String) {
        self.dictionaryName = text
        if !text.isEmpty {
            self.requiresUpdate = true
        }
    }
    func requestedDeletion(id: UUID) {
        currentWords.removeAll(where: {$0.identifier == id})
        
        singleOutput.send(.shouldReloadData(currentWords))
        requiresUpdate = true
    }

    func enteredEditingMode()   { }
    
    func exitedEditingMode()    { }
    


        
    //MARK: Actions
    @objc func appLanguageDidChange(sender: Any){
        output.send(.shouldReflectLanugageChange)
    }
    @objc func appSeparatorDidChange(sender: Any){
        output.send(.shouldUpdatePlaceholder)
    }
    @objc func appFontDidChange(sender: Any){
        output.send(.shouldReflectFontChange)
    }
    
}
