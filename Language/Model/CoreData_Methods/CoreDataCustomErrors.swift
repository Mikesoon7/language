//
//  CustomErrors.swift
//  Language
//
//  Created by Star Lord on 19/07/2023.
//

import Foundation

//For error related to dictionaries
enum DictionaryErrorType: Error {
    case creationFailed(String)
    case fetchFailed
    case updateFailed(String)
    case additionFailed(String)
    case updateOrderFailed
    case deleteFailed(String)
}

enum WordsErrorType: Error {
    case failedToAssignEmptyString(String)
    case fetchFailed(String)
    case deleteFailed(String)
}

enum LogsErrorType: Error {
    case fetchFailed
    case accessFailed(String)
    case creationFailed(String)
}

enum CoreDataErrorType: Error {
    case saveFailed
}


