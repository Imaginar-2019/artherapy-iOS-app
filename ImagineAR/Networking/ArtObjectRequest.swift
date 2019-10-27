//
//  ArtObjectRequest.swift
//  ImagineAR
//
//  Created by Karim Amanov on 26/10/2019.
//  Copyright © 2019 Karim Amanov. All rights reserved.
//

import Foundation

struct ArtObjectsRequest: APIRequest {
    typealias APIResponseType = ArtObjectsDTO
    
    var endpoint = "artobjects"
    var httpMethod: HttpMethod = .get
    var parameters: [String: String]? { return nil }
    
    init() {}
}

struct ArtObjectsDTO: APIResponse {
    let artobjects: [ArtObjectDTO]
}

struct ArtObjectDTO: Codable {
    let id: Int
    let title: String
    let coordinate: Coordinate
    let imageURL: URL
}
