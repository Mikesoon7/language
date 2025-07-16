//
//  SingleModeDelegate.swift
//  Learny
//
//  Created by Star Lord on 21/04/2025.
//

import Foundation
import UIKit

struct SingleModeCellData: Hashable {
    var identifier = UUID()

    var word: String
    var definition: String
    
    var imageDetails: ImageDetailsCheck?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

    static func == (lhs: SingleModeCellData, rhs: SingleModeCellData) -> Bool {
        lhs.identifier == rhs.identifier
    }

}

//struct IndividualCellData {
//    
//    var word: String
//    var definition: String
//    
//    var image: UIImage?
//    var imageDetails: ImageDetails
//}
protocol SingleModeCellActionDelegate: AnyObject {
    func panningBegan(for cell: UICollectionViewCell)

    func panningEnded(active: Bool)

    func deleteButtonDidTap(for cell: UICollectionViewCell)

}
protocol SingleModeImageDelegate: AnyObject {
    func wordDidType        (index: IndexPath, text: String)
    func definitionDidTye   (index: IndexPath, text: String)
    func didTapAddImage     (cell: SingleModeImageCell, index: IndexPath) 
}

protocol SingleModeNameDelegate: AnyObject {
    func didTypeName(text: String)
    func name() -> String
}

protocol SingleModeAddDelegate: AnyObject {
    func didAddCell()
    func didSave()
}
