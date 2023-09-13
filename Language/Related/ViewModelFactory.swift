//
//  ViewModelFactory.swift
//  Language
//
//  Created by Star Lord on 23/08/2023.
//

import Foundation
import UIKit

final class ViewModelFactory{
    private var dataModel: Dictionary_Words_LogsManager
    private var settingsModel: UserSettingsStorageProtocol
    
    init(dataModel: Dictionary_Words_LogsManager, settingsModel: UserSettingsStorageProtocol){
        self.dataModel = dataModel
        self.settingsModel = settingsModel
    }
    
    func configureMenuViewModel() -> MenuViewModel{
        return MenuViewModel(model: dataModel)
    }
    func configureAddDictionaryModel() -> AddDictionaryViewModel{
        AddDictionaryViewModel(model: dataModel, settingsModel: settingsModel)
    }
    func configureEditViewModel(dictionary: DictionariesEntity) -> EditViewModel{
        EditViewModel(dictionary: dictionary, model: dataModel)
    }
    func configureAddWordsViewModel(dictionary: DictionariesEntity) -> AddWordsViewModel{
        AddWordsViewModel(dataModel: dataModel, settingsModel: settingsModel, dictionary: dictionary)
    }
    func configureDetailsViewModel(dictionary: DictionariesEntity) -> DetailsViewModel{
        DetailsViewModel(model: dataModel, dictionary: dictionary)
    }
    func configureSearchViewModel() -> SearchViewModel{
        SearchViewModel(model: dataModel)
    }
    func configureSettingsViewModel() -> SettingsViewModel{
        SettingsViewModel(settingsModel: settingsModel)
    }
    func configureSeparatorsModel() -> SeparatorsViewModel{
        SeparatorsViewModel(settings: settingsModel)
    }
    func configureNotificationsModel() -> NotificationViewModel{
        NotificationViewModel(settingsModel: settingsModel)
    }
    func configureStatisticModel(dictionary: DictionariesEntity) -> StatisticCellViewModel{
        StatisticCellViewModel(model: dataModel, dictionary: dictionary)
    }
    func configureStatisticViewModel() -> StatisticViewModel{
        StatisticViewModel(dataModel: dataModel)
    }
    func configureGameViewmModel(dictionary: DictionariesEntity, isRandom: Bool, selectedNumber: Int) -> GameViewModel{
        GameViewModel(dataModel: dataModel,
                      settingsModel: settingsModel,
                      dictionary: dictionary,
                      isRandom: isRandom,
                      selectedNumber: selectedNumber
        )
    }
    func configureGameDetailsViewModel(dictionary: DictionariesEntity, word: WordsEntity, delegate: MainGameVCDelegate) -> GameDetailsViewModel{
        GameDetailsViewModel(
            dataModel: dataModel,
            settingsModel: settingsModel,
            dictionary: dictionary,
            word: word,
            delegate: delegate
        )
    }
}
