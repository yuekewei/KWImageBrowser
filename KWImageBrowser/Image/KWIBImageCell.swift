//
//  KWIBImageCell.swift
//  KWImageBrowser
//
//  Created by yuekewei on 2020/11/18.
//

import Foundation
import UIKit

class KWIBImageCell: KWIBBaseCollectionCell {
    
    var interacting: Bool = false
    var interactStartPoint = CGPoint.zero
    var tostContainerView: UIView = UIView()
    var imageData: KWIBImageData?
    override var cellData: KWIBDataProtocol? {
        didSet {
            self.imageScrollView.cellData = cellData as? KWIBImageData
            imageData = cellData as? KWIBImageData
            imageData?.delegate = self
        }
    }
    
    lazy var imageScrollView: KWIBImageScrollView = {
        var scrollView: KWIBImageScrollView = KWIBImageScrollView()
        scrollView.delegate = self
        return scrollView
    }()
    
    // MARK: -
    // MARK: - life
    override init(frame: CGRect) {
        super.init(frame: frame)
        tostContainerView.isUserInteractionEnabled = false
        contentView.addSubview(imageScrollView)
        addSubview(tostContainerView)
        addGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - override
    override func layoutSubviews() {
        super.layoutSubviews()
        
        tostContainerView.frame = bounds
        imageScrollView.frame = bounds
    }
    
    override func prepareForReuse() {
        
        if let data: KWIBImageData = cellData as? KWIBImageData {
            data.delegate = nil
        }
        imageScrollView.reset()
        hideAuxiliaryView()
        super.prepareForReuse()
    }
    
    override func kw_foregroundView() -> UIView? {
        return imageScrollView.imageView;
    }
    
    override func kw_orientationWillChange(expectOrientation: UIInterfaceOrientation) {
        
    }
    
    override func kw_orientationChangeAnimation(expectOrientation: UIInterfaceOrientation) {
        self.updateImageLayout(with: expectOrientation, previousImageSize: self.imageScrollView.imageView.image!.size)
    }
    
    override func kw_orientationDidChanged(expectOrientation: UIInterfaceOrientation) {
        
    }
    
    // MARK: - public
    
    func hideAuxiliaryView()  {
        self.imageBrowser?.auxiliaryViewHandler.kw_hideToast(withContainer: self)
        self.imageBrowser?.auxiliaryViewHandler.kw_hideLoading(withContainer: self)
    }
    
    // MARK: - private
    func contentSize(withContainerSize containerSize: CGSize, imageViewFrame: CGRect) -> CGSize {
        return CGSize(width: CGFloat(max(containerSize.width, imageViewFrame.size.width)), height: CGFloat(max(containerSize.height, imageViewFrame.size.height)))
    }
    
    func updateImageLayout(with orientation: UIInterfaceOrientation, previousImageSize: CGSize) {
        if interacting || imageBrowser == nil {
            return
        }
        
        let data:KWIBImageData = cellData as! KWIBImageData
        
        
        var imageSize: CGSize
        
        let image = imageScrollView.imageView.image
        let imageType: KWIBScrollImageType = imageScrollView.imageType
        imageSize = image?.size ?? CGSize.zero
        
        let containerSize = self.imageBrowser!.rotationObserver.containerSizeWithOrientation(orientation: orientation)
        let imageViewFrame = data.layout.kw_imageViewFrame(withContainerSize: self.imageBrowser!.rotationObserver.containerSizeWithOrientation(orientation: orientation), imageSize: imageSize, orientation: orientation)
        let contentSize = self.contentSize(withContainerSize: containerSize, imageViewFrame: imageViewFrame)
        let maxZoomScale: CGFloat = (imageType == .thumb ? 1.0 : data.layout.kw_maximumZoomScale(withContainerSize: containerSize, imageSize: imageSize, orientation: orientation))
        // 'zoomScale' must set before 'contentSize' and 'imageView.frame'.
        imageScrollView.zoomScale = 1
        imageScrollView.contentSize = contentSize
        imageScrollView.minimumZoomScale = 1
        imageScrollView.maximumZoomScale = maxZoomScale
        
        var scale: CGFloat
        if previousImageSize.width > 0 && previousImageSize.height > 0 {
            scale = imageSize.width / imageSize.height - previousImageSize.width / previousImageSize.height
        } else {
            scale = 0
        }
        
        // '0.001' is admissible error.
        if Double(abs(scale)) <= 0.001 {
            imageScrollView.imageView.frame = imageViewFrame
        } else {
            UIView.animate(withDuration: 0.25, animations: {
                self.imageScrollView.imageView.frame = imageViewFrame
            })
        }
    }
    
    func hideBrowser() {
        imageData?.delegate = nil
        hideAuxiliaryView()
        imageBrowser?.hide()
        interacting = false
    }
}

// MARK: - KWIBImageDataDelegate
extension KWIBImageCell:KWIBImageDataDelegate {
    func kw_imageData(_ data: KWIBImageData?, status: KWIBImageLoadingStatus) {
        switch status {
        case .none:
            hideAuxiliaryView()
        default:
            self.imageBrowser?.auxiliaryViewHandler.kw_showLoading(withContainer: tostContainerView)
        }
    }
    
