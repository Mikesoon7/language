//
//  DetailsViewModel.swift
//  Language
//
//  Created by Star Lord on 19/07/2023.
//

import Foundation
import Combine


class DetailsViewModel{
    
    enum Output {
        case error(Error)
        case shouldUpdateText
    }
    
    private var model: Dictionary_Words_LogsManager
    private var dictionary: DictionariesEntity
    private var cancellable = Set<AnyCancellable>()
    
    @Published var dataForView: DataForDetails!
    var output = PassthroughSubject<Output, Never>()
    
    init(model: Dictionary_Words_LogsManager = CoreDataHelper.shared, dictionary: DictionariesEntity){
        self.model = model
        self.dictionary = dictionary
        model.dictionaryDidChange
            .sink { type in
                switch type {
                case .wasUpdated(_):
                    self.dataForView = DataForDetails(pickerNumber: Int(dictionary.numberOfCards))
                default:
                    break
                }
            }
            .store(in: &cancellable)
        dataForView = DataForDetails(pickerNumber: dictionary.words?.count ?? 0)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(languageDidChange(sender: )), name: .appLanguageDidChange, object: nil)
    }
    func provideAddWordsView() -> AddWordsView{
        let view = AddWordsView(dictionary: dictionary)
        return view
    }
    func provideGameView(with random: Bool, numberOfCards: Int) -> MainGameVC{
        let vc = MainGameVC()
        vc.initialNumber = Int(dictionary.numberOfCards)
        vc.passedNumber = numberOfCards
        vc.dictionary = dictionary
        vc.words = prepareWords(randomise: random, restrictBy: numberOfCards)
        self.incrementLogsCount(for: dictionary)
        model.testFetchAllLogsForEveryDictioanry()
        return vc
    }
    
    func incrementLogsCount(for dict: DictionariesEntity) {
        do {
            try model.accessLog(for: dict)
        } catch {
            output.send(.error(error))
        }
    }
    
    func prepareWords(randomise: Bool, restrictBy: Int) -> [WordsEntity]{
        do {
            var words = try model.fetchWords(for: dictionary)
            if randomise {
               words.shuffle()
            }
            return Array(words.prefix(upTo: restrictBy))
            
        } catch {
            output.send(.error(error))
        }
        return []
    }
    @objc func languageDidChange(sender: Any){
        output.send(.shouldUpdateText)
    }
}
struct DataForDetails{
    let pickerNumber: Int
}
