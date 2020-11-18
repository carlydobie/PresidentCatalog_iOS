//
//  PortriatStore.swift
//  Assignment5
//
//  Created by Carly Dobie on 11/17/20.
//  Copyright © 2020 Carly Dobie. All rights reserved.
//

import Foundation
import UIKit
class PortraitStore {
    
    let imageCache = NSCache<NSString, UIImage>()
    
    func downloadImage(with urlString: String, completion: @escaping (_ image: UIImage?) -> Void) {
        
        if urlString == "None" {
            completion(UIImage(named: "default.png"))
        } else if let cachedImage = imageCache.object(forKey: urlString as NSString)
        {
            completion(cachedImage)
        } else if let cachedImage = readImage(named: fileNameFrom(urlString)) {
            completion(cachedImage)
        } else {
            
            weak var weakSelf = self
            if let url = URL(string: urlString) {
                
                let task = URLSession.shared.dataTask(with: url) {
                    (data, response, error) in
                    
                    let httpResponse = response as? HTTPURLResponse
                    
                    if httpResponse!.statusCode != 200 {
                        
                        DispatchQueue.main.async {
                            print("HTTP Error: status code \(httpResponse!.statusCode)")
                            completion(UIImage(named: "default.png"))
                        }
                    } else if (data == nil && error != nil) {
                        DispatchQueue.main.async {
                            print("No data downloaded fro \(urlString)")
                            completion(UIImage(named: "default.png"))
                        }
                    } else {
                        if let image = UIImage(data: data!) {
                            DispatchQueue.main.async {
                                weakSelf!.imageCache.setObject(image, forKey: urlString as NSString)
                                weakSelf!.saveImage(image, named:
                                    weakSelf!.fileNameFrom(urlString))
                                completion(image)
                            }
                        } else {
                            DispatchQueue.main.async {
                                print("\(urlString) is not a valid image")
                                completion(UIImage(named: "default:png"))
                            }
                        }
                    }
                }
                task.resume()
            } else {
            DispatchQueue.main.async {
                print("\(urlString) is not a valid URL")
                completion(UIImage(named: "default.png"))
            }
        }
        }
    }

    private func fileNameFrom(_ urlString: String) -> String {
        let fileArray = urlString.components(separatedBy: "/")
        return fileArray.last!
    }

    private func documentDirectory() -> String {
        let documentDirectoryArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return documentDirectoryArray[0]
    }

    private func append(toPath path: String, withPathComponent pathComponent: String) -> String? {
        if var pathURL = URL(string: path) {
            pathURL.appendPathComponent(pathComponent)
            return pathURL.absoluteString
        }
        return nil
    }

    func saveImage(_ image: UIImage, named fileName: String) {
        let fileManager = FileManager.default
    
        guard let filePath = append(toPath: documentDirectory(), withPathComponent: fileName) else {
            return
        }
        let imageData = image.jpegData(compressionQuality: 1.0)
        fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil)
    }

    func readImage(named fileName: String) -> UIImage? {
        guard let filePath = append(toPath: documentDirectory(), withPathComponent: fileName) else {
            return nil
        }
        return UIImage(contentsOfFile: filePath)
    }

    func clearCache() {
        imageCache.removeAllObjects()
    }

}
