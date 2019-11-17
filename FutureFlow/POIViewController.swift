//
//  POIViewController.swift
//  ARKit+CoreLocation
//
//  Created by Andrew Hart on 02/07/2017.
//  Copyright © 2017 Project Dent. All rights reserved.
//

import ARKit
import MapKit
import SceneKit
import UIKit

@available(iOS 11.0, *)
/// Displays Points of Interest in ARCL
class POIViewController: UIViewController {
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet weak var nodePositionLabel: UILabel!

    @IBOutlet var contentView: UIView!
    let sceneLocationView = SceneLocationView()

    var updateUserLocationTimer: Timer?
    var updateInfoLabelTimer: Timer?
    var updateLocationsTimer: Timer?
    

    /// Whether to display some debugging data
    /// This currently displays the coordinate of the best location estimate
    /// The initial value is respected
    let displayDebugging = false

    let adjustNorthByTappingSidesOfScreen = false

    class func loadFromStoryboard() -> POIViewController {
        return UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "ARCLViewController") as! POIViewController
        // swiftlint:disable:previous force_cast
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { _ in
            self.pauseAnimation()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { _ in
            self.restartAnimation()
        }

        updateInfoLabelTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                    target: self,
                                                    selector: #selector(POIViewController.updateInfoLabel),
                                                    userInfo: nil,
                                                    repeats: true)
        
        updateLocationsTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                    target: self,
                                                    selector: #selector(POIViewController.updateLocations),
                                                    userInfo: nil,
                                                    repeats: true)

        sceneLocationView.showAxesNode = true
        sceneLocationView.showFeaturePoints = displayDebugging
        sceneLocationView.locationNodeTouchDelegate = self
        sceneLocationView.arViewDelegate = self
        sceneLocationView.locationNodeTouchDelegate = self

        contentView.addSubview(sceneLocationView)
        sceneLocationView.frame = contentView.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        restartAnimation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        print(#function)
        pauseAnimation()
        super.viewWillDisappear(animated)
    }

    func pauseAnimation() {
        print("pause")
        sceneLocationView.pause()
    }

    func restartAnimation() {
        print("run")
        sceneLocationView.run()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneLocationView.frame = contentView.bounds
    }
}

// MARK: - Implementation

@available(iOS 11.0, *)
extension POIViewController {
    
    
    
    @objc
    func updateLocations() {
        
        LocationService.shared.updateLocations { [unowned self] result in
            let locations = result ?? []
            let nodes = locations.compactMap { self.buildNode(from: $0) }
            
//            self.sceneLocationView.removeAllNodes()
//            self.sceneLocationView.addLocationNodesWithConfirmedLocation(locationNodes: nodes)
            
            let newTags = nodes.compactMap { $0.tag }
            for node in self.sceneLocationView.locationNodes {
                if !newTags.contains(node.tag!) {
                    self.sceneLocationView.removeLocationNode(locationNode: node)
                }
            }

            for node in nodes {

                if let oldNode = self.sceneLocationView.findNodes(tagged: node.tag!).first {
                    let newLocation = node.location
                    let test = CLLocation(coordinate: newLocation!.coordinate, altitude: newLocation!.altitude)
                    oldNode.updatePositionAndScale(setup: true,
                                                   scenePosition: self.sceneLocationView.scenePosition, locationNodeLocation: test,
                                                   locationManager: self.sceneLocationView.sceneLocationManager,
                                                   onCompletion: {})
                } else {
                    self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: node)
                }

            }
        }
    }
    
    func buildNode(from location: Location) -> LocationNode {
        let number = (abs(location.id.hashValue) % 14) + 1
        //let number = 1
        let image = UIImage(named: "Person \(number)")!
        
        let node = LocationAnnotationNode(location: location.cllocation, image: image)
        node.scaleRelativeToDistance = true
        node.name = location.id
        node.tag = location.id
        return node
    }


    @objc
    func updateInfoLabel() {
        if let position = sceneLocationView.currentScenePosition {
            infoLabel.text = " x: \(position.x.short), y: \(position.y.short), z: \(position.z.short)\n"
        }

        if let eulerAngles = sceneLocationView.currentEulerAngles {
            infoLabel.text!.append(" Euler x: \(eulerAngles.x.short), y: \(eulerAngles.y.short), z: \(eulerAngles.z.short)\n")
        }

		if let eulerAngles = sceneLocationView.currentEulerAngles,
			let heading = sceneLocationView.sceneLocationManager.locationManager.heading,
			let headingAccuracy = sceneLocationView.sceneLocationManager.locationManager.headingAccuracy {
            let yDegrees = (((0 - eulerAngles.y.radiansToDegrees) + 360).truncatingRemainder(dividingBy: 360) ).short
			infoLabel.text!.append(" Heading: \(yDegrees)° • \(Float(heading).short)° • \(headingAccuracy)°\n")
		}

        let comp = Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond], from: Date())
        if let hour = comp.hour, let minute = comp.minute, let second = comp.second, let nanosecond = comp.nanosecond {
            let nodeCount = "\(sceneLocationView.sceneNode?.childNodes.count.description ?? "n/a") ARKit Nodes"
            infoLabel.text!.append(" \(hour.short):\(minute.short):\(second.short):\(nanosecond.short3) • \(nodeCount)")
        }
    }

    func buildViewNode(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                       altitude: CLLocationDistance, text: String) -> LocationAnnotationNode {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let location = CLLocation(coordinate: coordinate, altitude: altitude)
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        label.text = text
        label.backgroundColor = .green
        label.textAlignment = .center
        return LocationAnnotationNode(location: location, view: label)
    }
}

// MARK: - LNTouchDelegate
@available(iOS 11.0, *)
extension POIViewController: LNTouchDelegate {

    func annotationNodeTouched(node: AnnotationNode) {
        print("AnnotationNode touched \(node)")
    }

    func locationNodeTouched(node: LocationNode) {
        print("Location node touched - tag: \(node.tag ?? "")")
    }

}

// MARK: - Helpers

extension DispatchQueue {
    func asyncAfter(timeInterval: TimeInterval, execute: @escaping () -> Void) {
        self.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(timeInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: execute)
    }
}

extension UIView {
    func recursiveSubviews() -> [UIView] {
        var recursiveSubviews = self.subviews

        subviews.forEach { recursiveSubviews.append(contentsOf: $0.recursiveSubviews()) }

        return recursiveSubviews
    }
}
