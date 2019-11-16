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
    second
}

struct Location: Codable {
    
    let lat: Double
    let long: Double
    let floor: Floor
    
    var cllocation: CLLocation {
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        return CLLocation(coordinate: coordinate, altitude: altitude)
    }
    
    private var altitude: Double {
        switch floor {
        case .zero:
            return -5
        case .first:
            return 13
        case .second:
            return 30
        }
    }
}
