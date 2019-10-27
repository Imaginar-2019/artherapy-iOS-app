//
//  ArtObjectsRepository.swift
//  ImagineAR
//
//  Created by Karim Amanov on 26/10/2019.
//  Copyright © 2019 Karim Amanov. All rights reserved.
//

import Foundation
import RealmSwift

protocol ArtObjectsRepositoryProtocol: class {
    var artObjectsSeq: AnySequence<ArtObject>? { get }
    func addUpdateObserver(_ observer: @escaping () -> Void)
}

class ArtObjectsRepository: ArtObjectsRepositoryProtocol {
    var artObjectsSeq: AnySequence<ArtObject>? {
        return artObjects.map { AnySequence($0) }
    }
    
    public static let shared = ArtObjectsRepository()
    private let apiClient = APIClientFactory.apiClient
    private let artObjectsLoader: ArtObjectsLoaderProtocol
    private var artObjects: Results<ArtObject>?
    private var observationToken: NotificationToken!
    private var observers: [() -> Void] = []
    
    init(artObjectsLoader: ArtObjectsLoaderProtocol) {
        self.artObjectsLoader = artObjectsLoader
        loadFromStore()
    }
    
    func addUpdateObserver(_ observer: @escaping () -> Void) {
        self.observers.append(observer)
    }
    
    private func loadFromStore() {
        guard let realm = self.realm else { return }
        let artObjects = realm.objects(ArtObject.self)
        observationToken = artObjects.observe { changes in
            switch changes {
            case .update: self.observers.forEach { $0() }
            default: break
            }
        }
        self.artObjects = artObjects
    }
    
    func update() {
        self.artObjectsLoader.loadObjects { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let objects): self.save(objects)
            case .failure(let error): print("Failed to load art objects: \(error)")
            }
        }
    }
    
    private func save(_ objects: [ArtObjectDTO]) {
        DispatchQueue.global().async {
            guard let realm = self.realm else { return }
            do {
                try realm.write {
                    realm.add(objects.map {
                        let artObject = ArtObject()
                        artObject.id = $0.id
                        artObject.title = $0.title
                        artObject.latitude = $0.coordinate.latitude
                        artObject.longitude = $0.coordinate.longitude
                        artObject.altitude = $0.coordinate.altitude
                        artObject.remoteImageURL = $0.imageURL.absoluteString
                        return artObject
                    }, update: .modified)
                }
            } catch {
                print("Failed to store art objects: \(error)")
            }
        }
    }
    
    private var realm: Realm? {
        do {
            return try Realm()
        } catch {
            print("Failed to create realm: \(error)")
            return nil
        }
    }
}

extension ArtObjectsRepository {
    convenience init() {
        self.init(artObjectsLoader: ArtObjectsLoader(apiClient: APIClientFactory.apiClient))
    }
}

extension ArtObjectsRepository: ImageLoader {

    func loadImage(artObjectId: Int, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let realm = self.realm,
            let artObject = realm.object(ofType: ArtObject.self, forPrimaryKey: artObjectId) else {
                print("Failed to retrieve object with id: \(artObjectId)")
                return
        }
        
        let completionOnMain: (Result<UIImage, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let localImagePath = Self.imagePathForArtObject(with: artObjectId)
        if FileManager.default.fileExists(atPath: localImagePath) {
            DispatchQueue.global().async {
                guard let image = UIImage(contentsOfFile: localImagePath) else {
                    try! FileManager.default.removeItem(atPath: localImagePath)
                    self.loadImage(artObjectId: artObjectId, completion: completion)
                    return
                }
                completionOnMain(.success(image))
            }
            return
        }
        
        guard let remoteImageURL = URL(string: artObject.remoteImageURL) else {
            print("Invalid remote URL")
            return
        }
        
        apiClient.loadImage(with: remoteImageURL) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let image):
                self.saveImage(image, path: localImagePath) {
                    completionOnMain(.success(image))
                }
            case .failure(let error):
                completionOnMain(.failure(error))
                print("Failed to load image: (error)")
            }
        }
    }
    
    private func saveImage(_ image: UIImage, path: String, completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            do {
                guard let data = image.pngData() else {
                    print("Failed to get png data")
                    return
                }
                try data.write(to: URL(fileURLWithPath: path))
            } catch {
                print("Failed to store image: \(error)")
            }
            completion()
        }
    }

    static func imagePathForArtObject(with id: Int) -> String  {
        let newFileName = "ArtObjectImage\(id).png"
        let directoryURL = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("ArtObjectImages", isDirectory: true)
        var isDirectory = ObjCBool(true)
        if !FileManager.default.fileExists(atPath: directoryURL.path, isDirectory: &isDirectory) {
            try! FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        let resultURL = directoryURL.appendingPathComponent(newFileName)
        return resultURL.path
    }
}
