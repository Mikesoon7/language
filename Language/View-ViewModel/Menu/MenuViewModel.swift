//
//  MenuViewModel.swift
//  Language
//
//  Created by Star Lord on 07/07/2023.
//

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
                case .wasDeleted(let section):
                    self?.fetch()
                    self?.output.send(.needDelete(section))
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
        NotificationCenter.default.addObserver(self, selector: #selector(languageDidChange(sender:)), name: .appLanguageDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fontDidChange(sender:)), name: .appFontDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    //MARK: System
    func validateLaunchStatus(){
        let isFirst = settingsModel.appLaunchStatus.isFirstLaunch
        if isFirst {
            settingsModel.reload(newValue: .lauchStatus(.isNotFirst))
            output.send(.shouldPresentTutorialView)
        }
    }

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
        let dictionary = dictionaries[index.section]
        do {
            try model.delete(dictionary: dictionary)
        } catch {
            output.send(.error(error))
        }
    }
    //Edit dictionary action was tapped.
    func editDictionary(at index: IndexPath) {
        let dictionary = dictionaries[index.section]
        output.send(.shouldPresentEditView(dictionary))
    }
    
    //MARK: TableView Related
    func dataForTableCellAt(section: Int) -> DictionariesEntity? {
        guard section != dictionaries.count else {
            return nil
        }
        return dictionaries[section]
    }
    
    func numberOfSectionsInTableView() -> Int{
        return dictionaries.count + 1
    }
    
    func didSelectTableRowAt(section: Int){
        guard section != dictionaries.count else {
            output.send(.shouldPresentAddView)
            return
        }
        let dictionary = dictionaries[section]
        output.send(.shouldPresentDetailsView(dictionary))
    }
    
    @objc func languageDidChange(sender: Any){
        output.send(.shouldUpdateLabels)
    }
    @objc func fontDidChange(sender: Any){
        output.send(.shouldUpdateFont)
    }
}


