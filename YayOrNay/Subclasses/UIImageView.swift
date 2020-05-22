//
//  UIImageView.swift
//  YayOrNay
//
//  Created by Ilay on 17/09/2019.
//  Copyright © 2019 kStudio. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, AnyObject>()

class CustomUIImageView: UIImageView {
    
    var imageUrlString: String?
    
    func loadImageUsingCacheWithUrlString(urlString: String) {
        
        imageUrlString = urlString
        
        //Since the OS is recycling the cells, we set the image to nil so we don't see old image before setting the new one.
        self.image = nil
        
        //Check if we got the image cached. if so, use it.
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage{
            self.image = cachedImage
            return
        }
        
        //If we don't have the image cached, download it.
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            //Error - should get out and not continue.
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            DispatchQueue.main.async {
                
                let downloadedImage = UIImage(data: data!)
                if self.imageUrlString == urlString {
                    self.image = downloadedImage
                }
                
                imageCache.setObject(downloadedImage!, forKey: urlString as NSString)
            }
        }.resume()
    }
}
