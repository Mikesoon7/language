//
//  Error Extension.swift
//  Learny
//
//  Created by Star's MacBook Air on 29.11.2023.
//
//TODO: Polish


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
    func presentError(_ error: Error, sourceView: UIView?) {
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
            case .imageUpdateFailed(let data, let entity):
                //MARK: FINISH
                title = "coreDataError.words.emptyWord".localized
                message = "coreDataError.words.emptyWord.message".localized
                //            case .failedToAssignEmptyCell(_):
                //                title = "Empty cells cannot be created ".localized
                //                message = "Would you like to delete them and save".localized
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
                action1Style: .cancel,
                sourceView: sourceView
            )
        self.present(alert, animated: true, completion: nil)
    }
}

//    func presentCreationError(_ error: VerificationResult) -> UIAlertController {
//        var alertController = UIAlertController()
////        var title = String()
////        var message = String()
////        var actionTitle = String()
//        
//
//        switch error {
//        case .emptyName:
//            alertController = UIAlertController.alertWithAction(
//                alertTitle: "nameAlert".localized,
//                alertMessage: "nameInfo".localized,
//                alertStyle: .actionSheet,
//                action1Title: "system.continue".localized,
//                action1Style: .cancel)
//            
//            //                title = "nameAlert".localized
//            //                message = "nameInfo".localized
//        case .emptyText:
//            alertController = UIAlertController.alertWithAction(
//                alertTitle: "Entry the text",
//                alertMessage: "To save dictionary, please add at least one word",
//                alertStyle: .actionSheet,
//                action1Title: "system.edit".localized,
//                action1Handler: nil,
//                action1Style: .cancel,
//                action2Title: "system.delete".localized,
//                action2Handler: nil,
//                action2Style: .destructive,
//                sourceView: self.view,
//                sourceRect: self.view.bounds )
//        case .emptyArray:
//            alertController = UIAlertController.alertWithAction(
//                alertTitle: "Entry the content",
//                alertMessage: "To save dictionary, please add at least one cell with information. Image would also work",
//                alertStyle: .actionSheet,
//                action1Title: "system.edit".localized,
//                action1Handler: nil,
//                action1Style: .cancel,
//                action2Title: "system.delete".localized,
//                action2Handler: nil,
//                action2Style: .destructive,
//                sourceView: self.view,
//                sourceRect: self.view.bounds )
//
//        case .croppedText:
//            alertController = UIAlertController.alertWithAction(
//                alertTitle: "The dictionary content is empty",
//                alertMessage: "It seems that exception symbols cropped the text. Please check your settings and try again",
//                alertStyle: .actionSheet,
//                action1Title: "system.continue".localized,
//                action1Handler: nil,
//                action1Style: .cancel,
//                action2Title: "system.delete".localized,
//                action2Handler: nil,
//                action2Style: .destructive,
//                sourceView: self.view,
//                sourceRect: self.view.bounds )
//        }
//        return alertController
//        
//    }
//}
