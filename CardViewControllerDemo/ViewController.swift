//
//  ViewController.swift
//  TabBarDemo
//
//  Created by Ahmed M. Hassan on 1/27/20.
//  Copyright © 2020 Ahmed M. Hassan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    
    @IBAction func didTapButton(_ sender: UIButton) {
        
        let cardVC = CardViewController(viewController: ChildViewController())
        
        // present the view controller modally without animation
        self.present(cardVC, animated: false, completion: nil)

    }
    
}

