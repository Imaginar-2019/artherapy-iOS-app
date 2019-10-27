//
//  CameraAuthorizationHelper.swift
//  ImagineAR
//
//  Created by Karim Amanov on 26/10/2019.
//  Copyright © 2019 Karim Amanov. All rights reserved.
//

import UIKit
import AVFoundation

class CameraAuthorizationHelper {

    static func requestAccessIfNeeded(_ completion: @escaping () -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined: AVCaptureDevice.requestAccess(for: .video) { _ in
            completion()
        }
        break
        default: completion()
        }
    }
    
    static var accessGranted: Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
}
