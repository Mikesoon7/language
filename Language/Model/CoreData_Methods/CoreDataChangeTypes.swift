//
//  CoreDataChangeTypes.swift
//  Language
//
//  Created by Star Lord on 19/07/2023.
//

import Foundation

//For changes related to dictioanries.
public enum DictionaryChangeType{
    case wasAdded
    case wasDeleted(Int)
    case wasUpdated(Int)
}
