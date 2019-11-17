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
    
    let baseURL = "http://35.228.127.160"
    let decoder = JSONDecoder()
    
    var locations: [Location] = []
    
    private init() {}
    
    func updateLocations(_ callback: @escaping ([Location]?) -> Void) {
        let urlString = baseURL + "/predict?lat=60.185469&lon=24.824695&lb=1&ub=50"
        //let urlString = baseURL + "/predict_around?x=228&y=100500"
        //let urlString = baseURL + "/linear"
        guard let url = URL(string: urlString) else {
            callback(nil)
            return
        }
        
        Alamofire.request(url, method: .get).responseData { [weak self] result in
            if let data = result.data {
                var locations = try? self?.decoder.decode([Location].self, from: data)
                
                //locations?.remove(at: 4)
                
                self?.locations = locations ?? []
                
                callback(locations)
            } else {
                callback(nil)
            }
        }
    }
    
    
}
