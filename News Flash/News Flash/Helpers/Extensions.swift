//
//  Extensions.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 9.01.20.
//  Copyright © 2020 Emanuil Gospodinov. All rights reserved.
//

import Foundation
import UIKit

// MARK: UIImageView load image from url
extension UIImageView {
    func load(url: URL, completion: @escaping (UIImage) -> Void) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                        completion(image)
                    }
                }
            }
        }
    }
}

// MARK: Navigation Bar
extension UINavigationController {
    // make the Nav Bars with dark status bars
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
}
