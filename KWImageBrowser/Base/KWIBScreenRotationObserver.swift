//
//  KWIBScreenRotationObserver.swift
//  KWImageBrowser
//
//  Created by yuekewei on 2020/11/19.
//

import Foundation
import UIKit

@objc protocol KWIBOrientationProtocol: NSObjectProtocol {
    
    /// 图片浏览器的方向将要变化
    /// - Parameter orientation: 期望的方向
    @objc optional func kw_orientationWillChange(expectOrientation: UIInterfaceOrientation)
    
    /// 图片浏览器的方向变化动效调用，实现的变化会自动转换为动画
    /// - Parameter orientation: 期望的方向
    @objc optional func kw_orientationChangeAnimation(expectOrientation: UIInterfaceOrientation)
    
    /// 图片浏览器的方向已经变化
    /// - Parameter orientation: 当前的方向
    @objc optional func kw_orientationDidChanged(expectOrientation: UIInterfaceOrientation)
}


func KWIBValidDeviceOrientation(_ orientation: UIInterfaceOrientation) -> Bool {
    let validSet:Set<UIInterfaceOrientation> = [.portrait,.unknown,.landscapeLeft,.landscapeRight]
    return validSet.contains(orientation)
}

func KWIBRotationAngle(_ startOrientation: UIInterfaceOrientation, _ endOrientation: UIInterfaceOrientation) -> CGFloat {
    let angleMap: [UIInterfaceOrientation : Double] = [
        .portrait : 0,
        .portraitUpsideDown : Double.pi,
        .landscapeLeft : -Double.pi / 2.0,
        .landscapeRight : Double.pi / 2.0
    ]
    
    let start = angleMap[startOrientation]
    let end = angleMap[endOrientation]
    let res = end! - start!
    if Double(abs(res)) > .pi {
        return CGFloat(res > 0 ? res - .pi * 2 : .pi * 2 + res)
    }
    return CGFloat(res)
}

class KWIBScreenRotationObserver: NSObject {
    
    weak var imageBrowser: KWImageBrowser?
    private(set) var currentOrientation: UIInterfaceOrientation = .portrait
    var supportedOrientations: UIInterfaceOrientationMask = .allButUpsideDown
    var rotationDuration: TimeInterval = 0.25
    private var verticalContainerSize: CGSize = CGSize.zero
    private var horizontalContainerSize: CGSize = CGSize.zero
    var recordPage: Int = 0
    
    private(set) var rotating: Bool = false {
        didSet {
            imageBrowser?.containerView.isUserInteractionEnabled = !rotating
            imageBrowser?.collectionView.isUserInteractionEnabled = !rotating
            imageBrowser?.collectionView.panGestureRecognizer.isEnabled = !rotating
        }
    }
    
    // MARK: - life
    deinit {
        clear()
    }
    
    init(browser: KWImageBrowser) {
        super.init()
        imageBrowser = browser
    }
    
