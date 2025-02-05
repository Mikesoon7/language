//
//  CustomTableView.swift
//  Learny
//
//  Created by Star Lord on 04/12/2024.
//

import UIKit

class CustomTableView: UITableView { }

extension CustomTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            UIView.animate(withDuration: 0.1, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
    }
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            UIView.animate(withDuration: 0.1, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            })
        }
    }
}
