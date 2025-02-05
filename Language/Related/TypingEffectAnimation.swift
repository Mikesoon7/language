//
//  TypingEffectAnimation.swift
//  Learny
//
//  Created by Star Lord on 05/02/2025.
//

import Foundation
import UIKit

class TypingEffectController {
    var label: UILabel
    var typingInterval: TimeInterval = 0.05
    
    private var timer: DispatchSourceTimer?

    init(label: UILabel, interval: TimeInterval) {
        self.label = label
        self.typingInterval = interval
    }
    
    
    func simulateTypingEffectWith(passedLabel: UILabel? = nil, text: String, completion: @escaping () -> Void) {
        
        if let label = passedLabel {
            self.label = label
        }
        
        self.label.text = ""
            
        let characters = Array(text)
        var typeIndex = 0
        var charactersNumber = characters.count
                
        let queue = DispatchQueue(label: "com.timer.queue", qos: .userInitiated)
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now(), repeating: self.typingInterval)
        timer?.setEventHandler { [weak self] in
            if charactersNumber > 0 {
                DispatchQueue.main.async {
                    self?.label.text!.append(characters[typeIndex])
                    print(characters[typeIndex])
                    typeIndex += 1
                    charactersNumber -= 1
                }
            } else {
                self?.timer?.cancel()
                completion()
            }
        }
        timer?.resume()
    }
    func updateTypingEffectWith(text: String, completion: @escaping () -> Void) {
        self.cancelTypingEffect()
        self.simulateTypingEffectWith(text: text, completion: completion)
    }

    
    func cancelTypingEffect() {
        self.timer?.cancel()
    }
}

