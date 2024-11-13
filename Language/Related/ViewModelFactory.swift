//
//  ViewModelFactory.swift
//  Language
//
//  Created by Star Lord on 23/08/2023.
//

import Foundation
import UIKit

final class ViewModelFactory{
    private var dataModel: DictionaryFullAccess
    private var settingsModel: UserSettingsStorageProtocol
    
    init(dataModel: DictionaryFullAccess, settingsModel: UserSettingsStorageProtocol){
        self.dataModel = dataModel
        self.settingsModel = settingsModel
    }
    
    func configureMenuViewModel() -> MenuViewModel{
        return MenuViewModel(model: dataModel, settingsModel: settingsModel)
    }
    func configureAddDictionaryModel() -> AddDictionaryViewModel{
        AddDictionaryViewModel(model: dataModel, settingsModel: settingsModel)
    }
    func configureEditViewModel(dictionary: DictionariesEntity) -> EditViewModel{
        EditViewModel(dataModel: dataModel, settingsModel: settingsModel, dictionary: dictionary)
    }
    func configureAddWordsViewModel(dictionary: DictionariesEntity) -> AddWordsViewModel{
        AddWordsViewModel(dataModel: dataModel, settingsModel: settingsModel, dictionary: dictionary)
    }
    func configureDetailsViewModel(dictionary: DictionariesEntity) -> DetailsViewModel{
        DetailsViewModel(model: dataModel, dictionary: dictionary)
    }
    func configureSearchViewModel() -> SearchViewModel{
        SearchViewModel(model: dataModel, settingModel: settingsModel)
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
        StatisticCellViewModel(dataModel: dataModel,
                               settingModel: settingsModel,
                               dictionary: dictionary)
    }
    func configureStatisticViewModel() -> StatisticViewModel{
        StatisticViewModel(dataModel: dataModel, settingsModel: settingsModel)
    }
    func configureExceptionViewModel() -> ExceptioonsViewModel{
        ExceptioonsViewModel(settingsModel: settingsModel)
    }
    func configureGameViewmModel(dictionary: DictionariesEntity, isRandom: Bool, isTwoSidesModeOn: Bool, selectedNumber: Int) -> GameViewModel{
        GameViewModel(dataModel: dataModel,
                      settingsModel: settingsModel,
                      dictionary: dictionary,
                      isRandom: isRandom,
                      isOneSideMode: isTwoSidesModeOn,
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
