//
//  KWIBImageScrollView.swift
//  KWImageBrowser
//
//  Created by yuekewei on 2020/11/18.
//

import Foundation
import UIKit

enum KWIBScrollImageType : Int {
    case none
    case original
    case thumb
}

class KWIBImageScrollView: UIScrollView {
    
    var cellData: KWIBImageData? {
        didSet {
            if cellData == nil { return }
            if  let img = cellData?.createImageContainerBlock?() {
                imageView = img
            }
            thumbimageView.isHidden = !(cellData!.progressiveLoad)
        }
    }
    
    var thumbimageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    var largeimageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    
    var imageView: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    weak var currentImageView: UIImageView?
    
    
    var imageType: KWIBScrollImageType = .none
    
    // MARK: - life cycle
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        decelerationRate = .fast
        maximumZoomScale = 3
        minimumZoomScale = 1
        alwaysBounceHorizontal = false
        alwaysBounceVertical = false
        layer.masksToBounds = false
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
        addSubview(thumbimageView)
        addSubview(imageView)
        
        
        currentImageView = thumbimageView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //    override func layoutSubviews() {
    //        super.layoutSubviews()
    //
    //        thumbimageView.frame = bounds
    //        imageView.frame = bounds
    //    }
    
    // MARK: - public
    func setImage(_ image: UIImage?, type: KWIBScrollImageType) {
        imageType = type
        
        if  !thumbimageView.isHidden && type == .thumb {
            thumbimageView.image = image
        }
        else {
            imageView.image = image
        }
        
        imageType = type
    }
    
    func layoutImageFrame(frame: CGRect) {
        self.imageView.frame = frame;
        self.thumbimageView.frame = frame;
    }
    
    func reset() {
        zoomScale = 1
        thumbimageView.image = nil
        thumbimageView.frame = CGRect.zero
        imageView.image = nil
        imageView.frame = CGRect.zero
        imageType = KWIBScrollImageType.none
    } 
}
