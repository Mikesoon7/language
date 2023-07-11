//
//  CoreDataHelperV2.swift
//  Language
//
//  Created by Star Lord on 09/07/2023.
//

import Foundation
import CoreData
import UIKit
import Combine

protocol WordsEntityHandling{
        
}
protocol DictionariesEntityHandling{
    func createDictionary(with text: String, name: String) -> AnyPublisher<Never, Error>
    func fetchDitctionaries() -> AnyPublisher<[DictionariesEntity], Error>
    func delete(dictionary: DictionariesEntity) -> AnyPublisher<Never, Error>
}
protocol DictionariesLogsHandling{
    
}

final class CoreDataHelperV2{
    
    static let shared = CoreDataHelperV2()
    
    //MARK: - Properties
    private var numberOfDictionaries: Int64 = 0
    private var context: NSManagedObjectContext!
    
    private init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.context = appDelegate.persistentContainer.viewContext
        
        do {
            self.numberOfDictionaries = try fetchNumberOfDictionaries()
            
        } catch {
            print("Failed to initialize: \(error)")
        }
    }
    
    //Error cases
    enum CoreDataError: Error {
        case fetchFailed
        case saveFailed
        case dictionaryCreationFailed
        case logCreationFailed
        case dictionaryNotFound
    }
    
    //MARK: - Method helpers
    //Get actual number of dictionaries.
    private func fetchNumberOfDictionaries() throws -> Int64 {
        let request = NSFetchRequest<DictionariesEntity>(entityName: "DictionariesEntity")
        let dictionaries = try context.fetch(request)
        return Int64(dictionaries.count)
    }
    // Create dicitoanry entity
    private func createNewDictionary(language: String) -> DictionariesEntity? {
        let newDictionary = DictionariesEntity(context: context)
        newDictionary.language = language
        return newDictionary
    }
    // Save context shortcut
    private func saveContext() throws {
        do {
            try context.save()
            print("Debug: Context saved.")
        } catch {
            throw CoreDataError.saveFailed
        }
    }
}

//extension CoreDataHelperV2: DictionariesEntityHandling{
//    func createDictionary(with text: String, name: String) -> AnyPublisher<Never, Error> {
//    }
//    
//    func fetchDitctionaries() -> AnyPublisher<[DictionariesEntity], Error> {
//        
//    }
//    
//    func delete(dictionary: DictionariesEntity) -> AnyPublisher<Never, Error> {
//        
//    }
//    
//    
//}
