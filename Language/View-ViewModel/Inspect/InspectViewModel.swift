//
//  InspectViewModel.swift
//  Learny
//
//  Created by Star Lord on 15/11/2025.
//
//TODO: Polished

import Foundation
import Combine
import UIKit

class InspectViewModel {
    enum Output{
        case shouldPresentData(ParsedDictionary)
        case shouldPresentError(Error)
        case shouldUpdateLabels
        case shouldUpdateFont
    }

    //MARK: - Properties
    private let model: DictionaryFullAccess
    private let dictionary: DictionariesEntity
    private let settingsmodel: UserSettingsStorageProtocol
    

    private var dictionaryName: String = .init()
    private var words: [WordsEntity] = []
    private var oldTextByLines : [String] = []
        
    @Published var data: ParsedDictionary?
    var output = PassthroughSubject<Output, Never>()
    private var cancellables = Set<AnyCancellable>()
    

    //MARK: Inhereted and initialization
    init(dataModel: DictionaryFullAccess, settingsModel: UserSettingsStorageProtocol, dictionary: DictionariesEntity){
        self.model = dataModel
        self.settingsmodel = settingsModel
        self.dictionary = dictionary
        setUpObservers()
        
        do {
            words = try model.fetchWords(for: dictionary)
            let parsedDictionary = parseArrayToText(with: words, name: dictionary.language)
            self.data = parsedDictionary
            
        } catch {
            words = []
            output.send(.shouldPresentError(error))
        }
    }
    deinit { NotificationCenter.default.removeObserver(self) }

    
    func setUpObservers(){
        NotificationCenter.default.addObserver(
            self, selector: #selector(separatorDidChange(sender: )), name: .appSeparatorDidChange, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(languageDidChange(sender: )), name: .appLanguageDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fontDidChange(sedner: )), name: .appFontDidChange, object: nil)
    }
    
    ///Converting passed Words objects  into string.
    private func parseArrayToText(with words: [WordsEntity], name: String) -> ParsedDictionary{
        let result = NSMutableAttributedString(string: "", )
        var logicLines: [String] = []
        
        for pair in words {

            // MARK: image-only card
            if pair.word.isEmpty && pair.meaning.isEmpty,
               let data = pair.image,
               let details = try? JSONDecoder().decode(ImageDetailsCheck.self, from: data),
               let image = details.originalImage,
               let resized = image.resize(to: CGSize(width: 25, height: 25))
            {
                let attachment = NSTextAttachment()
                attachment.image = resized
                attachment.bounds = CGRect(x: 0, y: -3, width: 25, height: 25)
                
                result.append(NSAttributedString(attachment: attachment))
                result.append(NSAttributedString(string: "\n\n"))
                
                logicLines.append("system.image".localized)
                continue
            }
            
            // MARK: fallback: text entry
            let line = "\(pair.word) \(settingsmodel.appSeparators.value) \(pair.meaning)"
            logicLines.append(line)
            result.append(NSAttributedString(string: line + "\n\n"))
        }
        
        self.oldTextByLines = logicLines
        return ParsedDictionary(name: name, text: result)

    }
    
    
    
    //MARK: Data Model
    func configureTextPlaceholder() -> String{
        return "viewPlaceholderWord".localized + " \(settingsmodel.appSeparators.value) " + "viewPlaceholderMeaning".localized
    }
    func textSeparator() -> String{
        settingsmodel.appSeparators.value
    }

    
    //MARK: Actions
    @objc private func languageDidChange(sender: Notification){
        output.send(.shouldUpdateLabels)
    }
    @objc private func separatorDidChange(sender: Notification){
        let parsedDictionary = parseArrayToText(with: words, name: dictionary.language)
        output.send(.shouldPresentData(parsedDictionary))
    }
    @objc private func fontDidChange(sedner: Notification){
        output.send(.shouldUpdateFont)
    }
}

//MARK: - EditView initial data.
struct ParsedDictionary{
    let name: String
    let text: NSMutableAttributedString
    
    init(name: String, text: NSMutableAttributedString){
        self.name = name
        self.text = text
    }
}



