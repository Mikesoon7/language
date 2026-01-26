//
//  AlertCoordinator.swift
//  Learny
//
//  Created by Star Lord on 19/12/2025.
//

import Foundation
import UIKit
import Combine

enum AlertType {
    case emptyName
    case emptyText
    case emptyArray
    case invalidContent
    case saveAlert
}

enum AlertAction {
    case save
    case delete
    case edit
    case cancel
}


class AlertCoordinator {
    
    let action = PassthroughSubject<AlertAction, Never>()
    

    func makeAlert(alertType: AlertType ) -> UIAlertController {
        let titleKey: String
        let messageKey: String
        
        switch alertType {
        case .saveAlert:
            let alert = UIAlertController.alertWithAction(
                alertTitle: "edit.unsavedAlert.title".localized,
                alertMessage: "edit.unsavedAlert.message".localized,
                alertStyle: .actionSheet,
                
                action1Title: "system.save".localized,
                action1Handler: { _ in self.action.send(.save)},
                action1Style: .default,
                
                action2Title: "system.delete".localized,
                action2Handler: { _ in self.action.send(.delete) },
                action2Style: .destructive,
            )
            let editAction = UIAlertAction.init(title: "system.edit".localized, style: .cancel)
            { _ in self.action.send(.edit)  }
            
            editAction.setValue(UIColor.label, forKey: "titleTextColor")
            alert.addAction(editAction)
            
            
            return alert
            
        case .emptyName:
            
            return UIAlertController.alertWithAction(
                alertTitle: "addWords.emptyName.title".localized,
                alertMessage: "addWords.emptyName.message".localized,
                alertStyle: .actionSheet,
                action1Title: "system.continue".localized,
                action1Style: .cancel)
            
        case .emptyText:
            titleKey = "addWords.emptyText.title"
            messageKey = "addWords.emptyText.message"
            
        case .emptyArray:
            titleKey = "addWords.emptyCells.title"
            messageKey = "addWords.emptyCells.message"
            
        case .invalidContent:
            titleKey = "addWords.croppedText.title"
            messageKey = "addWords.croppedText.message"
        }
        
        let alert = UIAlertController.alertWithAction(
            alertTitle: titleKey.localized,
            alertMessage: messageKey.localized,
            alertStyle: .actionSheet,
            action1Title: "system.edit".localized,
            action1Handler: { _ in self.action.send(.edit) },
            action1Style: .cancel,
            action2Title: "system.delete".localized,
            action2Handler: { _ in self.action.send(.delete)},
            action2Style: .destructive )
        return alert
    }
}
