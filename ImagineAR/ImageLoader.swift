//
//  ImageLoader.swift
//  ImagineAR
//
//  Created by Karim Amanov on 26/10/2019.
//  Copyright © 2019 Karim Amanov. All rights reserved.
//

import UIKit


protocol ImageLoader {
    func loadImage(artObjectId: Int, completion: @escaping (Result<UIImage, Error>) -> Void)
}
