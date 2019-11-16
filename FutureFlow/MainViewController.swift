//
//  MainViewController.swift
//  FutureFlow
//
//  Created by Володя Зверев on 17.11.2019.
//  Copyright © 2019 Mihail. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var gifImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gifImageView.loadGif(asset: "anigif")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "NavigationController")
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true)
        }
    }
}

