//
//  APIClient.swift
//  ImagineAR
//
//  Created by Karim Amanov on 26/10/2019.
//  Copyright © 2019 Karim Amanov. All rights reserved.
//

import Foundation
import UIKit

protocol APIResponse: Codable {}

enum HttpMethod: String {
    case get
    case post
    case put
    case patch
    case delete
}

protocol APIRequest {
    associatedtype APIResponseType: APIResponse
    var endpoint: String { get }
    var httpMethod: HttpMethod { get }
    var parameters: [String: String]? { get }
}

enum APIClientError: Error {
    case InvalidResponse
}

protocol APIClientProtocol {
    func runRequest<T: APIRequest>(_ request: T, completion: @escaping (Result<T.APIResponseType, Error>) -> Void)
    func loadImage(with url: URL, completion: @escaping (Result<UIImage, Error>) -> Void)
}

class APIClient: APIClientProtocol {
    static private let baseURL = "http://192.168.0.248:7777/api/"
    let session = URLSession(configuration: .default)
    
    func runRequest<T: APIRequest>(_ request: T, completion: @escaping (Result<T.APIResponseType, Error>) -> Void) {
        guard let baseURL = URL( string: "\(Self.baseURL)\(request.endpoint)"),
                var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            fatalError("Invalid base url")
        }
        if let params = request.parameters {
            urlComponents.queryItems = params.map { URLQueryItem(name: $0, value: $1) }
        }
        guard let url = urlComponents.url else {
            fatalError("Invalid request")
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.httpMethod.rawValue
        print("Run request: \(urlRequest)")
        session.dataTask(with: urlRequest) { data, response, error in
            guard let data = data else {
                completion(.failure(error ?? APIClientError.InvalidResponse))
                return
            }
            do {
                let result = try JSONDecoder().decode(T.APIResponseType.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func loadImage(with url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        session.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else {
                completion(.failure(error ?? APIClientError.InvalidResponse))
                return
            }
            completion(.success(image))
        }.resume()
    }
}
