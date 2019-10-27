//
//  ARViewController.swift
//  ImagineAR
//
//  Created by Karim Amanov on 26/10/2019.
//  Copyright © 2019 Karim Amanov. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import ARCL
import CoreLocation

class ARViewController: UIViewController, ARSCNViewDelegate, LNTouchDelegate {

    private var closeButton: UIButton!
    private var statusLabel: UILabel!
    private var sceneLocationView: SceneLocationView!
    private let targetAnnotation: MapAnnotation
    
    init(annotations: AnySequence<MapAnnotation>, target: MapAnnotation) {
        self.targetAnnotation = target
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sceneLocationView = SceneLocationView()
        sceneLocationView.locationViewDelegate = self
        sceneLocationView.translatesAutoresizingMaskIntoConstraints = false
        sceneLocationView.showsStatistics = true
        sceneLocationView.showAxesNode = true
        sceneLocationView.autoenablesDefaultLighting = false
        
        view.addSubview(sceneLocationView)
        view.addConstraints([
            sceneLocationView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneLocationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sceneLocationView.leftAnchor.constraint(equalTo: view.leftAnchor),
            sceneLocationView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        closeButton = UIButton(type: .close)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        view.addConstraints([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)
        ])
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
                
        statusLabel = UILabel()
        statusLabel.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        statusLabel.font = .systemFont(ofSize: 15.0)
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        view.addConstraints([
            statusLabel.widthAnchor.constraint(equalTo: view.widthAnchor),
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
        ])
    }
    
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func addArtObject(_ coordinate: Coordinate, image: UIImage) {
        let location = coordinate.location
        let annotationNode = LocationAnnotationNode(location: location, image: image)
        annotationNode.scaleRelativeToDistance = true
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneLocationView.run()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        ArtObjectsRepository.shared.loadImage(artObjectId: targetAnnotation.id) { result in
            switch result {
            case .success(let img): self.addArtObject(self.targetAnnotation.coordinate, image: img)
            case .failure(let error): print("Failed to load image: \(error)")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneLocationView.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func locationNodeTouched(node: AnnotationNode) {
        //TODO add feedback
    }
    
}

extension ARViewController: SceneLocationViewDelegate {

}



