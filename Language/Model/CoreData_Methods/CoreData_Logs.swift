//
//  CoreData_Logs.swift
//  Language
//
//  Created by Star Lord on 23/07/2023.
//

import Foundation
import CoreData

protocol LogsManaging{
    func createNewLog(for dictionary: DictionariesEntity, at date: Date, shouldSave: Bool) throws -> DictionariesAccessLog
    func accessLog(for dictionary: DictionariesEntity) throws
    func fetchAllLogs(for dictionary: DictionariesEntity) throws -> [DictionariesAccessLog]
    func testFetchAllLogsForEveryDictioanry()
    
}

extension CoreDataHelper: LogsManaging{
    //MARK: - Working with logs
//    private func fetchLog(for dictionary: DictionariesEntity, at date: Date) -> DictionariesAccessLog? {
//        let calendar = Calendar.current
//        let startDate = calendar.startOfDay(for: date)
//        guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else { return nil }
//
//        let fetchRequest: NSFetchRequest<DictionariesAccessLog> = DictionariesAccessLog.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "dictionary == %@ AND (accessDate >= %@) AND (accessDate < %@)", argumentArray: [dictionary, startDate as NSDate, endDate as NSDate])
//
//        do {
//            let logs = try context.fetch(fetchRequest)
//            return logs.first
//        } catch {
//            print("Failed to fetch log: \(error)")
//            return nil
//        }
//    }
    private func fetchLog(for dictionary: DictionariesEntity, at date: Date) -> DictionariesAccessLog? {
        let dateWithoutTime = date.timeStripped
        let fetchRequest: NSFetchRequest<DictionariesAccessLog> = DictionariesAccessLog.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "dictionary == %@ AND accessDate == %@", dictionary, dateWithoutTime as NSDate)

        do {
            let logs = try context.fetch(fetchRequest)
            return logs.first
        } catch {
            print("Failed to fetch log: \(error)")
            return nil
        }
    }

    func createNewLog(for dictionary: DictionariesEntity, at date: Date, shouldSave: Bool) throws -> DictionariesAccessLog {
        let log = DictionariesAccessLog(context: context)
        log.accessDate = date.timeStripped
        log.accessCount = 0
        log.dictionary = dictionary
        do {
            try context.save()
        } catch {
            throw LogsErrorType.creationFailed
        }
        return log
    }
    
    func testFetchAllLogsForEveryDictioanry() {
        let fetchRequest: NSFetchRequest<DictionariesAccessLog> = DictionariesAccessLog.fetchRequest()
        do {
            let logs = try context.fetch(fetchRequest)
            logs.forEach { log in
                print("\(log.dictionary?.language) have \(log.accessCount) on \(log.accessDate)")
            }
        } catch {
            print("Error")
        }
    }
    func accessLog(for dictionary: DictionariesEntity) throws {
        guard let log =  fetchLog(for: dictionary, at: Date()) else {
            do {
                let log = try createNewLog(for: dictionary, at: Date(), shouldSave: true)
                log.accessCount += 1
            } catch {
                throw error
            }
            return
        }
        
        log.accessCount += 1
        
        do {
            try saveContext()
        } catch {
            throw LogsErrorType.accessFailed
        }
    }
    
    func fetchAllLogs(for dictionary: DictionariesEntity) throws -> [DictionariesAccessLog] {
        let fetchRequest = NSFetchRequest<DictionariesAccessLog>(entityName: "DictionariesAccessLog")
        let predicate = NSPredicate(format: "dictionary == %@", dictionary)
        let sortDescriptor = NSSortDescriptor(key: "accessDate", ascending: true)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do{
            let logs = try context.fetch(fetchRequest)
            return logs
        } catch {
            throw LogsErrorType.fetchFailed
        }
    }
    

}
