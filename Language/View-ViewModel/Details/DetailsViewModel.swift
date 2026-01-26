//
//  DetailsViewModel.swift
//  Language
//
//  Created by Star Lord on 19/07/2023.
//
//TODO: Polished

import Foundation
import Combine

enum DataInputMode {
    case regular
    case single
}
enum DetailsViewPrimaryActions {
    case saveAndSwitch
    case doneAndSwitch
    case addButton
    case switchButton
    case undefined
}

class DetailsViewModel{
    enum EditingMode {
        case idle
        case active
    }
    
    enum Output {
        case shouldUpdatePlaceholder
        case shouldUpdateLangauge
        case shouldUpdateFont
        case shouldUpdatePicker
    }
    
    enum EditOutput {
        case presentModalEditor(inputMode: DataInputMode, text: String?)
        case shouldPresentAlert(AlertType)
        case shouldPresentError(Error)
        case editFinishedSuccessfully
    }
    

    private var dataModel: DictionaryFullAccess
    private var settingsModel: UserSettingsStorageProtocol
    private var updateManager: DataUpdateManager
    
    private(set) var dictionary: DictionariesEntity
    private var currentText: String = ""
    
    private var cancellable = Set<AnyCancellable>()
    
    private let cardsDivider: Int = 10
    private var numberOfCards: Int = 0
    
    
    private var selectedOrder: DictionariesSettings.CardOrder
    private var hideTransaltion: Bool
    private var selectedDisplayNumber : Int
    
    private var editingMode: EditingMode = .idle
    private var layoutHorizontalClass: CustomLayoutContext = .regular

    var output = PassthroughSubject<Output, Never>()
    var editOutput = PassthroughSubject<EditOutput, Never>()
    
