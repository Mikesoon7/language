//
//  CoreData_Logs.swift
//  Language
//
//  Created by Star Lord on 23/07/2023.
//

import Foundation
import CoreData

protocol LogsManaging{
    func accessLog(for dictionary: DictionariesEntity) throws
    func fetchAllLogs(for dictionary: DictionariesEntity?) throws -> [DictionariesAccessLog]
//    func testFetchAllLogsForEveryDictioanry()
    
}

extension CoreDataHelper: LogsManaging{
    //MARK: Fetch
    ///Return log entity, assosiated with passed dictionary at the specific date.
    private func fetchLog(for dictionary: DictionariesEntity, at date: Date = Date()) -> DictionariesAccessLog? {
        let dateWithoutTime = date.timeStripped
        print(dateWithoutTime)
        let fetchRequest: NSFetchRequest<DictionariesAccessLog> = DictionariesAccessLog.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "dictionary == %@ AND accessDate == %@", dictionary, dateWithoutTime as NSDate)

        do {
            let logs = try context.fetch(fetchRequest)
            return logs.first
        } catch {
            return nil
        }
    }
    func fetchAllLogs(for dictionary: DictionariesEntity?) throws -> [DictionariesAccessLog] {
        let fetchRequest = NSFetchRequest<DictionariesAccessLog>(entityName: "DictionariesAccessLog")
        if let dictionary = dictionary {
            let predicate = NSPredicate(format: "dictionary == %@", dictionary)
            fetchRequest.predicate = predicate
        }
        let sortDescriptor = NSSortDescriptor(key: "accessDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do{
            let logs = try context.fetch(fetchRequest)
            return logs
        } catch {
            throw LogsErrorType.fetchFailed
        }
    }
    //MARK: Creation
    ///Creating new log entity for passed dictionary.
    private func createNewLog(for dictionary: DictionariesEntity, at date: Date = Date()) throws -> DictionariesAccessLog {
        let log = DictionariesAccessLog(context: context)
        log.accessDate = date.timeStripped
        log.accessCount = 0
        log.dictionary = dictionary
        
        do {
            try saveContext()
        } catch {
            throw LogsErrorType.creationFailed(dictionary.language)
        }
        return log
    }
    
    //MARK: Update
    func accessLog(for dictionary: DictionariesEntity) throws {
        guard let log = fetchLog(for: dictionary) else {
            do {
                let log = try createNewLog(for: dictionary)
                log.accessCount += 1
                try saveContext()
            } catch {
                throw error
            }
            return
        }
        log.accessCount += 1
        
        do {
            try saveContext()
        } catch {
            throw LogsErrorType.accessFailed(dictionary.language)
        }
    }
    
    

}