    func kw_imageDataDownloadProgress(_ data: KWIBImageData?, progress: CGFloat) {
        imageBrowser?.auxiliaryViewHandler.kw_showLoading(withContainer: tostContainerView, progress: progress)
    }
    
    func kw_imageIsInvalid(for data: KWIBImageData?) {
        hideAuxiliaryView()
        
        let imageIsInvalid = "图片无效"
        if imageScrollView.imageView.image != nil {
            imageBrowser?.auxiliaryViewHandler.kw_showIncorrectToast(withContainer: tostContainerView, text: imageIsInvalid)
        }
        else {
            imageBrowser?.auxiliaryViewHandler.kw_showLoading(withContainer: tostContainerView, text: imageIsInvalid)
        }
    }
    
    func kw_imageDownloadFailed(data: KWIBImageData?) {
        if imageScrollView.imageView.image != nil {
            imageBrowser?.auxiliaryViewHandler.kw_hideLoading(withContainer: tostContainerView)
            imageBrowser?.auxiliaryViewHandler.kw_showIncorrectToast(withContainer: tostContainerView, text: "加载图片失败")
        }
        else {
            imageBrowser?.auxiliaryViewHandler.kw_showLoading(withContainer: tostContainerView, text: "加载图片失败")
        }
    }
    
    func kw_imageDataOriginImage(_ data: KWIBImageData?, originImage: UIImage) {
        if imageBrowser == nil { return }
        if imageData?.loadingStatus != .originLoading {
            self.imageBrowser?.auxiliaryViewHandler.kw_hideLoading(withContainer: tostContainerView)
        }        
        self.imageScrollView.setImage(originImage, type: .original)
        self.updateImageLayout(with: imageBrowser!.currentOrientation, previousImageSize: originImage.size)
    }
    
    func kw_imageDataThumbImage(_ data: KWIBImageData?, thumbImage: UIImage) {
        if imageBrowser == nil { return }
        if imageData?.loadingStatus != .originLoading {
            self.imageBrowser?.auxiliaryViewHandler.kw_hideLoading(withContainer: tostContainerView)
        }
        self.imageScrollView.setImage(thumbImage, type: .thumb)
        self.updateImageLayout(with: imageBrowser!.currentOrientation, previousImageSize: thumbImage.size)
    }
}

// MARK: - UIGestureRecognizer
extension KWIBImageCell {
    
