//
//  SearchViewModel.swift
//  Language
//
//  Created by Star Lord on 25/07/2023.
//

import Combine
import UIKit

class SearchViewModel {
    //For passing from VM to View and back.
    enum Input{
        case viewWillAppear
        case reciveText(String)
    }
    
    enum Output{
        case shouldUpdateResults
        case shouldReloadView
        case shouldUpdateLabels
        case shouldReplaceSearchBarOnTop(Bool)
        case shouldUpdateFonts
        case error(Error)
    }
    
    private var model: Dictionary_WordsManager
    private var settingModel: UserSettingsStorageProtocol
    private var cancellable = Set<AnyCancellable>()
    
    private var allWords: [WordsEntity] = []
    private var filteredWords: [WordsEntity] = []
    
    var output: PassthroughSubject<Output, Never> = .init()
    
    private var searchPromt = ""
    
    init(model: Dictionary_WordsManager, settingModel: UserSettingsStorageProtocol){
        self.model = model
        self.settingModel = settingModel
        model.dictionaryDidChange
            .sink { changeType in
                self.fetchWords()
                
                self.output.send(.shouldReloadView)
            }
            .store(in: &cancellable)
        fetchWords()
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(appLanguageDidChange(sender: )),
            name: .appLanguageDidChange, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(searchBarPositionDidChange(sender: )),
            name: .appSearchBarPositionDidChange, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(appFontDidChange(sender: )),
            name: .appFontDidChange, object: nil)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: .appLanguageDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .appSearchBarPositionDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .appFontDidChange, object: nil)
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input
            .receive(on: DispatchQueue.main)
            .sink { inputType in
                switch inputType{
                case .viewWillAppear:
                    self.output.send(.shouldUpdateResults)
                case .reciveText(let text):
                    self.filter(for: text)
                }
            }
            .store(in: &cancellable)
        return output.eraseToAnyPublisher()
    }
    //MARK: Context
    func searchBarPositionIsOnTop() -> Bool {
        settingModel.appSearchBarPosition == .onTop ? true : false
    }

    //MARK: Results array related.
    //Returning array of existing dictionaries.
    private func fetchDictionaries() -> [DictionariesEntity]{
        var dictionaries = [DictionariesEntity]()
        do {
            dictionaries = try model.fetchDictionaries()
        } catch {
            output.send(.error(error))
        }
        return dictionaries
    }

    private func fetchWords(){
        let dictionaries = fetchDictionaries()
        var data = [WordsEntity]()
        do {
            try dictionaries.forEach({ dictionary in
                let words = try model.fetchWords(for: dictionary)
                data.append(contentsOf: words)
                self.filteredWords = data
                self.allWords = data
            })
        } catch {
            output.send(.error(error))
        }
    }

    //Filtering array of existing pairs to match promt.
    //If user types text, we filtering results from previous result. If text is smaller than previous filter promt, filter ftom all data.
    private func filter(for text: String){
        if text.isEmpty {
            filteredWords = allWords
        } else {
            if text.count >= searchPromt.count {
                filteredWords = filteredWords.filter { words in
                    words.word.lowercased().contains(text.lowercased()) ||
                    words.meaning.lowercased().contains(text.lowercased())
                }
                searchPromt = text
            } else {
                filteredWords = allWords.filter { words in
                    words.word.lowercased().contains(text.lowercased()) ||
                    words.meaning.lowercased().contains(text.lowercased())
                }
                searchPromt = text
            }
        }
        output.send(.shouldUpdateResults)
    }
    
    //MARK: - Methods for tableView
    func dataForCell(at index: IndexPath) -> DataForSearchCell{
        guard index.section < filteredWords.endIndex else {
            output.send(.shouldUpdateResults)
            return DataForSearchCell()
        }
        let pair = filteredWords[index.section]
        let viewModel = DataForSearchCell(word: pair.word, description: pair.meaning)
        return viewModel
    }

    func numberOfCells() -> Int{
        return filteredWords.count
    }
    
    @objc func appLanguageDidChange(sender: Any){
        output.send(.shouldUpdateLabels)
    }
    @objc func searchBarPositionDidChange(sender: Notification){
        let onTop = (settingModel.appSearchBarPosition == .onTop) ? true : false
        output.send(.shouldReplaceSearchBarOnTop(onTop))
    }
    @objc func appFontDidChange(sender: Any) {
        output.send(.shouldUpdateFonts)
    }
}