    init(model: DictionaryFullAccess, settings: UserSettingsStorageProtocol, dictionary: DictionariesEntity){
        self.dataModel = model
        self.settingsModel = settings
        self.updateManager = DataUpdateManager(dataModel: model, settings: settings)
        self.dictionary = dictionary
        self.numberOfCards = Int(dictionary.numberOfCards)
        
        let dictionaryDetails = model.fetchSettings(for: dictionary)
        self.selectedOrder = dictionaryDetails?.cardOrder ?? .normal
        self.hideTransaltion = dictionaryDetails?.isOneSideMode ?? false
        self.selectedDisplayNumber = Int(dictionaryDetails?.selectedNumber ?? Int64(min(numberOfCards, cardsDivider)))

        guard selectedDisplayNumber <= numberOfCards else {
            selectedDisplayNumber = numberOfCards
            return
        }

        dataModel.settingsDidChange
            .sink { [weak self] type in
                if type {
                    self?.retrieveUpdatedDictionaryData()
                }
            }
            .store(in: &cancellable)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(languageDidChange(sender: )),
            name: .appLanguageDidChange, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(fontDidChange(sender: )),
            name: .appFontDidChange, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(seperatorDidChange(sender: )),
            name: .appSeparatorDidChange, object: nil)
        
    }
    deinit { NotificationCenter.default.removeObserver(self) }

    
    //MARK: Modify details related to the dictionary.
    private func retrieveUpdatedDictionaryData(){
        guard let settings = dataModel.fetchSettings(for: dictionary) else {
            return
        }
        
        selectedDisplayNumber =     Int(settings.selectedNumber)
        selectedOrder =             settings.cardOrder
        hideTransaltion =           settings.isOneSideMode
        numberOfCards =             Int(dictionary.numberOfCards)


        output.send(.shouldUpdatePicker)
    }
    func extendDictionary(){
        let data = updateManager.verifyTextData(data: currentText, name: dictionary.language)
        
        switch data {
        case .success(let singleData, _):
            do {
                try updateManager.addNewWordsFor(dictionary, from: singleData)
                editOutput.send(.editFinishedSuccessfully)
            } catch {
                editOutput.send(.shouldPresentError(error))
            }
        case .emptyName:
            editOutput.send(.shouldPresentAlert(.emptyName))
        case .emptyText:
            editOutput.send(.shouldPresentAlert(.emptyText))
        case .croppedText:
            editOutput.send(.shouldPresentAlert(.invalidContent))
        case .emptyArray:
            editOutput.send(.shouldPresentAlert(.emptyArray))
        }
    }
    
    //MARK: Text input view related
    func configureTextPlaceholder() -> String{
        return "viewPlaceholderWord".localized + " \(settingsModel.appSeparators.value) " + "viewPlaceholderMeaning".localized
    }
    func textSeparator() -> String{
        settingsModel.appSeparators.value
    }

    
    //MARK: Switch related
    func selectedCardsOrder() -> DictionariesSettings.CardOrder {
        return self.selectedOrder
    }
    func isHideTranslationOn() -> Bool {
        return hideTransaltion
    }
    func selectedNumberOfCards() -> Int {
        return selectedDisplayNumber
    }
    
    func hideTranslationDidChange(on: Bool){
        do {
            try updateManager.settingsDidChangeFor(dictionary, isOneSideMode: on)
        } catch {
            editOutput.send(.shouldPresentError(error))
        }
    }
    func cardOrderDidChange(order: DictionariesSettings.CardOrder){
        do {
            try updateManager.settingsDidChangeFor(dictionary, cardsOrderSelection: order)
        } catch {
            editOutput.send(.shouldPresentError(error))
        }
    }
    
    //MARK: Layout change related
    func layoutDidChange(to sizeClass: CustomLayoutContext) {
        self.layoutHorizontalClass = sizeClass
        switch sizeClass {
        case .compact:
            switch editingMode {
            case .active:
                editOutput.send(.presentModalEditor(inputMode: .regular, text: currentText))
                editingMode = .idle
                currentText = ""
            default     :
                break
            }
        default:
            break
        }
    }
    func defineIntialSizeclass(sizeClass: CustomLayoutContext){
        self.layoutHorizontalClass = sizeClass
    }
    
    //MARK: Edit state Related
    //Logic related to TextView content and layout state
    func userTappedAdd() {
        editOutput.send(.presentModalEditor(
            inputMode: .regular, text: currentText))
    }
    func userTappedSingleAdd() {
        editOutput.send(.presentModalEditor(
            inputMode: .single, text: currentText))
    }

    func userDidType(text: String){
        self.currentText = text
    }
    
    func userBeganEditing(){
        self.editingMode = .active
    }
    func userFinishedEditing(){
        self.editingMode = .idle
    }
    
        
    //MARK: Picker related.
    func selectedRowForPicker() -> Int {
        let selectedRow = Int(selectedDisplayNumber / cardsDivider)
        switch selectedDisplayNumber % cardsDivider {
        case 0:
            return selectedRow - 1
        default:
            return selectedRow
        }

    }
    func numberOfRowsInComponent() -> Int {
        switch numberOfCards % cardsDivider {
        case 0: 
            return numberOfCards / cardsDivider
        default: 
            return numberOfCards / cardsDivider + 1
        }
    }
    func titleForPickerAt(row: Int) -> String{
        let numberOfOptions = Int(numberOfCards / cardsDivider)
        if row == numberOfOptions || numberOfOptions == 0 {
            return String(numberOfCards)
        } else {
             return String((row + 1) * cardsDivider)
        }
    }
    func didSelectPickerRow(row: Int){
        do {
            try updateManager.settingsDidChangeFor(dictionary, selectedDisplayNumber: Int64(titleForPickerAt(row: row)) ?? Int64(numberOfCards))
        } catch {
            editOutput.send(.shouldPresentError(error))
        }
    }

    //MARK: Actions
    @objc func languageDidChange(sender: Any){
        output.send(.shouldUpdateLangauge)
    }
    @objc func fontDidChange(sender: Any){
        output.send(.shouldUpdateFont)
    }
    @objc func seperatorDidChange(sender: Any){
        output.send(.shouldUpdatePlaceholder)
    }
}
