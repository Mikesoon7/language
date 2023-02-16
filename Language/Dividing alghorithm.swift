//
//  Dividing alghorithm.swift
//  Language
//
//  Created by Star Lord on 03/02/2023.
//

import Foundation


    func divider(text: String) -> [[String: String]]{
        var textToDivide = text
        var dictionary = [[String: String]]()
        let end = "- [ ] "
        var currentWord : String?
        var currentTranslation : String?
        
        while currentWord != nil{
            
            if text.hasPrefix(end){
                textToDivide.removeFirst(6)
                currentWord = String(text.prefix(through: text.firstIndex(where: { (s1: Character) in
                    s1 == "-"
                })!))
                currentWord.removeLast(2)
                textToDivide.removeSubrange(text.startIndex...text.firstIndex(where: { (s1: Character) in
                    s1 == "-"
                })!)
                
                currentTranslation =  String(text.prefix(through: text.firstIndex(where: { (s1: Character) in
                    s1 == "-"
                    
                })!))
                textToDivide.removeSubrange(text.startIndex...text.firstIndex(where: { (s1: Character) in
                    s1 == "-"
                })!)
                textToDivide.insert("-", at: textToDivide.startIndex)
                currentTranslation.removeLast()
                dictionary.append([currentWord: currentTranslation])
            }
        }
        return dictionary
    }
    
}

/*
 - [ ] Precedes - come before in time. The gun battle has preceded the explosions.
- [ ] Determine - вычислять, решать.
- [ ] Interaction - взаимодействие.
- [ ] Hypocrite - лицемерный, неискренний.
- [ ] Anxiety - тревожность.
- [ ] Offence -
- [ ] Imbed - insert or implant.
- [ ] Rapid - quick or fast.
- [ ] Miserable -
- [ ] Duffel bag -
- [ ] Exile - изгнание.
- [ ] Jinxed -
- [ ] Disrupts -
- [ ] Disrupters -
- [ ] Stir - волнение.
- [ ] Buttress -
- [ ] Quantum of solace -
- [ ] Mocking -
- [ ] Mutual - взаимный.
- [ ] Seductive -
- [ ] Custody -
*/
