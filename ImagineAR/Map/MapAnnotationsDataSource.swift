//
//  MapAnnotationsDataSource.swift
//  ImagineAR
//
//  Created by Karim Amanov on 26/10/2019.
//  Copyright © 2019 Karim Amanov. All rights reserved.
//


protocol MapAnnotationsDataSourceProtocol: class {
    var annotations: AnySequence<MapAnnotation> { get }
    var delegate: MapAnnotationsDataSourceDelegate? { get set }
}

protocol MapAnnotationsDataSourceDelegate: class {
    func annotationsDataSourceDidUpdate()
}

class MapAnnotationsDataSource: MapAnnotationsDataSourceProtocol {
    private let artObjectsRepo: ArtObjectsRepositoryProtocol
    weak var delegate: MapAnnotationsDataSourceDelegate?

    init(artObjectsRepo: ArtObjectsRepositoryProtocol = ArtObjectsRepository.shared) {
        self.artObjectsRepo = artObjectsRepo
        
        artObjectsRepo.addUpdateObserver { [weak self] in
            self?.delegate?.annotationsDataSourceDidUpdate()
        }
    }
    
    var annotations: AnySequence<MapAnnotation> {
        guard let artObjects = artObjectsRepo.artObjectsSeq else { return AnySequence([]) }
        
        return AnySequence(artObjects.map {
            let coordinate = Coordinate(latitude: $0.latitude, longitude: $0.longitude, altitude: $0.altitude)
            return MapAnnotation(id: $0.id, title: $0.title, coordinate: coordinate)
        })
    }
}