    // MARK: - public
    func startObserveStatusBarOrientation() {
        
        currentOrientation = UIApplication.shared.statusBarOrientation
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(KWIBScreenRotationObserver.applicationDidChangedStatusBarOrientationNotification(noti:)),
                                               name: UIApplication.didChangeStatusBarOrientationNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(KWIBScreenRotationObserver.applicationWillChangeStatusBarOrientationNotification(noti:)),
                                               name: UIApplication.willChangeStatusBarOrientationNotification,
                                               object: nil)
    }
    
    func startObserveDeviceOrientation() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(KWIBScreenRotationObserver.deviceOrientationDidChangeNotification(noti:)),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }
    
    func configContainerSize(_ size: CGSize) {
        if currentOrientation.isLandscape {
            // Now is horizontal.
            verticalContainerSize = CGSize(width: size.height, height: size.width)
            horizontalContainerSize = size
        } else {
            // Now is vertical.
            verticalContainerSize = size
            horizontalContainerSize = CGSize(width: size.height, height: size.width)
        }
    }
    
    func containerSizeWithOrientation(orientation: UIInterfaceOrientation) -> CGSize {
        return orientation.isLandscape ? horizontalContainerSize : verticalContainerSize
    }
    
    func clear() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func interfaceOrientationForDeviceOrientation() -> UIInterfaceOrientation  {
        
        var interfaceOrientation: UIInterfaceOrientation = .unknown
        let deviceOrientation: UIDeviceOrientation = UIDevice.current.orientation
        
        switch deviceOrientation {
        case .portrait:
            interfaceOrientation = .portrait
        case .portraitUpsideDown:
            interfaceOrientation = .portraitUpsideDown
        case .landscapeLeft:
            interfaceOrientation = .landscapeRight
        case .landscapeRight:
            interfaceOrientation = .landscapeLeft
        default:
            interfaceOrientation = .unknown
            break
            
        }
        return interfaceOrientation
    }
    
    // MARK: - Notification
    
    @objc func deviceOrientationDidChangeNotification(noti: Notification) {
        if imageBrowser == nil { return }
        
        let expectOrientation: UIInterfaceOrientation = interfaceOrientationForDeviceOrientation()
        
        if rotating ||
            imageBrowser!.transitioning ||
            expectOrientation == self.currentOrientation ||
            expectOrientation == .unknown {
            return
        }
        print("22222222-------\(expectOrientation.rawValue)======\(UIDevice.current.orientation.rawValue)")
        let isCloseSplit = (Bundle.main.infoDictionary?["UIRequiresFullScreen"] as? NSNumber)?.boolValue ?? false
        if isCloseSplit || UI_USER_INTERFACE_IDIOM() == .phone {
            if !supportedOf(expectOrientation) {
                return
            }
        }
        rotating = true
        
        imageBrowser!.collectionView.scrolltoPage(page: imageBrowser!.currentPage)
        // Record current page number before transforming.
        let currentPage = imageBrowser!.currentPage
        
        let statusBarOrientation: UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
        let angleStatusBarToExpect = KWIBRotationAngle(statusBarOrientation, expectOrientation)
        let angleCurrentToExpect = KWIBRotationAngle(currentOrientation, expectOrientation)
        let expectBounds = CGRect(origin: CGPoint.zero, size: containerSizeWithOrientation(orientation: expectOrientation))
        if  let centerCell: KWIBBaseCollectionCell = imageBrowser!.collectionView.centerCell() {
            // Animate smoothly if bigger rotation angle.
            
            let duration: TimeInterval = Double(self.rotationDuration) * ((fabsf(Float(angleCurrentToExpect)) > Float(Double.pi/2.0)) ? 2.0 : 1.0)
            
            // 'collectionView' transformation.
            imageBrowser!.collectionView.bounds = expectBounds
            imageBrowser!.collectionView.transform = CGAffineTransform(rotationAngle: angleStatusBarToExpect)
            centerCell.contentView.transform = CGAffineTransform(rotationAngle: -angleCurrentToExpect)
            
            imageBrowser!.collectionView.scrolltoPage(page: currentPage)
            orientationWillChange(orientation: expectOrientation, centerCell: centerCell)
            
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: { [self] in
                
                // Maybe the internal UI need to transform.
                orientationChangeAnimation(orientation: expectOrientation, centerCell: centerCell)
                centerCell.contentView.bounds = expectBounds
                centerCell.contentView.transform = .identity
                
                imageBrowser!.containerView.bounds = expectBounds
                imageBrowser!.containerView.transform = CGAffineTransform(rotationAngle: angleStatusBarToExpect)
                
            }) { [self] finished in
                currentOrientation = expectOrientation
                rotating = false
                orientationDidChanged(orientation: expectOrientation, centerCell: centerCell)
            }
        }
    }
    
    @objc func applicationWillChangeStatusBarOrientationNotification(noti: Notification) {
        if imageBrowser == nil { return }
        
        rotating = true
        
        // Record current page number before transforming.
        recordPage = imageBrowser!.currentPage
        
        let expectOrientation: UIInterfaceOrientation = UIInterfaceOrientation.init(rawValue: (noti.userInfo?[UIApplication.statusBarOrientationUserInfoKey] as? Int) ?? 0) ?? .portrait
        if  let centerCell: KWIBBaseCollectionCell = imageBrowser!.collectionView.centerCell() {
            orientationWillChange(orientation: expectOrientation, centerCell: centerCell)
        }
    }
    
    @objc func applicationDidChangedStatusBarOrientationNotification(noti: Notification) {
        if imageBrowser == nil { return }
        
        let expectOrientation: UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
        print("111111111---------\(expectOrientation.rawValue)")
        
        if  let centerCell: KWIBBaseCollectionCell = imageBrowser!.collectionView.centerCell() {
            orientationChangeAnimation(orientation: expectOrientation, centerCell: centerCell)
            let expectBounds = CGRect(origin: CGPoint.zero, size: self.containerSizeWithOrientation(orientation: expectOrientation))
            imageBrowser!.collectionView.layout.itemSize = expectBounds.size
            
            // Reset to prevent the page number change after transforming.
            imageBrowser!.collectionView.scrolltoPage(page: recordPage)
            
            currentOrientation = expectOrientation
            rotating = false
            
            orientationDidChanged(orientation: expectOrientation, centerCell: centerCell)
        }
    }
    
    // MARK: - private
    private func supportedOf(_ orientation: UIInterfaceOrientation) -> Bool {
        if !KWIBValidDeviceOrientation(orientation) {
            return false
        }
        var set: Set<AnyHashable> = []
        if supportedOrientations.rawValue & UIInterfaceOrientationMask.portrait.rawValue != 0 {
            _ = set.insert(NSNumber(value: UIInterfaceOrientation.portrait.rawValue))
        }
        if supportedOrientations.rawValue & UIInterfaceOrientationMask.portraitUpsideDown.rawValue != 0 {
            _ = set.insert(NSNumber(value: UIInterfaceOrientation.portraitUpsideDown.rawValue))
        }
        if supportedOrientations.rawValue & UIInterfaceOrientationMask.landscapeRight.rawValue != 0 {
            _ = set.insert(NSNumber(value: UIInterfaceOrientation.landscapeLeft.rawValue))
        }
        if supportedOrientations.rawValue & UIInterfaceOrientationMask.landscapeLeft.rawValue != 0 {
            _ = set.insert(NSNumber(value: UIInterfaceOrientation.landscapeRight.rawValue))
        }
        return set.contains(NSNumber(value: orientation.rawValue))
    }
    
    private func orientationWillChange(orientation: UIInterfaceOrientation, centerCell: KWIBBaseCollectionCell) {
        if imageBrowser == nil { return }
        centerCell.kw_orientationWillChange(expectOrientation: orientation)
        for handler in imageBrowser!.toolViewHandlers {
            handler.kw_orientationWillChange?(expectOrientation: orientation)
        }
    }
    
    private func orientationChangeAnimation(orientation: UIInterfaceOrientation, centerCell: KWIBBaseCollectionCell) {
        if imageBrowser == nil { return }
        centerCell.kw_orientationChangeAnimation(expectOrientation: orientation)
        for handler in imageBrowser!.toolViewHandlers {
            handler.kw_orientationChangeAnimation?(expectOrientation: orientation)
        }
    }
    
    private func orientationDidChanged(orientation: UIInterfaceOrientation, centerCell: KWIBBaseCollectionCell) {
        if imageBrowser == nil { return }
        centerCell.kw_orientationDidChanged(expectOrientation: orientation)
        for handler in imageBrowser!.toolViewHandlers {
            handler.kw_orientationDidChanged?(expectOrientation: orientation)
        }
    }
}
