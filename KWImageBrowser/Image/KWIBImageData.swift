//
//  KWIBImageData.swift
//  KWImageBrowser
//
//  Created by yuekewei on 2020/11/18.
//

import Foundation
import UIKit
import Photos

enum KWIBImageLoadingStatus : Int {
    case none
    case thumbLoading
    case originLoading
}

protocol KWIBImageDataDelegate: NSObjectProtocol {
    func kw_imageData(_ data: KWIBImageData?, status: KWIBImageLoadingStatus)
    func kw_imageIsInvalid(for data: KWIBImageData?)
    func kw_imageDataOriginImage(_ data: KWIBImageData?, originImage: UIImage)
    func kw_imageDataThumbImage(_ data: KWIBImageData?, thumbImage: UIImage)
    func kw_imageDataDownloadProgress(_ data: KWIBImageData?,  progress: CGFloat)
    func kw_imageDownloadFailed(data: KWIBImageData?)
}

class KWIBImageData: NSObject, KWIBDataProtocol {
    
    weak var imageBrowser: KWImageBrowser?
    /// 手势交互动效配置文件
    var interactionProfile: KWIBInteractionConfig = KWIBInteractionConfig()
    var page: Int = 0
    // 原始图片
    var largeImage: UIImage?
    /// 预览图/缩约图，注意若这个图片过大会导致内存压力（若 projectiveView 存在且是 UIImageView 类型将会自动获取缩约图）
    var thumbImage: UIImage?
    /// 投影视图，当前数据模型对应外界业务的 UIView (通常为 UIImageView)，做转场动效用
    weak var projectiveView: UIView?
    
    /// 是否使用渐进式加载，默认 true
    var progressiveLoad: Bool = true
    /// 图片布局类 (赋值可自定义, 可配置其属性)
    var layout: KWIBImageLayoutProtocol = KWIBImageLayout()
    /// 返回图片显示视图
    var createImageContainerBlock: (() -> UIImageView?)?
    /// 是否允许保存到相册
    var allowSaveToPhotoAlbum = true
    
    /// 单击的处理，默认是退出图片浏览器
    var singleTouchBlock: ((_ imageData: KWIBImageData?) -> Void)?
    /// 图片缩放的回调
    var imageDidZoomBlock: ((_ imageData: KWIBImageData?, _ scrollView: UIScrollView) -> Void)?
    /// 图片滚动的回调
    var imageDidScrollBlock: ((_ imageData: KWIBImageData?, _ scrollView: UIScrollView) -> Void)?
    
    var loadingStatus: KWIBImageLoadingStatus = .none {
        didSet {
            delegate?.kw_imageData(self, status: loadingStatus)
        }
    }
    
    private var privateDelegate: KWIBImageDataDelegate?
    var delegate: KWIBImageDataDelegate? {
        set {
            if newValue != nil {                
                self.privateDelegate = newValue
                delegate?.kw_imageData(self, status: loadingStatus)
                self.loadData()
            }
        }
        
        get {
            imageBrowser?.hideTransitioning ?? false ? nil : self.privateDelegate
        }
    }
    
    // MARK: -
    // MARK: - life
    deinit {
        imageBrowser?.delegate?.kw_cancelLoadImage?(index: page)
    }
        
    func loadData() {
        if largeImage == nil {
            loadThumbImage()
        }
        else {
            loadLargeImage()
        }
    }
    
    func loadThumbImage() {
        if (thumbImage != nil) {
            delegate?.kw_imageDataThumbImage(self, thumbImage: thumbImage!)
            loadLargeImage()
        }
        else if projectiveView != nil {
            if  let thumbImage = (projectiveView as? UIImageView)?.image {
                delegate?.kw_imageDataThumbImage(self, thumbImage: thumbImage)
            }
            loadLargeImage()
        }
        else {
            loadLargeImage()
        }
    }
    
