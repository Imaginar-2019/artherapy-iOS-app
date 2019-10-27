//
//  MapAnnotation.swift
//  ImagineAR
//
//  Created by Karim Amanov on 26/10/2019.
//  Copyright © 2019 Karim Amanov. All rights reserved.
//

import CoreLocation

struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double
    let altitude: Double
}

extension Coordinate {
    var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}

struct MapAnnotation {
    let id: Int
    let title: String
    let coordinate: Coordinate
}
