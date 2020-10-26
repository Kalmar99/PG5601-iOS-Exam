//
//  FetchData.swift
//  CleverWeather
//
//  Created by REDACTED on 10/26/20.
//  "Borrowed" the completion handler code from here: https://stackoverflow.com/questions/40184468/convert-data-to-string-in-swift-3/40185083

import Foundation

enum FetchResponse {
    case success(String),failure(Error)
}

class FetchData {
    
    func get(url: String, complete: @escaping (FetchResponse) -> Void ) {
        
        let endpoint = URL(string: url)!
        let session = URLSession.shared;
        let task = session.dataTask(with: endpoint, completionHandler: { (data, response, error) in
            if(error != nil) {
                complete(.failure(error!))
            } else if(data != nil) {
                complete(.success(String(data: data!, encoding: .utf8)!))
            } else {
                complete(.failure(NSError(domain: "example.cleverweather", code: 500, userInfo: [NSLocalizedDescriptionKey : "Cant convert data to string"])))
            }
        })
        task.resume()
        
    }
    
}
