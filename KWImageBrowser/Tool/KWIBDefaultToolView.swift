//
//  KWIBDefaultToolView.swift
//  KWImageBrowser
//
//  Created by yuekewei on 2020/11/18.
//

import Foundation
import UIKit

@objc protocol KWIBToolViewProtocol: KWIBOrientationProtocol {
    weak var kw_imageBrowser: KWImageBrowser? { get set }
    /// 容器视图准备好了，可进行子视图的添加和布局
    func kw_containerViewIsReadied()
    /// 隐藏视图
    /// - Parameter hide: 是否隐藏
    func kw_hide(_ hide: Bool)
    
    /// 页码变化了
    @objc optional func kw_pageChanged()
    /// 偏移量变化了
    /// - Parameter offsetX: 当前偏移量
    @objc optional func kw_offsetXChanged(_ offsetX: CGFloat)
    /// 响应长按手势
    @objc optional func kw_respondsToLongPress()
}

class KWIBDefaultToolView: NSObject, KWIBToolViewProtocol {
    var sheet: UIAlertController?
    var kw_imageBrowser: KWImageBrowser?
    
    // 顶部显示页码视图
    lazy var topView: KWIBTopView = {
        var topView = KWIBTopView()
        topView.operationType = .more
        
        topView.clickOperation = {  type in
            if self.kw_imageBrowser == nil {return}
            switch type {
            case .save:
                var data = self.kw_imageBrowser!.browserViewModel.dataForCell(at: self.kw_imageBrowser!.currentPage)
                data?.kw_saveToPhotoAlbum?()
            case .more:
                self.showSheetView()
            }
        }
        return topView
    }()
    
    // MARK: - KWIBOrientationProtocol
    func kw_containerViewIsReadied() {
        if kw_imageBrowser == nil {return}
        kw_imageBrowser?.containerView.addSubview(topView)
        layout(withExpect: kw_imageBrowser!.rotationObserver.currentOrientation)
    }
    
    func kw_pageChanged() {
        if kw_imageBrowser == nil {return}
        if topView.operationType == .save {
            topView.operationButton.isHidden = currentDataShouldHideSaveButton()
        }
        topView.setPage(kw_imageBrowser!.currentPage, totalPage: kw_imageBrowser!.browserViewModel.numberOfCells)
    }
    
    func kw_respondsToLongPress() {
        showSheetView()
    }
    
    func kw_hide(_ hide: Bool) {
        topView.isHidden = hide
        
        sheet?.dismiss(animated: false)
    }
    
    
    // MARK: - KWIBOrientationProtocol
    func kw_orientationWillChange(expectOrientation orientation: UIInterfaceOrientation) {
        sheet?.dismiss(animated: false)
    }
    
    func kw_orientationChangeAnimation(expectOrientation orientation: UIInterfaceOrientation) {
        layout(withExpect: orientation)
    }
    
    
    // MARK: - private
    func currentDataShouldHideSaveButton() -> Bool {
        if kw_imageBrowser == nil { return false}
        let data: KWIBDataProtocol? = kw_imageBrowser!.browserViewModel.dataForCell(at: kw_imageBrowser!.currentPage)
        let allow: Bool =  data?.kw_allowSaveToPhotoAlbum() ?? false
        let can: Bool = ((data?.kw_saveToPhotoAlbum) != nil)
        return !(allow && can)
    }
    
    func layout(withExpect orientation: UIInterfaceOrientation) {
        if kw_imageBrowser == nil {
            return 
        }
        
        let containerSize = kw_imageBrowser!.rotationObserver.containerSizeWithOrientation(orientation: orientation)
        let padding = KWIBPaddingByBrowserOrientation(orientation)
        
        topView.frame = CGRect(x: padding.left, y: padding.top, width: containerSize.width - padding.left - padding.right, height: KWIBTopView.defaultHeight())
    }
    
    func showSheetView() {
        if kw_imageBrowser == nil { return }
        
        if !currentDataShouldHideSaveButton() {
            sheet = {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet)
                alert.addAction(UIAlertAction(title: "保存到相册", style: .default, handler: { [self] action in
                    var data = kw_imageBrowser!.browserViewModel.dataForCell(at: kw_imageBrowser!.currentPage)
                    data?.kw_saveToPhotoAlbum?()
                }))
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                return alert
            }()
            topmostViewController()?.present(sheet!, animated: true)
        }
    }
    
}