    func addGesture() {
        
        let tapSingle = UITapGestureRecognizer(target: self, action: #selector(respondsTapSingle(tap:)))
        tapSingle.numberOfTapsRequired = 1
        let tapDouble = UITapGestureRecognizer(target: self, action: #selector(respondsTapDouble(toTapDouble:)))
        tapDouble.numberOfTapsRequired = 2
        let pan = UIPanGestureRecognizer(target: self, action: #selector(respondsPanGesture(pan:)))
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        
        tapSingle.require(toFail: tapDouble)
        tapSingle.require(toFail: pan)
        tapDouble.require(toFail: pan)
        
        addGestureRecognizer(tapSingle)
        addGestureRecognizer(tapDouble)
        addGestureRecognizer(pan)
    }
    
    @objc func respondsTapSingle(tap: UITapGestureRecognizer?) {
        if imageBrowser == nil ||
            imageBrowser!.rotationObserver.rotating {
            return
        }
        
        if  imageData?.singleTouchBlock?(imageData) == nil {
            hideAuxiliaryView()
            imageBrowser?.hide()
        }
    }
    
    @objc func respondsTapDouble(toTapDouble tap: UITapGestureRecognizer?) {
        if imageBrowser == nil ||
            imageBrowser!.rotationObserver.rotating {
            return
        }
        let zoomView: UIView? = self.viewForZooming(in: imageScrollView)
        
        let point = tap?.location(in: zoomView)
        if !(zoomView?.bounds.contains(point ?? CGPoint.zero) ?? false) {
            return
        }
        if imageScrollView.zoomScale == imageScrollView.maximumZoomScale {
            imageScrollView.setZoomScale(1, animated: true)
        } else {
            imageScrollView.zoom(to: CGRect(x: point?.x ?? 0.0, y: point?.y ?? 0.0, width: 1, height: 1), animated: true)
        }
    }
    
    @objc func respondsPanGesture( pan: UIPanGestureRecognizer) {
        
        let interactionConfig:KWIBInteractionConfig = cellData?.interactionProfile ?? KWIBInteractionConfig()
        if imageBrowser == nil ||
            interactionConfig.disable ||
            imageScrollView.imageView.frame.isEmpty ||
            imageScrollView.imageView.image == nil {
            return
        }
        
        let point = pan.location(in: self)
        let containerSize = self.frame.size
        
        if pan.state == .began {
            interactStartPoint = point
        }
        else if pan.state == .cancelled ||
                    pan.state == .ended ||
                    pan.state == .recognized ||
                    pan.state == .failed {
            
            // End.
            if interacting {
                let velocity = pan.velocity(in: imageScrollView)
                
                let velocityArrive = abs(velocity.y) > interactionConfig.dismissVelocityY
                let distanceArrive = abs(point.y - interactStartPoint.y) > (containerSize.height * interactionConfig.dismissScale)
                
                let shouldDismiss = distanceArrive || velocityArrive
                if shouldDismiss {
                    hideBrowser()
                }
                else {
                    restoreInteraction(withDuration: TimeInterval(interactionConfig.restoreDuration))
                    tostContainerView.isHidden = false
                }
            }
        }
        else if pan.state == .changed {
            if interacting {
                
                // Change.
                imageScrollView.center = point
                var scale: CGFloat = 1 - abs(point.y - interactStartPoint.y) / (containerSize.height * 1.2)
                scale = CGFloat(min(scale, 1))
                scale = CGFloat(max(scale, 0.35))
                imageScrollView.transform = CGAffineTransform(scaleX: scale, y: scale)
                
                var alpha: CGFloat = 1 - abs(point.y - interactStartPoint.y) / (containerSize.height * 0.7)
                alpha = CGFloat(min(alpha, 1))
                alpha = CGFloat(max(alpha, 0))
                imageBrowser?.backgroundColor = imageBrowser?.containerView.backgroundColor?.withAlphaComponent(alpha)
            }
            else {
                if interactStartPoint.equalTo(CGPoint.zero) ||
                    imageBrowser?.currentPage != page ||
                    !imageBrowser!.cellIsInCenter() ||
                    imageScrollView.isZooming {
                    return
                }
                
                let velocity = pan.velocity(in: imageScrollView)
                let triggerDistance = interactionConfig.triggerDistance
                let offsetY = imageScrollView.contentOffset.y
                let height = imageScrollView.bounds.size.height
                
                let distanceArrive = CGFloat(abs(point.x - interactStartPoint.x)) < triggerDistance && Int(abs(velocity.x)) < 500
                let upArrive = point.y - interactStartPoint.y > triggerDistance && offsetY <= 1
                let downArrive = (point.y - interactStartPoint.y) < -triggerDistance && (offsetY + height ) >= (max(imageScrollView.contentSize.height, height) - 1)
                
                let shouldStart = (upArrive || downArrive) && distanceArrive
                if !shouldStart {
                    return
                }
                
                interactStartPoint = point
                
                let startFrame = imageScrollView.frame
                let anchorX = point.x / startFrame.size.width
                let anchorY = point.y / startFrame.size.height
                imageScrollView.layer.anchorPoint = CGPoint(x: anchorX, y: anchorY)
                imageScrollView.isUserInteractionEnabled = false
                imageScrollView.isScrollEnabled = false
                imageScrollView.center = point
                
                imageBrowser?.hideStatusBar()
                imageBrowser?.showStatusBar()
                imageBrowser?.collectionView.isScrollEnabled = false
                tostContainerView.isHidden = true
                imageBrowser?.hideToolViews(true)
                
                interacting = true
            }
        }
    }
    
    func restoreInteraction(withDuration duration: TimeInterval) {
        let containerSize = self.frame.size
        
        let animations: (() -> Void) = {
            self.imageBrowser?.backgroundColor = self.imageBrowser?.backgroundColor?.withAlphaComponent(1.0)
            
            let anchorPoint = self.imageScrollView.layer.anchorPoint
            self.imageScrollView.center = CGPoint(x: containerSize.width * anchorPoint.x, y: containerSize.height * anchorPoint.y)
            self.imageScrollView.transform = CGAffineTransform.identity
        }
        let completion: ((_ finished: Bool) -> Void) = { finished in
            self.imageScrollView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            self.imageScrollView.center = CGPoint(x: containerSize.width * 0.5, y: containerSize.height * 0.5)
            self.imageScrollView.isUserInteractionEnabled = true
            self.imageScrollView.isScrollEnabled = true
            
            self.imageBrowser?.hideToolViews(false)
            self.imageBrowser?.hideStatusBar()
            self.imageBrowser?.collectionView.isScrollEnabled = true
            
            
            self.interactStartPoint = CGPoint.zero
            self.interacting = false
        }
        
        if duration <= 0 {
            animations()
            completion(false)
        } else {
            UIView.animate(withDuration: duration, animations: animations, completion: completion)
        }
    }
    
}

// MARK: - <UIScrollViewDelegate>
extension KWIBImageCell: UIScrollViewDelegate {
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageData?.imageDidZoomBlock?(imageData,scrollView)
        var imageViewFrame = imageScrollView.imageView.frame
        let width = imageViewFrame.size.width
        let height = imageViewFrame.size.height
        let sHeight = scrollView.bounds.size.height
        let sWidth = scrollView.bounds.size.width
        if height > sHeight {
            imageViewFrame.origin.y = 0
        } else {
            imageViewFrame.origin.y = (sHeight - height) / 2.0
        }
        if width > sWidth {
            imageViewFrame.origin.x = 0
        } else {
            imageViewFrame.origin.x = (sWidth - width) / 2.0
        }
        imageScrollView.imageView.frame = imageViewFrame
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageScrollView.imageView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        imageData?.imageDidScrollBlock?(imageData,scrollView)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension KWIBImageCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
