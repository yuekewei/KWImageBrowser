//
//  KWIBUtilities.swift
//  KWImageBrowser
//
//  Created by yuekewei on 2020/11/18.
//

import UIKit
import Photos

 func topmostViewController() -> UIViewController? {

    var topViewController = UIApplication.shared.keyWindow?.rootViewController
    if topViewController == nil {
        return nil
    }

    while true {
        if topViewController?.presentedViewController != nil {
            topViewController = topViewController?.presentedViewController
        } else if topViewController is UINavigationController {
            let navi = topViewController as? UINavigationController
            topViewController = navi?.topViewController
        } else if topViewController is UITabBarController {
            let tab = topViewController as? UITabBarController
            topViewController = tab?.selectedViewController
        } else {
            break
        }
    }

    return topViewController
}

func KWIBIsIphoneXSeries() -> Bool {
    return KWIBStatusbarHeight() > 20
}


func KWIBStatusbarHeight() -> CGFloat {
    var height: CGFloat = 0
    if #available(iOS 11.0, *) {
        height = UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0.0
    }
    if height <= 0 {
        height = UIApplication.shared.statusBarFrame.size.height
    }
    if height <= 0 {
        height = 20
    }
    return height
}


func KWIBSafeAreaBottomHeight() -> CGFloat {
    var bottom: CGFloat = 0
    if #available(iOS 11.0, *) {
        bottom = UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0.0
    }
    return bottom
}

func KWIBPaddingByBrowserOrientation(_ orientation: UIInterfaceOrientation) -> UIEdgeInsets {
    var padding: UIEdgeInsets = .zero
    if !KWIBIsIphoneXSeries() {
        return padding
    }

    let barOrientation: UIInterfaceOrientation = UIInterfaceOrientation.init(rawValue: UIApplication.shared.statusBarOrientation.rawValue) ?? .unknown

    if orientation.isLandscape {
        let same = orientation == barOrientation
        let reverse = !same && barOrientation.isLandscape
        if same {
            padding.bottom = KWIBSafeAreaBottomHeight()
            padding.top = 0
        } else if reverse {
            padding.top = KWIBSafeAreaBottomHeight()
            padding.bottom = 0
        }
        padding.right = CGFloat(max(KWIBSafeAreaBottomHeight(), KWIBStatusbarHeight()))
        padding.left = padding.right
    } else {
        if orientation == .portrait {
            padding.top = KWIBStatusbarHeight()
            padding.bottom = barOrientation == .portrait ? KWIBSafeAreaBottomHeight() : 0
        } else {
            padding.bottom = KWIBStatusbarHeight()
            padding.top = barOrientation == .portrait ? KWIBSafeAreaBottomHeight() : 0
        }
        padding.right = barOrientation.isLandscape  ? KWIBSafeAreaBottomHeight() : 0
        padding.left = padding.right
        
    }
    return padding
}

func kw_imageBundle() -> Bundle {
    var imgaeBundle: Bundle?
    if let bundlePath: String = Bundle.main.path(forResource: "KWImageBrowser", ofType: "bundle") {
        imgaeBundle = Bundle.init(path: bundlePath)
    }
    else {
        let bundle = Bundle(for: KWImageBrowser.self)
        let url = bundle.url(forResource: "TZImagePickerController", withExtension: "bundle")
        if let url = url, let bundle1 = Bundle(url: url) {
            imgaeBundle = bundle1
        }
    }
    return imgaeBundle ?? Bundle.main;
}

func kwib_SnapshotView(_ view: UIView) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, UIScreen.main.scale)
    view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}

func kw_isLowMemory() -> Bool {
    let physicalMemory = ProcessInfo.processInfo.physicalMemory
    let lowMemory = physicalMemory > 0 && physicalMemory < 1024 * 1024 * 1500
    return lowMemory
}

class KWIBUtilities: NSObject {

    /// 相册授权
    /// @param completion 授权回调
    class func authorizationforPhotoLibrary(completion: @escaping (_ granted: Bool) -> Void) {

        let authStatus = PHPhotoLibrary.authorizationStatus()
        if authStatus == .notDetermined {
            DispatchQueue.global(qos: .default).async(execute: {
                PHPhotoLibrary.requestAuthorization({ status in
                    DispatchQueue.main.async(execute: {
                        completion(status == .authorized)
                    })
                })
            })
        } else if authStatus == .restricted || authStatus == .denied {
            DispatchQueue.main.async {
                let alertVc = UIAlertController(title: "无法访问相册", message: """
                    请在iPhone的\
                    设置-隐私-相册\
                    中允许访问相册
                    """, preferredStyle: .alert)
                alertVc.addAction(UIAlertAction(title: "设置", style: .default, handler: { action in

                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.openURL(url)
                    }
                }))
                alertVc.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                topmostViewController()?.present(alertVc, animated: true)

                completion(false)
            }
            
        }
        else {
            completion(true)
        }
    }
}
