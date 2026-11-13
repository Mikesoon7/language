//
//  SearchViewModel.swift
//  Language
//
//  Created by Star Lord on 25/07/2023.
//
//TODO: Polish

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
        case shouldUpdateLabels
        case shouldUpdateFonts
        case shouldReloadCell(IndexPath)
        case shouldPresentError(Error)
        case shouldPresentAlert(SingleEntryEditAlertType)
        
        case reflectSearchPositionChange(AppSearchBarPosition)
    }
    
    
    private var model: DictionaryFullAccess
    private var settingModel: UserSettingsStorageProtocol
    private lazy var updateManager: DataUpdateManager = DataUpdateManager(dataModel: model, settings: settingModel)

    private var cancellable = Set<AnyCancellable>()
    
    private var allDictionaries: [Dictionaries] = []
    private var filteredDictionaries: [Dictionaries] = []
    private var allWords: [WordsEntity] = []
    private var filteredWords: [WordsEntity] = []
    
    var output: PassthroughSubject<Output, Never> = .init()
    
    var searchBarPosition: AppSearchBarPosition {
        settingModel.appSearchBarPosition
    }
    
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
    
    deinit { NotificationCenter.default.removeObserver(self) }

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
            output.send(.shouldPresentError(error))
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
            output.send(.shouldPresentError(error))
        }
    }
    private func filter(for text: String){
        if text.isEmpty {
            filteredDictionaries = allDictionaries
        } else {
            var filteredArray: [Dictionaries] = []
            
            allDictionaries.forEach { dictionary in
                let filteredWords = dictionary.words.filter { word in
                    word.word.lowercased().contains(text.lowercased()) ||
                    word.meaning.lowercased().contains(text.lowercased())
                }
                if filteredWords.count != 0 {
                    filteredArray.append(.init( words: filteredWords, dictionary: dictionary.dictionary))
                }
            }
            filteredDictionaries = filteredArray
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
            output.send(.shouldPresentError(error))
        }
    }
    ///Validate text and saving it dataModel.
    func editWord(with text: String, index: IndexPath){
        let verificationResult = updateManager.verifySingleEntryTextData(data: text)

        let dictionary = filteredDictionaries[index.section]
        let entry = dictionary.words[index.item]

        switch verificationResult {
        case .success(let data, _):
            let singleData = data[0]
            do {
                try updateManager.updateSingleEntry(entry: entry, data: singleData)
                output.send(.shouldReloadCell(index))
            } catch {
                output.send(.shouldPresentError(error))
            }
        case .emptyText:
            output.send(.shouldPresentAlert(.emptyText))
        case .croppedText:
            output.send(.shouldPresentAlert(.invalidContent))
        default:
            break
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
    
    //MARK: Actions
    @objc func appLanguageDidChange(sender: Any){
        output.send(.shouldUpdateLabels)
    }
    @objc func searchBarPositionDidChange(sender: Notification){
        output.send(.reflectSearchPositionChange(self.searchBarPosition))
    }
    @objc func appFontDidChange(sender: Any) {
        output.send(.shouldUpdateFonts)
    }
}

