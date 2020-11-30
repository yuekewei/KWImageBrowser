//
//  KWIBImageLayout.swift
//  KWImageBrowser
//
//  Created by yuekewei on 2020/11/18.
//

import Foundation
import UIKit

enum KWIBImageFillType : Int {
    /// 宽度优先填充满
    case fullWidth
    /// 完整显示
    case completely
}

protocol KWIBImageLayoutProtocol: NSObjectProtocol {
    
    /// 计算图片展示的位置
    /// - Parameters:
    ///   - containerSize: 容器大小
    ///   - imageSize: 图片大小 (逻辑像素)
    ///   - orientation: 图片浏览器的方向
    /// - Returns: 图片展示的位置 (frame)
    func kw_imageViewFrame(withContainerSize containerSize: CGSize, imageSize: CGSize, orientation: UIInterfaceOrientation) -> CGRect
    
    /// 计算最大缩放比例
    /// - Parameters:
    ///   - containerSize: 容器大小
    ///   - imageSize: 图片大小 (逻辑像素)
    ///   - orientation: 图片浏览器的方向
    /// - Returns: 最大缩放比例
    func kw_maximumZoomScale(withContainerSize containerSize: CGSize, imageSize: CGSize, orientation: UIInterfaceOrientation) -> CGFloat
}

class KWIBImageLayout: NSObject {
    
    /// 纵向的填充方式，默认 KWIBImageFillTypeCompletely
    var verticalFillType: KWIBImageFillType = .completely
    /// 横向的填充方式，默认 KWIBImageFillTypeFullWidth
    var horizontalFillType: KWIBImageFillType = .fullWidth
    /// 最大缩放比例 (必须大于 1 才有效，若不指定内部会自动计算)
    var maxZoomScale: CGFloat = 0.0
    /// 自动计算严格缩放比例后，再乘以这个值作为最终缩放比例，默认 1.5
    var zoomScaleSurplus: CGFloat = 1.5
    
    
    // MARK: - private
    func fillType(by orientation: UIInterfaceOrientation) -> KWIBImageFillType {
        return orientation.isLandscape ? horizontalFillType : verticalFillType
    }
    
}

extension KWIBImageLayout: KWIBImageLayoutProtocol {
    func kw_imageViewFrame(withContainerSize containerSize: CGSize,
                           imageSize: CGSize,
                           orientation: UIInterfaceOrientation) -> CGRect {
        if containerSize.width <= 0 ||
            containerSize.height <= 0 ||
            imageSize.width <= 0 ||
            imageSize.height <= 0 {
            return CGRect.zero
        }
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        var width: CGFloat = 0
        var height: CGFloat = 0
        switch fillType(by: orientation) {
        case .fullWidth:
            x = 0
            width = containerSize.width
            height = containerSize.width * (imageSize.height / imageSize.width)
            if imageSize.width / imageSize.height >= containerSize.width / containerSize.height {
                y = (containerSize.height - height) / 2.0
            } else {
                y = 0
            }
        case .completely:
            if imageSize.width / imageSize.height >= containerSize.width / containerSize.height {
                width = containerSize.width
                height = containerSize.width * (imageSize.height / imageSize.width)
                x = 0
                y = (containerSize.height - height) / 2.0
            } else {
                height = containerSize.height
                width = containerSize.height * (imageSize.width / imageSize.height)
                x = (containerSize.width - width) / 2.0
                y = 0
            }
            
        }
        return CGRect.init(x: x, y: y, width: width, height: height)
    }
    
    
    func kw_maximumZoomScale(withContainerSize containerSize: CGSize, imageSize: CGSize, orientation: UIInterfaceOrientation) -> CGFloat {
        if maxZoomScale >= 1 {
            return maxZoomScale
        }
        
        if containerSize.width <= 0 || containerSize.height <= 0 {
            return 0
        }
        
        let scale = UIScreen.main.scale
        if scale <= 0 {
            return 0
        }
        
        let widthScale = imageSize.width / scale / containerSize.width
        let heightScale = imageSize.height / scale / containerSize.height
        var maxScale: CGFloat = 1
        
        switch fillType(by: orientation) {
        case .fullWidth:
            maxScale = widthScale
        case .completely:
            maxScale = CGFloat(max(widthScale, heightScale))
        }
        return max(maxScale, 1) * zoomScaleSurplus
    }
}
