//
//  ViewModel.swift
//  Language
//
//  Created by Star Lord on 20/03/2023.
//

import Foundation
import UIKit

class ViewModel {
    
    init(){}
    
    private var cachedImage : UIImage?
    private var isDownloading = false
    private var callBack: ((UIImage?) -> Void)?
    
    func getAnImage(completion: ((UIImage?) -> Void)?){
        if let image = cachedImage{
            completion?(image)
            return
        }
        
        guard !isDownloading else {
            self.callBack = completion
            return
        }
        
        isDownloading = true
        
        guard let url = URL(string: "https://source.unsplash.com/random") else {
            print("Error")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self?.cachedImage = image
                self?.callBack?(image)
                self?.callBack = nil
                completion?(image)
            }
        }
        task.resume()
    }

    
    
}
