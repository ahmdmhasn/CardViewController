//
//  UIView+Snapshot.swift
//  TabBarDemo
//
//  Created by Ahmed M. Hassan on 1/28/20.
//  Copyright © 2020 Ahmed M. Hassan. All rights reserved.
//

import UIKit

extension UIView {
    
    // render the view within the view's bounds, then capture it as image
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image(actions: { rendererContext in
            layer.render(in: rendererContext.cgContext)
        })
    }

}
