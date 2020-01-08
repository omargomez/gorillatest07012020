//
//  URLSession+Extensions.swift
//  Ice Cream Parlor
//
//  Created by Omar Eduardo Gomez Padilla on 1/7/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import Foundation
import UIKit

extension URLSession {
    
    enum JsonError: Error {
        case noDataError
        case parsingError
    }
    
    enum ImageError: Error {
        case noDataError
        case creationError
    }
    
    func doJsonTask(forURL endpoint: URL, completion: @escaping (_ data: Any?, _ error: Error?) -> Void ) {
        
        let task = URLSession.shared.dataTask(with: endpoint) {(data, response, error ) in
            
            guard error == nil else {
                print("returned error")
                completion(nil, error)
                return
            }
            
            guard let content = data else {
                completion(nil, JsonError.noDataError)
                return
            }
            
            guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) else {
                completion(nil, JsonError.parsingError)
                return
            }
            
            completion(json, nil)
            
        }
        
        task.resume()
        
    }
    
    func createImageTask(fromURL imageURL: URL, completion: @escaping (UIImage?, Error?) -> Void ) -> URLSessionTask {
        
        let task = URLSession.shared.dataTask(with: imageURL) {(data, response, error ) in
            
            guard error == nil else {
                print("returned error")
                completion(nil, error)
                return
            }
            
            guard let imageData = data else {
                completion(nil, ImageError.noDataError)
                return
            }
            
            guard let image = UIImage(data: imageData) else {
                completion(nil, ImageError.creationError)
                return
            }
            
            completion(image, nil)
            
        }
        
        return task
        
    }
    
    func doImageTask(fromURL imageURL: URL, completion: @escaping (UIImage?, Error?) -> Void ) {
        
        let task = createImageTask(fromURL: imageURL, completion: completion)
        task.resume()
        
    }
}