    func loadLargeImage() {
        if largeImage == nil {
            if loadingStatus != .originLoading {
                self.downloadLargeImage()
            }
            return
        }
        else {
            delegate?.kw_imageDataOriginImage(self, originImage: largeImage!)
        }
    }
    
    func downloadLargeImage()  {
        loadingStatus = .originLoading
        
        imageBrowser?.delegate?.kw_loadLargeImage?(index: page, progress: { (receivedSize, expectedSize) in
            let p = max(Float(receivedSize) / Float(expectedSize), 0);
            
            DispatchQueue.main.async {               
                self.delegate?.kw_imageDataDownloadProgress(self, progress: CGFloat(p))
            }
            
        }, completed: { (image, data, error, finished) in
            DispatchQueue.main.async {
                if error != nil  {
                    self.loadingStatus = .none
                    self.delegate?.kw_imageDownloadFailed(data: self)
                }
                
                if finished {
                    self.loadingStatus = .none
                }
                
                if image != nil {
                    self.largeImage = image
                    self.loadLargeImage()
                }
            }            
        })
    }
    
    // MARK: - public
    func saveToPhotoAlbumCompleteWithError(_ error: Error?) {
        if error != nil {
            imageBrowser?.auxiliaryViewHandler.kw_showIncorrectToast(withContainer: imageBrowser?.containerView, text: "保存失败")
        } else {
            imageBrowser?.auxiliaryViewHandler.kw_showCorrectToast(withContainer: imageBrowser?.containerView, text: "已保存到系统相册")
        }
    }
    
    @objc func uiImageWriteToSavedPhotosAlbum_completed(with image: UIImage?, error: Error?, context: UnsafeMutableRawPointer?) {
        saveToPhotoAlbumCompleteWithError(error)
    }
}

// MARK: - KWIBDataProtocol
extension KWIBImageData {
    
    
    /// 保存到相册
    func kw_saveToPhotoAlbum() {
        //        let saveData: ((Data?) -> Void) = { [self] data in
        //            ALAssetsLibrary().writeImageData(toSavedPhotosAlbum: data, metadata: nil, completionBlock: { [self] assetURL, error in
        //                saveToPhotoAlbumCompleteWithError(error)
        //            })
        //        }
        
        
        
        let saveImage: ((UIImage) -> Void) = { image in
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(KWIBImageData.uiImageWriteToSavedPhotosAlbum_completed(with:error:context:)), nil)
        }
        
        let unableToSave: (() -> Void) = { [self] in
            imageBrowser?.auxiliaryViewHandler.kw_showIncorrectToast(withContainer: imageBrowser?.containerView, text: "无法保存")
        }
        
        KWIBUtilities.authorizationforPhotoLibrary { (success) in
            if success {
                if (self.largeImage != nil) {
                    saveImage(self.largeImage!)
                }
                else {
                    unableToSave()
                }
            }
        }
    }
    
    func kw_allowSaveToPhotoAlbum() -> Bool {
        return self.allowSaveToPhotoAlbum
    }
    
    func kw_projectiveView() -> UIView? {
        return self.projectiveView
    }
    
    func kw_preload() {
        if delegate == nil {
            loadData()
        }
    }
    
    func registerCellClass(_ imageBrowser: KWImageBrowser) {
        _ = imageBrowser.collectionView.reuseIdentifier(forCellClass: KWIBImageCell.self)
    }
    
    func kw_imageBrowser(_ imageBrowser: KWImageBrowser,
                         cellForItemAt index: Int) -> KWIBBaseCollectionCell {
        let cell = imageBrowser.collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(KWIBImageCell.self), for: IndexPath.init(row: index, section: 0))
        return cell as! KWIBBaseCollectionCell
    }
    
    func kw_imageViewFrame(withContainerSize containerSize: CGSize,
                           imageSize: CGSize,
                           orientation: UIInterfaceOrientation) -> CGRect {
        return layout.kw_imageViewFrame(withContainerSize: containerSize, imageSize: imageSize, orientation: orientation)
    }
    
}
