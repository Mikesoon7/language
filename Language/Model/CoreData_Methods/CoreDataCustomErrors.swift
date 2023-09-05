//
//  CustomErrors.swift
//  Language
//
//  Created by Star Lord on 19/07/2023.
//

import Foundation

//For error related to dictionaries
enum DictionaryErrorType: Error {
    case creationFailed
    case fetchFailed
    case updateFailed
    case additionFailed
    case updateOrderFailed
    case deleteFailed
}

enum WordsErrorType: Error {
    case creationFailed
    case fetchFailed
    case updateFailed
    case updateOrderFailed
    case deleteFailed
    case failedToDefineDictionary
}

enum LogsErrorType: Error {
    case fetchFailed
    case accessFailed
    case creationFailed
}


