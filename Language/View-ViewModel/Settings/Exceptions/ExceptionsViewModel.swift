//
//  ExceptionsViewModel.swift
//  Language
//
//  Created by Star Lord on 10/10/2023.
//

import Foundation
import Combine

class ExceptioonsViewModel{
    
    enum Output{
        case shouldUpdateTable
        case shouldPresentAlertController
        case shouldPresentTextField
        case shouldUpdateTablesHeight
    }
    
    enum Input {
        case deleteException(IndexPath)
        case addException(String)
    }

    //MARK: Properties
    private var settingsModel: UserSettingsStorageProtocol
    private var cancellable = Set<AnyCancellable>()
    
    var output = PassthroughSubject<Output, Never>()
    
    //MARK: Inherited & Initializers
    init(settingsModel: UserSettingsStorageProtocol){
        self.settingsModel = settingsModel
    }
    
    //MARK: VC related.
    func transform(input: AnyPublisher<Input, Never>?) -> AnyPublisher<Output, Never> {
        input?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] type in
                switch type{
                case .addException(let separator):
                    self?.addException(exception: separator)
                case .deleteException(let indexPath):
                    self?.deleteException(indexPath: indexPath)
                }
            }
            .store(in: &cancellable)
        
        return output.eraseToAnyPublisher()
    }
    
    ///Returns stored in memory exception symbols, joined by separator
    func selectedExceptions() -> String {
        var selectedSymbols =  settingsModel.appExceptions.selectedExceptions.map { $0.content }
        return selectedSymbols.joined().joined(separator: " ")
    }

    ///Returns current separator. Uses in example view
    func selectedSeparator() -> String {
        settingsModel.appSeparators.value
    }


    //MARK: System
    ///Creating array of characters with string type
    private func splitSymbols(from text: String) -> [String]{
        text.map({String($0)})
    }
    
    private func isAddCharacterRow(indexPath: IndexPath) -> Bool{
        if indexPath.section == 0, numberOfSections() == 2 {
            return false
        } else {
            return true
        }
    }

    private func availableExceptionSymbols() -> [AppExceptions.Selection]{
        return settingsModel.appExceptions.availableExceptionsBySections
    }
    
    private func validateException(text: String) -> Bool{
        if !text.trimmingCharacters(in: CharacterSet(charactersIn: " ")).isEmpty {
            return true
        } else {
            return false
        }
    }
    
    
    //MARK: Update available exceptions.
    ///Adding new array of exceptions into data memory.
    private func addException(exception: String){
        if validateException(text: exception) {
            let symbolsArray = splitSymbols(from: exception)
            settingsModel.appExceptions.availableExceptionsBySections.append(AppExceptions.Selection(content: symbolsArray, isSelected: true))
            output.send(.shouldUpdateTablesHeight)
        } else {
            output.send(.shouldPresentAlertController)
        }
    }
    
    ///Delete exceptions array for passed index
    private func deleteException(indexPath: IndexPath){
        settingsModel.appExceptions.availableExceptionsBySections.remove(at: indexPath.row)
        output.send(.shouldUpdateTablesHeight)
    }
    
    //MARK: TableView Related.
    func numberOfSections() -> Int{
        return settingsModel.appExceptions.availableExceptionsBySections.isEmpty ? 1 : 2
    }
    
    func numberOfRowsInSection(section: Int) -> Int{
        if section == 0, numberOfSections() == 2 {
            return settingsModel.appExceptions.availableExceptionsBySections.count
        } else {
            return 1
        }
    }

    //Returns Data structure for initializing cell
    func dataForCellAt(indexPath: IndexPath) -> DataForSeparatorCell{
        if isAddCharacterRow(indexPath: indexPath)  {
            return DataForSeparatorCell(value: "separators.addChar".localized, isSelected: false, isFunctional: true)
        } else {
            let value = availableExceptionSymbols()[indexPath.row]
            return DataForSeparatorCell(
                value: value.content.joined(separator: " "), isSelected: value.isSelected)
        }
    }
    
    func didSelectCellAt(indexPath: IndexPath){
        if isAddCharacterRow(indexPath: indexPath){
            output.send(.shouldPresentTextField)
        } else {
            settingsModel.appExceptions.availableExceptionsBySections[indexPath.row].isSelected.toggle()
            output.send(.shouldUpdateTable)
        }
    }
    
    func canEditRowAt(indexPath: IndexPath) -> Bool{
        return !isAddCharacterRow(indexPath: indexPath)
    }
}
