//
//  StatiscticCellView.swift
//  Language
//
//  Created by Star Lord on 12/07/2023.
//

import UIKit
import SwiftUI
import Charts

struct AccessData{
    let date: String
    let numberOfTimes: Double
}
class StatiscticCellView: UIView {
    
    var data: [AccessData]!
    
    
    init(data: [Date: Double]){
        super.init(frame: .zero)
        self.data = configure(data: data)
    }
    required init?(coder: NSCoder) {
        fatalError("Coder wasn't imported")
    }
    
    func configure(data: [Date: Double]) -> [AccessData]{
        var output = [AccessData]()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        data.forEach { (key: Date, value: Double) in
            output.append(AccessData(date: formatter.string(from: key), numberOfTimes: value))
        }
        return output
    }
    
    var body: some View{
        Charts(data) {
            
        }
    }
}
