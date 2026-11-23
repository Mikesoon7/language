//
//  SearchViewAlertController.swift
//  Learny
//
//  Created by Star Lord on 06/02/2026.
//

import Foundation
import Combine
import UIKit

enum SingleEntryEditAlertType {
    case emptyText
    case invalidContent
}

class SearchViewAlertController {
    
    let action = PassthroughSubject<AlertAction, Never>()
    

    func makeAlert(alertType: SingleEntryEditAlertType ) -> UIAlertController {
        let titleKey: String
        let messageKey: String
        
        switch alertType {
        case .emptyText:
            titleKey = "searchView.saveError"
            messageKey = "emptyText.message"
            
        case .invalidContent:
            titleKey = "searchView.saveError"
            messageKey = "incorrectInput.message"
        }
        
        let alert = UIAlertController.alertWithAction(
            alertTitle: titleKey.localized,
            alertMessage: messageKey.localized,
            alertStyle: .actionSheet,
            action1Title: "system.agreeInformal".localized,
            action1Handler: { _ in },
            action1Style: .cancel
            )
        return alert
    }
}
