//
//  ImagesCellClassCollectionViewCell.swift
//  test
//
//  Created by MacbookAir_32 on 18/04/24.
//

import UIKit

class ImagesCellClass: UICollectionViewCell {
    
    //MARK: - Outlates

    @IBOutlet weak var imgAll  : UIImageView!
    
    //-----------------------------------------
    //MARK: - Custom Variables
    
    var imageCache = NSCache<NSString, UIImage>()
    
    //-----------------------------------------
    
    //MARK: - Custom Methods
    
    func setupView() {
        self.applyTheme()
        
    }
    
    func applyTheme() {
        
    }

    //confing Function

//    func confing(imagesUrl: String) {
//        
//        if let imageUrl = URL(string: imagesUrl) {
//            
//            URLSession.shared.dataTask(with: imageUrl) { [weak self] (data, response, error) in
//                guard let self = self else { return }
//
//                if let error = error {
//                    print("Error loading image: \(error)")
//                    return
//                }
//
//                if let imageData = data {
//                    DispatchQueue.main.async {
//                        self.imgAll.image = UIImage(data: imageData)
//                    }
//                }   
//            }.resume()
//        }
//    }
    
    // confing function to load images asynchronously
    func confing(imagesUrl: String) {
        if let cachedImage = imageCache.object(forKey: imagesUrl as NSString) {
            // Use cached image if available
            self.imgAll.image = cachedImage
        } else {
            if let imageUrl = URL(string: imagesUrl) {
                let sessionConfig = URLSessionConfiguration.default
                sessionConfig.timeoutIntervalForRequest = 10 // Adjust timeout interval as needed

                let session = URLSession(configuration: sessionConfig)
                let task = session.dataTask(with: imageUrl) { [weak self] (data, response, error) in
                    guard let self = self else { return }

                    if let error = error {
                        if let nsError = error as NSError?, nsError.code == NSURLErrorTimedOut {
                            print("Request timed out for URL: \(imagesUrl)")
                            // Handle timeout error (e.g., display a placeholder image)
                             self.imgAll.image = UIImage(named: "placeholderImage")
                            return
                        }
                        print("Error loading image: \(error)")
                        return
                    }

                    if let imageData = data, let image = UIImage(data: imageData) {
                        DispatchQueue.main.async {
                            self.imgAll.image = image
                            self.imageCache.setObject(image, forKey: imagesUrl as NSString)
                        }
                    }
                }
                task.resume()
            }
        }
    }
    //----------------------------------------
    
    //MARK: - Actions
    
    //----------------------------------------
    
    //MARK: - Lifecycle methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    //----------------------------------------

}
