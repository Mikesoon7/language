//
//  MenuViewModel.swift
//  Language
//
//  Created by Star Lord on 07/07/2023.
//
//TODO: Polished

import UIKit
import CoreData
import Combine


final class MenuViewModel{
    enum Output{
        case shouldPresentAddView
        case shouldPresentDetailsView(DictionariesEntity)
        case shouldPresentEditView(DictionariesEntity)
        case shouldPresentInspectView(DictionariesEntity)
        case shouldPresentGameTutorialView(DictionariesEntity)
        case shouldPresentTutorialView
        case shouldUpdateLabels
        case shouldUpdateFont
        case error(Error)
    }
    enum CollectionOutput {
        case needReload
        case needDelete(Int)
        case needUpdate(Int)
    }
    
    private let model: Dictionary_Words_LogsManager
    private let settingsModel: UserSettingsStorageProtocol
    private var cancellables = Set<AnyCancellable>()
    var dictionaries: [DictionariesEntity] = []
    
    var output = PassthroughSubject<Output, Never>()
    var collectionOutput = PassthroughSubject<CollectionOutput, Never>()
    
    init(model: Dictionary_Words_LogsManager, settingsModel: UserSettingsStorageProtocol) {
        self.model = model
        self.settingsModel = settingsModel
        model.dictionaryDidChange
            .sink { [weak self] type in
                guard let self = self else { return }
                switch type {
                case .wasDeleted(let item):
                    self.fetch()
                    self.collectionOutput.send(.needDelete(item))
                case .wasAdded:
                    self.fetch()
                    self.collectionOutput.send(.needReload)
                case .wasUpdated(let section):
                    self.fetch()
                    self.collectionOutput.send(.needUpdate(section))
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

    //MARK: Cell swipe actions related.
    //Delete dictioanary action was tapped.
    func deleteDictionary(at item: Int) {
        let dictionary = dictionaries[item]
        do {
            try model.deleteDictionary(dictionary)
        } catch {
            output.send(.error(error))
        }
    }
    //Edit dictionary action was tapped.
    func editDictionary(at item: Int) {
        let dictionary = dictionaries[item]
        output.send(.shouldPresentEditView(dictionary))
    }
    func inspectDictionary(at item: Int) {
        let dictionary = dictionaries[item]
        output.send(.shouldPresentInspectView(dictionary))
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
    
    //MARK: Collection Related
    func dataForCell(at item: Int) -> DataForMenuCell? {
        guard item != dictionaries.count else {
            return nil
        }
        let dictionary = dictionaries[item]
        return DataForMenuCell(name: dictionary.language, numberOfCards: dictionary.numberOfCards)
    }
    
    func numberOfCells() -> Int{
        return dictionaries.count + 1
    }
    
    func didSelectCell(at item: Int){
        guard item != dictionaries.count else {
            output.send(.shouldPresentAddView)
            return
        }
        let dictionary = dictionaries[ item]
        if (dictionary.id == AppLinks.tutorialUUID && settingsModel.appTutorialStatus.isFirstAccess) || settingsModel.appTutorialStatus.isFirstAccess {
            settingsModel.reload(newValue:  .tutorialStatus(.isNotFirst))
            output.send(.shouldPresentGameTutorialView(dictionary))
        } else {
            output.send(.shouldPresentDetailsView(dictionary))
        }
    }

    //MARK: Actions
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


