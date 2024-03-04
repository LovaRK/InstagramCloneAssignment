//
//  UIImageViewExt.swift
//  InstagramClone
//
//  Created by Lova Krishna on 26/04/20.
//  Copyright © 2020 Lova Krishna. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    func loadImageUsingCache(withUrl urlString : String, placeholder: UIImage?) {
        let url = URL(string: urlString)
        if url == nil {return}
        self.image = nil
        // check cached image
        if let cachedImage = imageCache.object(forKey: urlString as NSString)  {
            print("Image Get from catche  ***")
            self.image = cachedImage
            return
        }
        self.image = placeholder
        // if not, download image from url
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            DispatchQueue.main.async {
                if let image = UIImage(data: data!) {
                    print("Image From Server +++++++++++++++++++++===========")
                    imageCache.setObject(image, forKey: urlString as NSString)
                    self.image = image
                }
            }
        }).resume()
    }
}


extension URLCache {
    static func configSharedCache(directory: String? = Bundle.main.bundleIdentifier, memory: Int = 0, disk: Int = 0) {
        URLCache.shared = {
            let cacheDirectory = (NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as String).appendingFormat("/\(directory ?? "cache")/" )
            return URLCache(memoryCapacity: memory, diskCapacity: disk, diskPath: cacheDirectory)
        }()
    }
}
