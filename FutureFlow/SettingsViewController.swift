//
//  SettingsViewController.swift
//  ARKit+CoreLocation
//
//  Created by Eric Internicola on 2/19/19.
//  Copyright © 2019 Project Dent. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit

@available(iOS 11.0, *)
class SettingsViewController: UIViewController {
    @IBOutlet weak var gif2: UIImageView!
    
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gif2.loadGif(asset: "anigif2")
        startButton.layer.cornerRadius = 5
        
//        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)

    }
    
    @IBAction func tappedOpenARButton2(_ sender: Any) {
        let arclVC = self.createARVC()
        self.navigationController?.pushViewController(arclVC, animated: true)
    }
    
    func createARVC() -> POIViewController {
           let arclVC = POIViewController.loadFromStoryboard()
           return arclVC
       }
}
