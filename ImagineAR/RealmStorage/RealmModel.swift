//
//  RealmModel.swift
//  ImagineAR
//
//  Created by Karim Amanov on 26/10/2019.
//  Copyright © 2019 Karim Amanov. All rights reserved.
//

import RealmSwift


class ArtObject: Object {
    @objc dynamic var id = 0
    @objc dynamic var title = ""
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var altitude: Double = 0.0
    @objc dynamic var remoteImageURL: String = ""
    @objc dynamic var localImagePath: String?
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

