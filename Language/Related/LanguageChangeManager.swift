//
//  LanguageChangeManager.swift
//  Language
//
//  Created by Star Lord on 08/04/2023.
//

import Foundation
import UIKit

class LanguageChangeManager {
    static let shared = LanguageChangeManager()
    static let key = "AppleLanguages"
    private var bundle: Bundle
    
    private init() {
        let language = UserDefaults.standard.string(forKey: LanguageChangeManager.key) ?? "en"
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else {
            bundle = Bundle.main
            return
        }
        bundle = Bundle(path: path) ?? Bundle.main
    }
    func changeLanguage(to languageKey: String){
        let path = Bundle.main.path(forResource: languageKey, ofType: "lproj")
        UserDefaults.standard.set([languageKey], forKey: LanguageChangeManager.key)

        if let newPath = path, let newBundle = Bundle(path: newPath) {
            bundle = newBundle
        } else {
            print("No lanugage found.")
        }
        NotificationCenter.default.post(name: .appLanguageDidChange, object: nil)
    }
    func localizedString(forKey: String) -> String{
        return bundle.localizedString(forKey: forKey, value: nil, table: nil)
    }
}
