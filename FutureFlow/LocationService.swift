//
//  LocationService.swift
//  FutureFlow
//
//  Created by Mihail on 16.11.2019.
//  Copyright © 2019 Mihail. All rights reserved.
//

import Alamofire

final class LocationService {
    
    static let shared = LocationService()
    
    let baseURL = ""
    let decoder = JSONDecoder()
    
    var locations: [Location] = []
    
    private init() {}
    
    func updateLocations(_ callback: @escaping ([Location]?) -> Void) {
        let urlString = ""
        guard let url = URL(string: urlString) else {
            callback(nil)
            return
        }
        
        Alamofire.request(url, method: .get).responseData { [weak self] result in
            if let data = result.data {
                let locations = try? self?.decoder.decode([Location].self, from: data)
                self?.locations = locations ?? []
                callback(locations)
            } else {
                callback(nil)
            }
        }
    }
}
