//
//  UIViewController+KeyWindow.swift
//  TabBarDemo
//
//  Created by Ahmed M. Hassan on 1/28/20.
//  Copyright © 2020 Ahmed M. Hassan. All rights reserved.
//

import UIKit

extension UIViewController {
    
    var keyWindow: UIView? {
        return UIApplication.shared.windows.filter{$0.isKeyWindow}.first
    }
    
}
