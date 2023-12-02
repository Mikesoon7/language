//
//  Error Extension.swift
//  Learny
//
//  Created by Star's MacBook Air on 29.11.2023.
//

import Foundation
import UIKit

extension UIViewController{
    func presentUnknownError(){
        let alertController = UIAlertController(
            title: "unknownError.title".localized,
            message: "unknownError.message".localized,
            preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "system.agreeFormal".localized, style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
    func presentError(_ error: Error) {
        var title = String()
        var message = "unknownError.message".localized
        
        switch error{
        case let error as DictionaryErrorType:
            switch error{
            case .creationFailed(let name):
                title = "coreDataError.dictionary.creation".localized + " '\(name)'"
            case .fetchFailed:
                title = "coreDataError.dictionary.fetch".localized
            case .updateFailed(let name):
                title = "coreDataError.dictionary.update".localized + " '\(name)'"
            case .additionFailed(let name):
                title = "coreDataError.dictionary.addition".localized + " '\(name)'"
            case .updateOrderFailed:
                title = "coreDataError.dictionary.orderUpdate".localized
            case .deleteFailed(let name):
                title = "coreDataError.dictionary.deletion".localized + " '\(name)'"
            }
        case let error as WordsErrorType:
            switch error{
            case .deleteFailed(let word):
                title = "coreDataError.words.deletion".localized + " '\(word)'"
            case .fetchFailed(let name):
                title = "coreDataError.words.fetch".localized + " '\(name)'"
            case .failedToAssignEmptyString(let word):
                title = "coreDataError.words.emptyWord".localized + " '\(word)'"
                message = "coreDataError.words.emptyWord.message".localized
            }
        case let error as LogsErrorType:
            switch error {
            case .creationFailed(let name):
                title = "coreDataError.logs.creation".localized + " '\(name)'"
            case .accessFailed(let name):
                title = "coreDataError.logs.update".localized + " '\(name)'"
            case .fetchFailed:
                title = "coreDataError.logs.fetch".localized
            }
            
        case let error as CoreDataErrorType:
            switch error{
            case .saveFailed:
                title = "unknownError.save.title".localized
                message = "unknownError.save.message".localized
            }
        default:
            title = "unknownError.title".localized
        }
        let alert = UIAlertController
            .alertWithAction(
                alertTitle: title,
                alertMessage: message,
                alertStyle: .alert,
                action1Title: "system.agreeFormal".localized,
                action1Style: .cancel)
        self.present(alert, animated: true, completion: nil)
    }
}
