//
//  MenuViewModel.swift
//  Language
//
//  Created by Star Lord on 07/07/2023.
//
//  REFACTORING STATE: CHECKED

import UIKit
import CoreData
import Combine


final class MenuViewModel{
    enum Output{
        case needReload
        case needDelete(Int)
        case needUpdate(Int)
        case shouldPresentAddView
        case shouldPresentDetailsView(DictionariesEntity)
        case shouldPresentEditView(DictionariesEntity)
        case shouldPresentTutorialView
        case shouldUpdateLabels
        case shouldUpdateFont
        case error(Error)
    }

    private let model: Dictionary_Words_LogsManager
    private let settingsModel: UserSettingsStorageProtocol
    private var cancellables = Set<AnyCancellable>()
    var dictionaries: [DictionariesEntity] = []
        
    @Published var output = PassthroughSubject<Output, Never>()
    
    init(model: Dictionary_Words_LogsManager, settingsModel: UserSettingsStorageProtocol) {
        self.model = model
        self.settingsModel = settingsModel
        model.dictionaryDidChange
            .sink { [weak self] type in
                switch type {
                case .wasDeleted(let item):
                    self?.fetch()
                    self?.output.send(.needDelete(item))
                case .wasAdded:
                    self?.fetch()
                    self?.output.send(.needReload)
                case .wasUpdated(let section):
                    self?.fetch()
                    self?.output.send(.needUpdate(section))
                }
            }
            .store(in: &cancellables)
        fetch()
        NotificationCenter.default.addObserver(
            self, selector: #selector(languageDidChange(sender:)),
            name: .appLanguageDidChange, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(fontDidChange(sender:)),
            name: .appFontDidChange, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(validateLaunchStatus(sender: )),
            name: .appDidFinishLaunchAnimation, object: nil)
    }
    
    deinit { NotificationCenter.default.removeObserver(self)}

    //MARK: Fetch and update local dictionary variable.
    func fetch(){
        do {
            dictionaries = try model.fetchDictionaries()
        } catch {
            output.send(.error(error))
        }
    }
    //MARK: Deleted dictionary restoring
    ///Asks model is restore available
    func canUndo() -> Bool {
        return model.canUndo()
    }
    ///Tells model to restore last deleted dictionary
    func undoLastDeletion(){
        model.undoDeletion()
    }
    func currentFont() -> UIFont {
        let font = settingsModel.appFont.selectedFont
        
        return font.withSize(23)
    }
    
    //MARK: Cell swipe actions related.
    //Delete dictioanary action was tapped.
    func deleteDictionary(at index: IndexPath) {
        let dictionary = dictionaries[index.item]
        do {
            try model.delete(dictionary: dictionary)
        } catch {
            output.send(.error(error))
        }
    }
    //Edit dictionary action was tapped.
    func editDictionary(at index: IndexPath) {
        let dictionary = dictionaries[index.item]
        output.send(.shouldPresentEditView(dictionary))
    }
    
    //TODO: - Finish share functionality implementation.
    func shareCellsInformation(at index: IndexPath) -> String{
        let dictionary = dictionaries[index.item]
        var words = "Here is my \(dictionary.language) dictionary from Learny memory cards app. \n"
        do {
            let pairs = try model.fetchWords(for: dictionary)
            pairs.forEach({ word in
                words.append("\n" + word.word + " - " + word.meaning)
            })
        } catch {
            output.send(.error(error))
        }
        return words
    }
    
    //MARK: TableView Related
    func dataForTableCellAt(item: Int) -> DataForMenuCell? {
        guard item != dictionaries.count else {
            return nil
        }
        let dictionary = dictionaries[item]
        return DataForMenuCell(name: dictionary.language, numberOfCards: dictionary.numberOfCards)
    }
    
    func numberOfSectionsInTableView() -> Int{
        return dictionaries.count + 1
    }
    
    func didSelectTableRowAt(item: Int){
        guard item != dictionaries.count else {
            output.send(.shouldPresentAddView)
            return
        }
        let dictionary = dictionaries[item]
        output.send(.shouldPresentDetailsView(dictionary))
    }
    
    @objc func languageDidChange(sender: Any){
        output.send(.shouldUpdateLabels)
    }
    @objc func fontDidChange(sender: Any){
        output.send(.shouldUpdateFont)
    }
    @objc func validateLaunchStatus(sender: Notification){
        let isFirst = settingsModel.appLaunchStatus.isFirstLaunch
        if isFirst {
            settingsModel.reload(newValue: .lauchStatus(.isNotFirst))
            output.send(.shouldPresentTutorialView)
        }
    }
}


