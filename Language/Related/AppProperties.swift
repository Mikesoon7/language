//
//  AppProperties.swift
//  Learny
//
//  Created by Star Lord on 14/02/2025.
//
//TODO: Polish

import Foundation

class AppLinks {
    static var websiteLink: String = "https://learnycards.com"
    static var supportLink: String = "https://learnycards.com/contact"
    static var privacyPolicyLink: String = "https://learnycards.com/privacy-policy"
    static var supportAuthorLink: String = "https://buymeacoffee.com/learnyforeveryone"
    static var tutorialUUID: UUID = {
        if let savedString = UserDefaults.standard.string(forKey: "tutorialUUID"),
           let savedUUID = UUID(uuidString: savedString) {
            return savedUUID
        } else {
            let id = UUID()
            UserDefaults.standard.set(id.uuidString, forKey: "tutorialUUID")
            return id
        }
    }()
}
