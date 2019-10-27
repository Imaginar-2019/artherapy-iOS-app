//
//  APIClientFactory.swift
//  ImagineAR
//
//  Created by Karim Amanov on 26/10/2019.
//  Copyright © 2019 Karim Amanov. All rights reserved.
//


protocol APIClientFactoryProtocol {
    static var apiClient: APIClientProtocol { get }
}


class APIClientFactory: APIClientFactoryProtocol {
    static var apiClient: APIClientProtocol {
        return APIClientMock()
    }
}
