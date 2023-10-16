//
//  SeparatorsViewModel.swift
//  Language
//
//  Created by Star Lord on 16/08/2023.
//

import UIKit
import Combine

class SeparatorsViewModel{
    //MARK: From VM to V and back.
    enum Output{
        case shouldUpdateTable
        case shouldPresentAlertController
        case shouldUpdateTablesHeight
    }
    enum Input {
        case deleteSeparator(IndexPath)
        case addSeparator(String)
    }
    
    
    private var settingsModel: UserSettingsStorageProtocol
    private var cancellable = Set<AnyCancellable>()
    
    var output = PassthroughSubject<Output, Never>()

    init(settings: UserSettingsStorageProtocol){
        self.settingsModel = settings
        
    }
    //Called by view in order to bind calls from view and viewModel.
    func transform(input: AnyPublisher<Input, Never>?) -> AnyPublisher<Output, Never> {
        input?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] type in
                switch type{
                case .addSeparator(let separator):
                    self?.addSeparator(separator: separator)
                case .deleteSeparator(let indexPath):
                    self?.deleteSeparator(indexPath: indexPath)
                }
            }
            .store(in: &cancellable)
        
        return output.eraseToAnyPublisher()
    }

    //MARK: Fucntional methods for context.
    // Return selected separator from the model. Using for passing to the example view.
    func selectedSeparator() -> String{
        settingsModel.appSeparators.value
    }
    
    // Return all separators from the model.Using for avoiding duplicates.
    func availableSeparators() -> [String]{
        settingsModel.appSeparators.availableSeparators
    }
    
    //Return maximum number of separators, saved in model.
    private func maxNumber() -> Int{
        settingsModel.appSeparators.maxCapacity
    }
    //Cheking, is passed index belongs to functional row.
    private func isAddCharacterRow(indexPath: IndexPath) -> Bool{
        if numberOfSeparators() == maxNumber() {
            return false
        } else  {
            return indexPath.row == numberOfRowsInTable() - 1
            
        }
    }
    // Return current number of separators on model.
    private func numberOfSeparators() -> Int{
        availableSeparators().count
    }

    
    
    //MARK: Update available separators.
    //Add separator to the models separatorsArray.
    private func addSeparator(separator: String){
        settingsModel.appSeparators.availableSeparators.append(separator)
        output.send(.shouldUpdateTablesHeight)
    }
    
    //Delete separator from existing separator array.
    private func deleteSeparator(indexPath: IndexPath){
        settingsModel.appSeparators.availableSeparators.remove(at: indexPath.row)
        output.send(.shouldUpdateTablesHeight)
    }
    
    //MARK: TableView Related.
    // User can add up to 5 separators, so when max number is reached, cell for adding new separator will dissapear.
    func numberOfRowsInTable() -> Int{
        let currentNumber = numberOfSeparators() + 1
        return min(currentNumber, maxNumber())
    }

        //Checks, is row editable. Return false if row dispay selected string or the row used for adding new separators.
    func canEditRowAt(indexPath: IndexPath) -> Bool{
        guard !isAddCharacterRow(indexPath: indexPath) && numberOfRowsInTable() > 2 else { return false }
        guard availableSeparators()[indexPath.row] != selectedSeparator() else { return false }
        return true
    }
    
    //Returns Data structure for initializing cell
    func dataForCellAt(indexPath: IndexPath) -> DataForSeparatorCell{
        if isAddCharacterRow(indexPath: indexPath)  {
            return DataForSeparatorCell(value: "separators.addChar".localized, isSelected: false, isFunctional: true)
        } else {
            let value =  availableSeparators()[indexPath.row]
            let selectedValue = settingsModel.appSeparators.value
            let isSelected = value == selectedValue
            return DataForSeparatorCell(
                value: value, isSelected: isSelected)
        }
    }

    func didSelectCellAt(indexPath: IndexPath){
        if availableSeparators().count == indexPath.row{
            output.send(.shouldPresentAlertController)
        } else {
            let selectedValue = availableSeparators()[indexPath.row]
            guard selectedValue != settingsModel.appSeparators.value else { return }
            settingsModel.appSeparators.value = selectedValue
            output.send(.shouldUpdateTable)
        }
    }
}

