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
    private var bundle: Bundle
    
    private init() {
        let language = UserDefaults.standard.string(forKey: "AppleLanguages") ?? "en"
        let path = Bundle.main.path(forResource: language, ofType: "lproj")!
        bundle = Bundle(path: path)!
    }
    func changeLanguage(to language: String){
        let path = Bundle.main.path(forResource: language, ofType: "lproj")
        if let newPath = path, let newBundle = Bundle(path: newPath) {
            bundle = newBundle
        }
        let path1 = Bundle.main.localizations
        print(path1.contains(language))
        UserDefaults.standard.set([language], forKey: "AppleLanguages")
        NotificationCenter.default.post(name: .appLanguageDidChange, object: nil)
    }
    func localizedString(forKey: String) -> String{
        return bundle.localizedString(forKey: forKey, value: nil, table: nil)
    }
    
}
