//
//  GameDetailsViewModel.swift
//  Language
//
//  Created by Star Lord on 10/09/2023.
//
//  REFACTORING STATE: CHECKED

import Foundation
import Combine
import UIKit


class GameDetailsViewModel{
    //MARK: Enums
    enum Output {
        case shouldPresentAlert(UIAlertController)
        case shouldDismissView
        case shouldProcceedEditing
        case shouldEndEditing
        case error(Error)
    }
    enum CardState{
        case wasUpdated
        case wasDeleted
        case wasChecked
    }
    
    //MARK: Properties
    private let dataModel: Dictionary_WordsManager
    private let settingsModel: UserSettingsStorageProtocol
    
    var delegate: MainGameVCDelegate?
    
    private var selectedDictionary: DictionariesEntity
    private var selectedWord: WordsEntity
    
    private var cardState: CardState = .wasChecked
    
    private var currentText: String = .init()
    
    var output = PassthroughSubject<Output, Never>()
    private var cancellable = Set<AnyCancellable>()
    
    
    init(dataModel: Dictionary_WordsManager, settingsModel: UserSettingsStorageProtocol, dictionary: DictionariesEntity, word: WordsEntity, delegate: MainGameVCDelegate){
        self.dataModel = dataModel
        self.settingsModel = settingsModel
        self.selectedDictionary = dictionary
        self.selectedWord = word
        self.delegate = delegate
        self.currentText = configureTexForTextView(isEditing: true)
    }
    
    //MARK: Functional methods.
    ///Calls on VC deinition. Calling delegate method in responce on changes.
    func viewWillDissapear(){
        switch cardState {
        case .wasChecked: delegate?.restoreCardCell()
        case .wasUpdated: delegate?.updateCardCell()
        case .wasDeleted: delegate?.deleteCardCell()
        }
    }
    ///Configure and returning text for textView.
    func configureTexForTextView(isEditing: Bool) -> String{
        let separationFormatter = isEditing ? (" " + settingsModel.appSeparators.value + " ") : "\n\n"
        let text = selectedWord.word + separationFormatter + selectedWord.meaning
        return text
    }
    
    ///Presenting alert to submit deletion.
    func deleteWord(view: UIView?){
        configureAlert(forDeletion: true, view: view)
    }
    
    func configureTextPlaceholder() -> String{
        return "viewPlaceholderWord".localized + " \(settingsModel.appSeparators.value) " + "viewPlaceholderMeaning".localized
    }
    func textSeparator() -> String{
        settingsModel.appSeparators.value
    }
    

    ///Validate text and saving it dataModel.
    func editWord(with text: String, view: UIView?){
        guard text != currentText else {
            output.send(.shouldEndEditing)
            return
        }
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            configureAlert(forDeletion: false, view: view)
            return
        }
        
        do {
            try dataModel.reassignWordsProperties(for: selectedWord, from: text)
            self.currentText = text
            self.cardState = .wasUpdated
            output.send(.shouldEndEditing)
        } catch {
            output.send(.error(error))
        }
    }
    
    //MARK: System methods
    ///Returns number of words or nil.
    private func getCurrentNumberOfWords() -> Int?{
        do {
            let words = try dataModel.fetchWords(for: selectedDictionary)
            return words.count
        } catch {
            return nil
        }
    }
    ///Important. Since deletion triggers on behalf of MainGameViewModel, this method changing card state and triggering view dismiss.
    private func delete(){
        cardState = .wasDeleted
        output.send(.shouldDismissView)
    }
    
    ///Configures and send alert. Creates alert for edit, if delete = false.
    private func configureAlert(forDeletion: Bool, view: UIView?){
        let alert = UIAlertController
            .alertWithAction(
                alertTitle: forDeletion
                ? "gameDetails.deleteAlert.title".localized
                : "gameDetails.emptyTextAlert.title".localized,
                alertMessage: forDeletion
                ? "gameDetails.deleteAlert.message".localized
                : "gameDetails.emptyTextAlert.message".localized,
                sourceView: view
            )
        
        let confirm = UIAlertAction(title: "system.delete".localized, style: .destructive) { [weak self] _ in
            self?.delete()
        }
        
        let cancel = UIAlertAction(title: "system.cancel".localized, style: .cancel, handler: { [weak self] _ in
            if !forDeletion{
                self?.output.send(.shouldProcceedEditing)
            }
        })
        
        cancel.setValue(UIColor.label, forKey: "titleTextColor")
        
        guard let numberOfWords = getCurrentNumberOfWords() else {
            output.send(.error(DictionaryErrorType.deleteFailed(selectedWord.dictionary?.language ?? "")))
            return
        }
        
        if numberOfWords == 1 {
            alert.message?.append("gameDetails.deleteAlert.message.warning".localized)
        }
        
        alert.addAction(cancel)
        alert.addAction(confirm)
        output.send(.shouldPresentAlert(alert))
    }
}

