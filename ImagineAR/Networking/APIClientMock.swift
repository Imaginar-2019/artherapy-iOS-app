//
//  APIClientMock.swift
//  ImagineAR
//
//  Created by Karim Amanov on 26/10/2019.
//  Copyright © 2019 Karim Amanov. All rights reserved.
//

import UIKit

class APIClientMock: APIClientProtocol {
    func runRequest<T>(_ request: T, completion: @escaping (Result<T.APIResponseType, Error>) -> Void) where T : APIRequest {
        let coordinates: [Coordinate] = [
            Coordinate(latitude: 47.485888, longitude: 19.064392, altitude: 0.0),
            Coordinate(latitude: 47.484571, longitude: 19.062611, altitude: 0.0),
            Coordinate(latitude: 47.484257, longitude: 19.065508, altitude: 0.0)
        ]
        let response = ArtObjectsDTO(artobjects: coordinates.enumerated().map { id, coord in
            return ArtObjectDTO(id: id,
                                title: "Obj\(id)",
                                coordinate: coord,
                                imageURL: URL(fileURLWithPath: ""))
        })
        guard let typed = response as? T.APIResponseType else {
            fatalError("Unmocked request")
        }
        completion(.success(typed))
    }
    
    func loadImage(with url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        DispatchQueue.global().async {
            guard let mockImg = Bundle.main.path(forResource: "mock_img", ofType: "jpeg"),
                let image = UIImage(contentsOfFile: mockImg) else {
                fatalError("Failed to load mock image")
            }
            DispatchQueue.main.async {
                completion(.success(image))
            }
        }

    }
}
