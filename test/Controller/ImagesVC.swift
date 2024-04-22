//
//  ViewController.swift
//  test
//
//  Created by MacbookAir_32 on 18/04/24.
//

import UIKit
import CommonCrypto

class ImagesVC: UIViewController {
    
    //MARK: Outlate
    
    @IBOutlet weak var colImages  : UICollectionView!
    
    @IBOutlet weak var loader     : UIActivityIndicatorView!
    
    //-----------------------------------------
    
    //MARK: - Custom Variables
    
    var arrImages : [String] = []
    
    var imageCache: NSCache<NSString, UIImage> = NSCache()
    let fileManager = FileManager.default
    
    lazy var diskCachePath: String = {
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + "/ImageCache"
        if !fileManager.fileExists(atPath: path) {
            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating disk cache directory: \(error.localizedDescription)")
            }
        }
        return path
    }()
    
    //-----------------------------------------
    
    //MARK: Custom Method
    
    func setup(){
        self.applyTheme()
        
   
        self.fetchDataFromApi(urlString: "https://acharyaprashant.org/api/v2/content/misc/media-coverages?limit=100")
    }
    
    func applyTheme(){
        
        self.colImages.delegate     = self
        self.colImages.dataSource   = self
        
        self.loader.startAnimating()
        
    }
    
    func fetchDataFromApi(urlString: String) {
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL for api")
            return
        }
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest  = 30
        sessionConfig.timeoutIntervalForResource = 60
        
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(" Error: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response from api")
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                
                if let data = data {
                    do {
                        let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
                        self.arrImages.removeAll()
                        
                        jsonResult?.forEach { coverage in
                            if let imagepass = coverage["coverageURL"] as? String {
                                
                                self.arrImages.append(imagepass)
                                
                            }
                            
                            DispatchQueue.main.async {
                                self.loader.isHidden = true
                                self.colImages.reloadData()
                            }
                        }
                    } catch {
                        print("Error parsing JSON: \(error.localizedDescription)")
                    }
                }
            case 400...499:
                print("Client error for api: \(httpResponse.statusCode)")
            case 500...599:
                print("Server error for api: \(httpResponse.statusCode)")
            default:
                print("Unexpected response for api: \(httpResponse.statusCode)")
            }
        }
        
        task.resume()
    }
    
    
    func saveImageToDiskCache(image: UIImage, urlString: String) {
        let imagePath = URL(fileURLWithPath: diskCachePath).appendingPathComponent(urlString.md5 + ".jpg")
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            do {
                try imageData.write(to: imagePath)
                print("Image saved to disk cache")
            } catch {
                print("Error saving image to disk cache: \(error.localizedDescription)")
            }
        }
    }
    
   
    //-----------------------------------------
    
    //MARK: Action
    
    
    //-----------------------------------------
    
    //MARK: Life-Cycle Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        
    }
    
}

//MARK: - UICollectionViewDelegate,UICollectionViewDataSource

extension ImagesVC: UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrImages.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let objCell  = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagesCellClass", for: indexPath) as! ImagesCellClass
        
        objCell.confing(imagesUrl: self.arrImages[indexPath.item])
        
        return objCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.bounds.size.width/3 - 10
        let height = collectionView.bounds.size.width/2.5 - 10
        return CGSize(width: width - 10, height: height - 20)
    }
}

extension String {
    var md5: String {
        let data = Data(self.utf8)
        let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
}
