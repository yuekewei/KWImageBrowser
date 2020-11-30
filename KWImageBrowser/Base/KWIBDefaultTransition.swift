//
//  KWIBDefaultTransition.swift
//  KWImageBrowser
//
//  Created by yuekewei on 2020/11/18.
//

import Foundation
import UIKit

enum KWTransitionType : Int {
    /// 无动效
    case none
    /// 渐隐
    case fade
    /// 连贯移动
    case coherent
}

protocol KWIBTransitionProtocol: NSObjectProtocol {
    func kwIB_showTransitioning(
        withContainer container: UIView,
        start startView: UIView?,
        start startImage: UIImage?,
        endFrame: CGRect,
        orientation: UIInterfaceOrientation,
        completion: @escaping () -> Void
    )
    
    func kwIB_hideTransitioning(
        withContainer container: UIView,
        start startView: UIView?,
        end endView: UIView?,
        orientation: UIInterfaceOrientation,
        completion: @escaping () -> Void
    )
}

class KWIBDefaultTransition: NSObject {
    /// 入场动效类型
    var showType: KWTransitionType = .coherent
    /// 出场动效类型
    var hideType: KWTransitionType = .coherent
    /// 入场动效持续时间
    var showDuration: TimeInterval = 0.25
    /// 出场动效持续时间
    var hideDuration: TimeInterval = 0.25
    
    
    // MARK: - private
    func imageViewAssimilate(to view: UIView?) -> UIImageView? {
        let animateImageView = UIImageView()
        if view is UIImageView {
            if let contentMode = view?.contentMode {
                animateImageView.contentMode = contentMode
            }
        } else {
            animateImageView.contentMode = .scaleAspectFill
        }
        animateImageView.layer.masksToBounds = view?.layer.masksToBounds ?? false
        animateImageView.layer.cornerRadius = view?.layer.cornerRadius ?? 0.0
        animateImageView.layer.backgroundColor = view?.layer.backgroundColor
        return animateImageView
    }
    
}


extension KWIBDefaultTransition: KWIBTransitionProtocol {
    func kwIB_showTransitioning(withContainer container: UIView,
                                start startView: UIView?,
                                start startImage: UIImage?,
                                endFrame: CGRect,
                                orientation: UIInterfaceOrientation,
                                completion: @escaping () -> Void) {
        var type = showType
        if type == .coherent {
            if endFrame.isEmpty || startView == nil || orientation != UIInterfaceOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue) {
                type = .fade
            }
        }
        
        switch type {
        case .none:
            completion()
        case .fade:
            let animateValid = !endFrame.isEmpty && (startView != nil)
            
            var animateImageView: UIImageView?
            if animateValid {
                animateImageView = imageViewAssimilate(to: startView)
                animateImageView?.frame = endFrame
                animateImageView?.image = startImage
                if let animateImageView = animateImageView {
                    container.addSubview(animateImageView)
                }
            }
            
            let rawAlpha = container.alpha
            container.alpha = 0
            
            if !animateValid {
                completion()
            }
            
            UIView.animate(withDuration: showDuration, animations: {
                container.alpha = rawAlpha
            }) { finished in
                if animateValid {
                    animateImageView?.removeFromSuperview()
                    completion()
                }
            }
            
        case .coherent:
            let animateImageView = imageViewAssimilate(to: startView)
            animateImageView?.frame = startView?.convert(startView!.bounds, to: container) ?? CGRect.zero
            animateImageView?.image = startImage
            
            if let animateImageView = animateImageView {
                container.addSubview(animateImageView)
            }
            
            let rawBackgroundColor = container.backgroundColor
            container.backgroundColor = rawBackgroundColor?.withAlphaComponent(0)
            
            UIView.animate(withDuration: showDuration, animations: {
                animateImageView?.frame = endFrame
                container.backgroundColor = rawBackgroundColor
            }) { finished in
                completion()
                UIView.animate(withDuration: 0.2, animations: {
                    animateImageView?.alpha = 0
                }) { finished in
                    animateImageView?.removeFromSuperview()
                }
            }
            
        }
    }
    
    func kwIB_hideTransitioning(withContainer container: UIView,
                                start startView: UIView?,
                                end endView: UIView?,
                                orientation: UIInterfaceOrientation,
                                completion: @escaping () -> Void) {
        var type = hideType
        if type == .coherent && (startView == nil || endView == nil) {
            type = .fade
        }
        
        switch type {
        case .none:
            completion()
        case .fade:
            
            let rawAlpha = container.alpha
            
            UIView.animate(withDuration: hideDuration, animations: {
                container.alpha = 0
            }) { finished in
                completion()
                container.alpha = rawAlpha
            }
        case .coherent:
            let startFrame = startView!.frame
            let endFrame = endView!.convert(endView!.bounds , to: startView!.superview)
            
            let rawBackgroundColor = container.backgroundColor
            
            UIView.animate(withDuration: hideDuration, animations: {
                container.backgroundColor = rawBackgroundColor?.withAlphaComponent(0)
                
                startView!.contentMode = endView!.contentMode
                
                var transform = startView!.transform
                let statusBarOrientation = UIInterfaceOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue)
                if orientation != statusBarOrientation {
                    transform = transform.rotated(by: KWIBRotationAngle(orientation, statusBarOrientation!))
                    
                }
                
                if startView is UIImageView {
                    startView?.frame = endFrame
                    startView?.transform = transform
                }
                else {
                    let scale = CGFloat(max(endFrame.size.width / startFrame.size.width, endFrame.size.height / startFrame.size.height))
                    startView!.center = CGPoint(x: endFrame.size.width * startView!.layer.anchorPoint.x + endFrame.origin.x, y: endFrame.size.height * startView!.layer.anchorPoint.y + endFrame.origin.y)
                    startView!.transform = transform.scaledBy(x: scale, y: scale)
                }
            }) { (finished) in
                completion();
                container.backgroundColor = rawBackgroundColor;
            }
        }
    }
}
