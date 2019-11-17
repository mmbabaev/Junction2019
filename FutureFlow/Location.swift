//
//  Location.swift
//  FutureFlow
//
//  Created by Mihail on 16.11.2019.
//  Copyright © 2019 Mihail. All rights reserved.
//

import CoreLocation

enum Floor: Int, Codable {
    case
    zero = 0,
    first,
    second,
    third
}

struct Location: Codable {
    
    let id: String
    let lat: Double
    let lon: Double
    let floor: Floor
    
    var cllocation: CLLocation {
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        return CLLocation(coordinate: coordinate, altitude: altitude)
    }
    
    private var altitude: Double {
        switch floor {
        case .zero:
            return -5
        case .first:
            return 40
        case .second:
            return 70
        case .third:
            return 100
        }
    }
}
