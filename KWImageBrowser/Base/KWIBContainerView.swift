//
//  KWIBContainerView.swift
//  KWImageBrowser
//
//  Created by yuekewei on 2020/11/18.
//

import UIKit

class KWIBContainerView: UIView {

   override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let originView = super.hitTest(point, with: event)
        if originView == self {
            // Continue hit-testing if the view is kind of 'self.class'.
            return nil
        }
        return originView
    }
}
