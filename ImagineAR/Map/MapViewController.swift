//
//  MapViewController.swift
//  ImagineAR
//
//  Created by Karim Amanov on 26/10/2019.
//  Copyright © 2019 Karim Amanov. All rights reserved.
//

import UIKit
import GoogleMaps


class MapViewController: UIViewController {
    private let annotationsDataSource: MapAnnotationsDataSourceProtocol
    private let locationManager = CLLocationManager()
    
    private var arButton: UIButton!
    private var mapView: GMSMapView!
    private var idToMarker: [Int: GMSMarker] = [:]
    
    init(annotationsDataSource: MapAnnotationsDataSourceProtocol) {
        self.annotationsDataSource = annotationsDataSource
        super.init(nibName: nil, bundle: nil)
        annotationsDataSource.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateAnnotations(animated: Bool = false) {
        var markerIDs: Set<Int> = []
        for annotation in annotationsDataSource.annotations {
            let position = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude,
                                                  longitude: annotation.coordinate.longitude)
            
            let marker = idToMarker[annotation.id] ?? {
                let marker = GMSMarker(position: position)
                idToMarker[annotation.id] = marker
                return marker
            }()
            
            if animated {
                marker.appearAnimation = .pop
            }
            marker.title = annotation.title
            marker.isTappable = false
            marker.icon = UIImage(named: "annotation_icon")
            markerIDs.insert(annotation.id)
            marker.map = mapView
        }
        
        idToMarker.lazy.filter { key, _ in !markerIDs.contains(key) }.forEach { key, marker in
            marker.map = nil
            idToMarker[key] = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        mapView = GMSMapView(frame: UIScreen.main.bounds)
        mapView.delegate = self
            
        do {
            guard let styleURL = Bundle.main.url(forResource: "mapStyle", withExtension: "json") else {
                fatalError("Unable to find style")
            }
            mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
        } catch {
            print("Style loading error: \(error)")
        }

        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.settings.compassButton = true
        view.addSubview(mapView)
        view.addConstraints([
            mapView.topAnchor.constraint(equalTo: self.view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            mapView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: self.view.rightAnchor)
        ])
        
        arButton = UIButton(type: .custom)
        arButton.setBackgroundImage(UIImage(named: "arbutton"), for: .normal)
        //arButton.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        //arButton.titleLabel?.font = .boldSystemFont(ofSize: 30.0)
        //arButton.setTitleColor(.gray, for: .normal)
       // arButton.setTitle("AR", for: .normal)
       // arButton.layer.cornerRadius = 15.0
       // arButton.contentEdgeInsets = .init(top: 4, left: 22, bottom: 4, right: 22)
        arButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(arButton)
        view.addConstraints([
            arButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            arButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        ])
        arButton.addTarget(self, action: #selector(onARTapped), for: .touchUpInside)
        setARButtonActive(true)
    }
    
    @objc private func onARTapped() {
        guard let nearest = nearestAnnotation else {
            showNoAnnotationAlert()
            return
        }
        let arController = ARViewController(annotations: annotationsDataSource.annotations,
                                            target: nearest)
        arController.modalPresentationStyle = .fullScreen
        self.present(arController, animated: true, completion: nil)
    }
        
    private var nearestAnnotation: MapAnnotation? {
        let minDistance: Double = .greatestFiniteMagnitude
        var nearest: MapAnnotation?
        guard let currentLocation = locationManager.location else { return nil }
        for a in self.annotationsDataSource.annotations {
            let location = a.coordinate.location
            let distance = currentLocation.distance(from: location)
            if distance < minDistance {
                nearest = a
            }
        }
        return nearest
    }
    
    private var isARAvailable: Bool {
        return nearestAnnotation != nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.arButton.isEnabled {
            self.setARButtonActive(true)
        }

    }
    
    func setARButtonActive(_ active: Bool) {
        guard CameraAuthorizationHelper.accessGranted else {
            
            return
        }
        arButton.isEnabled = active
        guard active else {
            arButton.layer.removeAllAnimations()
            return
        }
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.6
        pulse.fromValue = 1.0
        pulse.toValue = 1.12
        pulse.autoreverses = true
        pulse.repeatCount = 1
        pulse.initialVelocity = 0.5
        pulse.damping = 0.8

        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 2.0
        animationGroup.repeatCount = .greatestFiniteMagnitude
        animationGroup.animations = [pulse]
    
        arButton.layer.add(animationGroup, forKey: "pulse")
    }
}

extension MapViewController: GMSMapViewDelegate {
    static var onboardingShowed: Bool {
        get {
            UserDefaults.standard.bool(forKey: "onboarding")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "onboarding")
        }
    }

}

extension MapViewController {
    convenience init() {
        self.init(annotationsDataSource: MapAnnotationsDataSource())
    }
}

extension MapViewController: MapAnnotationsDataSourceDelegate {
    func annotationsDataSourceDidUpdate() {
        updateAnnotations(animated: true)
    }
}

extension MapViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    guard status == .authorizedWhenInUse else { return }
    
    CameraAuthorizationHelper.requestAccessIfNeeded {
        DispatchQueue.main.async {
            if !Self.onboardingShowed {
                let v = OnboardingViewController()
                v.modalPresentationStyle = .overCurrentContext
                v.modalTransitionStyle = .crossDissolve
                self.present(v, animated: true, completion: nil)
                Self.onboardingShowed = true
                v.onClose = {
                    self.dismiss(animated: true, completion: nil)
                    self.updateAnnotations()
                    self.setARButtonActive(true)
                }
            } else {
                self.updateAnnotations()
                self.setARButtonActive(true)
            }


        }
    }

    locationManager.startUpdatingLocation()
    mapView.isMyLocationEnabled = true
    mapView.settings.myLocationButton = true
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else { return }
    mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
    locationManager.stopUpdatingLocation()
  }
}

extension MapViewController {
    func showCameraAccessAlert() {
        let alert = UIAlertController(
            title: "Important",
            message: "Camera access required for AR mode",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .default, handler: { (alert) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func showNoAnnotationAlert() {
        let alert = UIAlertController(
            title: "Ooops",
            message: "There is no art object nearby",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
