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
        UserDefaults.standard.set([language], forKey: "AppleLanguages")

        if let newPath = path, let newBundle = Bundle(path: newPath) {
            bundle = newBundle
        } else {
            print("No another language")
        }
        
        NotificationCenter.default.post(name: .appLanguageDidChange, object: nil)
    }
    func localizedString(forKey: String) -> String{
        return bundle.localizedString(forKey: forKey, value: nil, table: nil)
    }
    
}
