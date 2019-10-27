//
//  ArtObjectsLoader.swift
//  ImagineAR
//
//  Created by Karim Amanov on 26/10/2019.
//  Copyright © 2019 Karim Amanov. All rights reserved.
//

import UIKit

protocol ArtObjectsLoaderProtocol {
    func loadObjects(_ completion: @escaping (Result<[ArtObjectDTO], Error>) -> Void)
}

class ArtObjectsLoader: ArtObjectsLoaderProtocol {
    typealias ResultBlock = (Result<[ArtObjectDTO], Error>) -> Void
    private var completions: [ResultBlock] = []
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }
    
    func loadObjects(_ completion: @escaping ResultBlock) {
        let completionOnMain: ResultBlock = { result in
            DispatchQueue.main.async {
                let completions = self.completions
                self.completions = []

                for block in completions {
                    block(result)
                }
            }
        }
        guard completions.isEmpty else {
            completions.append(completion)
            return
        }
        completions.append(completion)

        let request = ArtObjectsRequest()
        apiClient.runRequest(request) { result in
            switch result {
            case .success(let resp): completionOnMain(.success(resp.artobjects))
            case .failure(let error): completionOnMain(.failure(error))
            }
        }
    }
}
