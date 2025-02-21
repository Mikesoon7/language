//
//  CountdownBarButton.swift
//  Learny
//
//  Created by Star Lord on 14/11/2024.
//

import UIKit

class CountdownTimerLabel: UILabel {
    var delegate: CountdownTimerDelegate
    
    var initialTimerTime: Int
    var remainingTimerTime: Int
    var additionalTimerTime: Int = 0
    
    var isCountingDown: Bool
    private var timer: DispatchSourceTimer?

    required init(initialTimerTime: Int, delegate: CountdownTimerDelegate) {
        self.delegate = delegate
        self.initialTimerTime = initialTimerTime
        self.remainingTimerTime = initialTimerTime
        isCountingDown = initialTimerTime == 0 ? false : true
        super.init(frame: .zero)
        configureTimer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureTimer() {
        self.text = String.timeString(from: remainingTimerTime)
        self.font = UIFont.systemFont(ofSize: .subBodyTextSize, weight: .bold)
        self.textColor = .label
        self.textAlignment = .center
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isUserInteractionEnabled = true
        self.isEnabled = true
    }

    func startCountdown() {
        let queue = DispatchQueue(label: "com.timer.queue", qos: .userInitiated)
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now(), repeating: 1.0)
        timer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            if self.remainingTimerTime > 0 {
                self.remainingTimerTime -= 1
                DispatchQueue.main.async {
                    self.text = String.timeString(from: self.remainingTimerTime)
                }
            } else {
                self.timer?.cancel()
                DispatchQueue.main.async {
                    self.text = "Time's up!"
                    self.delegate.timerDidFire()
                    self.isCountingDown = false
                    return
                }
            }
        }
        isCountingDown = true
        timer?.resume()
    }
    
    func startCountingUp() {
        let queue = DispatchQueue(label: "com.timer.queue", qos: .userInitiated)
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now(), repeating: 1.0)
        timer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            
            additionalTimerTime += 1
            
            DispatchQueue.main.async {
                self.text = String.timeString(from: self.additionalTimerTime)
            }
        }
        isCountingDown = false
        timer?.resume()
    }
    
    func stopCountdown() {
        timer?.cancel()
    }
    
    func resumeCountdown() {
        isCountingDown ? startCountdown() : startCountingUp()
    }

//    func timeString(from seconds: Int) -> String {
//        let minutes = seconds / 60
//        let seconds = seconds % 60
//        return String(format: "%02d:%02d", minutes, seconds)
//    }
    
    func timeSpent() -> Int{
        if remainingTimerTime == 0 {
            return initialTimerTime + additionalTimerTime
        } else {
            return initialTimerTime - remainingTimerTime
        }
    }
}

protocol CountdownTimerDelegate {
    func timerDidFire()
}

