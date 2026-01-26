//
//  KeyboardCoordinator.swift
//  Learny
//
//  Created by Star Lord on 09/01/2026.
//

import Foundation
import UIKit
import Combine

final class KeyboardListener {

    enum KeyboardVisibility {
        case visible
        case hidden
    }
    
    enum Presence {
        case hidden
        case accessoryOnly
        case full(height: CGFloat)
    }

    struct Event {
        let presence: Presence
        let duration: TimeInterval
        let intersection: CGRect
        let curve: UIView.AnimationOptions
    }

    let events = PassthroughSubject<Event, Never>()

    private weak var view: UIView?
    private var observer: NSObjectProtocol?

    init(
        view: UIView,
        notificationCenter: NotificationCenter = .default
    ) {
        self.view = view
        observer = notificationCenter.addObserver(
            forName: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handle(notification)
        }
    }

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func handle(_ notification: Notification) {
        guard
            let view = view,
            let userInfo = notification.userInfo,
            let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }

        let curve = UIView.AnimationOptions(rawValue: curveRaw << 16)

        let keyboardFrame = view.convert(endFrame, from: nil)

        let intersection = view.bounds.intersection(keyboardFrame)
        let height = intersection.height

        let presence: Presence
        if height == 0 {
            presence = .hidden
        } else if height < 80 {
            presence = .accessoryOnly
        } else {
            presence = .full(height: height)
        }

        events.send(
            Event(
                presence: presence,
                duration: duration,
                intersection: intersection,
                curve: curve
            )
        )
    }
}
