//
//  UIImage+KWImageBrowser.swift
//  KWImageBrowser
//
//  Created by yuekewei on 2020/11/18.
//

import Foundation
import UIKit

extension UIImage {
    open class func kw_imageNamed(_ name: String) -> UIImage? {
        let mainBundle = Bundle(for: KWImageBrowser.self)

        var resourcesBundle = Bundle(path: mainBundle.path(forResource: "KWImageBrowser", ofType: "bundle") ?? "")

        if resourcesBundle == nil {
            resourcesBundle = mainBundle
        }

        let image = UIImage(named: name, in: resourcesBundle, compatibleWith: nil)
        
        return image;
    }
}
