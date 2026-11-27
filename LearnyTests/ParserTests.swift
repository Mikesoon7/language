//
//  ParserTests.swift
//  LearnyTests
//
//  Created by Star Lord on 23/11/2026.
//

import Foundation
import Testing

@testable import Learny

struct ParserTests {
    // TODO: build `manager` from your mocks, see below
    lazy var settingsModel = {
        var setting = UserSettings()
        setting.appExceptions.availableExceptionsBySections.append(AppExceptions.Selection(content: ["."], isSelected: true))
        return setting
    }()
    
    lazy var dataModel = CoreDataHelper(settingsModel: settingsModel)
    
    lazy var manager = DataUpdateManager(dataModel: dataModel, settings: settingsModel)

    @Test mutating func skipsJunkLineAndKeepsTheRest() {
        let result = manager.splitTheText(text: "cat - кот\n...\n-\ndog - собака", trimExceptions: true)
        #expect(result.map(\.word) == ["Cat", "Dog"])      // fails today: only ["Cat"]
    }

    @Test mutating func skipsBlankLineInTheMiddle() {
        let result = manager.splitTheText(text: "cat - кот\n\r\ndog - собака", trimExceptions: false)
        #expect(result.count == 2)                          // fails today: 1
    }

    @Test mutating func emptySeparatorsDoNotCrash() {
        let result = manager.splitSingleExpressionData(data: " - ")
        #expect(result.word.isEmpty)                        // guards the fix from earlier
    }

    @Test(arguments: ["cat - кот", "cat – кот", "cat : кот"])
    mutating func splitsWordFromDefinition(line: String) {
        
        let result = manager.splitTheText(text: line, trimExceptions: false)
        #expect(result.first?.definition == "кот")
    }
}
