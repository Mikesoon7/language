//
//  SearchViewModel.swift
//  Language
//
//  Created by Star Lord on 25/07/2023.
//
//  REFACTORING STATE: CHECKED

import Combine
import UIKit

class SearchViewModel {
    //For passing from VM to View and back.
    enum Input{
        case viewWillAppear
        case reciveText(String)
    }
    
    struct Dictionaries {
        var words: [WordsEntity]
        var dictionary: DictionariesEntity
    }
    
    
    enum Output{
        case shouldUpdateResults
        case shouldReloadView
        case shouldUpdateLabels
        case shouldReplaceSearchBarOnTop(Bool)
        case shouldUpdateFonts
        case shouldReloadCell(IndexPath)
        case error(Error)
    }
    
    
    private var model: DictionaryFullAccess
    private var settingModel: UserSettingsStorageProtocol
    
    private lazy var updateManager: DataUpdateManager = DataUpdateManager(dataModel: model)

    private var cancellable = Set<AnyCancellable>()
    
    private var allDictionaries: [Dictionaries] = []
    private var filteredDictionaries: [Dictionaries] = []
    private var allWords: [WordsEntity] = []
    private var filteredWords: [WordsEntity] = []
     
    var output: PassthroughSubject<Output, Never> = .init()
    
    private var searchPromt = ""
    
    init(model: DictionaryFullAccess, settingModel: UserSettingsStorageProtocol){
        self.model = model
        self.settingModel = settingModel
        
        model.dictionaryDidChange
            .sink { changeType in
                self.fetchWords()
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
        var allDictionariesAfterUpdate: [Dictionaries] = []
        do {
            try dictionaries.forEach { dictionary in
                let words = try model.fetchWords(for: dictionary)
                allDictionariesAfterUpdate.append(Dictionaries(words: words, dictionary: dictionary))
            }
            allDictionaries = allDictionariesAfterUpdate
            filteredDictionaries = allDictionaries
            filter(for: searchPromt)
        } catch {
            output.send(.error(error))
        }
    }
    //Filtering array of existing pairs to match promt.
    //If user types text, we filtering results from previous result. If text is smaller than previous filter promt, filter ftom all data.
    private func filter(for text: String){
        if text.isEmpty {
            filteredDictionaries = allDictionaries
        } else {
            if text.count > searchPromt.count {
                var filteredArray: [Dictionaries] = []
                
                filteredDictionaries.forEach { dictionary in
                     let filteredWords = dictionary.words.filter { word in
                        word.word.lowercased().contains(text.lowercased()) ||
                        word.meaning.lowercased().contains(text.lowercased())
                    }
                    if filteredWords.count != 0 {
                        filteredArray.append(.init(words: filteredWords, dictionary: dictionary.dictionary))
                    }
                }
                filteredDictionaries = filteredArray

            } else if text.count <= searchPromt.count {
                var filteredArray: [Dictionaries] = []
                
                allDictionaries.forEach { dictionary in
                     let filteredWords = dictionary.words.filter { word in
                        word.word.lowercased().contains(text.lowercased()) ||
                        word.meaning.lowercased().contains(text.lowercased())
                    }
                    if filteredWords.count != 0 {
                        filteredArray.append(.init(words: filteredWords, dictionary: dictionary.dictionary))
                    }
                }
                filteredDictionaries = filteredArray
            }
        }
        searchPromt = text
        output.send(.shouldUpdateResults)
    }
    
    //MARK: Detailed CellView related.
    func currentPlaceholder() -> String {
        return "viewPlaceholderWord".localized + " \(settingModel.appSeparators.value) " + "viewPlaceholderMeaning".localized
    }
    
    func textSeparator() -> String{
        settingModel.appSeparators.value
    }

    func deleteWordAt(indexPath: IndexPath){
        let dictionary = filteredDictionaries[indexPath.section]
        let pair = dictionary.words[indexPath.item]

        do {
            try updateManager.wordDidDeleteFor(dictionary.dictionary, word: pair)
        } catch {
            output.send(.error(error))
        }
    }
    ///Validate text and saving it dataModel.
    func editWord(with text: String, index: IndexPath){
        let dictionary = filteredDictionaries[index.section]
        let pair = dictionary.words[index.item]

        do {
            try model.reassignWordsProperties(for: pair, from: text)
            self.output.send(.shouldReloadCell(index))
        } catch {
            output.send(.error(error))
        }
    }

    //MARK: - Methods for tableView
    func dataForCellFor(indexPath: IndexPath) -> DataForSearchCell{
        guard indexPath.section < filteredDictionaries.count else {
            output.send(.shouldUpdateResults)
            return DataForSearchCell()
        }
        let dictionary = filteredDictionaries[indexPath.section]
        
        let pair = dictionary.words[indexPath.item]
        let viewModel = DataForSearchCell(word: pair.word, description: pair.meaning)
        return viewModel
    }

    func titleForHeaderView(at section: Int) -> String {
        return filteredDictionaries[section].dictionary.language
    }
    func numberOfCellsIn(section: Int) -> Int{
        return filteredDictionaries[section].words.count
    }
    func numberOfSections() -> Int{
        return filteredDictionaries.count
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

