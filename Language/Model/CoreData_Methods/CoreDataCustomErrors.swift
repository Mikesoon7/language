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

enum LogsErrorType: Error {
    case fetchFailed
    case accessFailed
    case creationFailed
}


