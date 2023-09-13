//
//  GameDetailsViewModel.swift
//  Language
//
//  Created by Star Lord on 10/09/2023.
//

import Foundation
import Combine
import UIKit

class GameDetailsViewModel{

    enum Output {
        case shouldPresentAlert(UIAlertController)
        case shouldDismissView
        case error(Error)
    }
    enum CardState{
        case wasUpdated
        case wasDeleted
        case wasChecked
    }
    
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
    
    func viewWillDissapear(){
        switch cardState {
        case .wasChecked: delegate?.restoreCardCell()
        case .wasUpdated: delegate?.updateCardCell()
        case .wasDeleted: delegate?.deleteCardCell()
        }
    }
    
    func getCurrentSeparator() -> String{
        return settingsModel.appSeparators.value
    }
    
    func configureTexForTextView(isEditing: Bool) -> String{
        let separationFormatter = isEditing ? (" " + getCurrentSeparator() + " ") : "\n\n"
        let text = selectedWord.word + separationFormatter + selectedWord.meaning
        return text
    }
    
    private func getCurrentNumberOfWords() -> Int?{
        do {
            let words = try dataModel.fetchWords(for: selectedDictionary)
            return words.count
        } catch {
            return nil
        }
    }

    func deleteWord(){
        let delete = { [weak self] in
            self?.output.send(.shouldDismissView)
            self?.cardState = .wasDeleted
        }
        
        createAlertController {
            delete()
        }
    }

    func editWord(with text: String){
        guard text != currentText else { return }
        do {
            try dataModel.reassignWordsProperties(for: selectedWord, from: text)
            self.currentText = configureTexForTextView(isEditing: true)
            self.cardState = .wasUpdated
        } catch {
            output.send(.error(error))
        }
    }
    
    private func createAlertController(completion: @escaping () -> () ) {
        let alert = UIAlertController
            .alertWithAction(
                alertTitle: "gameDetails.deleteAlert.title".localized,
                alertMessage: "gameDetails.deleteAlert.message".localized,
                alertStyle: .actionSheet,
                action1Title: "system.cancel".localized,
                action1Style: .cancel
            )
        
        let confirm = UIAlertAction(title: "system.delete".localized, style: .destructive) {_ in
                completion()
            }

        guard let numberOfWords = getCurrentNumberOfWords() else {
            output.send(.error(DictionaryErrorType.deleteFailed))
            return
        }
        
        if numberOfWords == 1 {
            alert.message?.append("gameDetails.deleteAlert.message.warning".localized)
        }
        
        alert.addAction(confirm)
        output.send(.shouldPresentAlert(alert))
    }
}

