//
//  KWIBDataProtocol.swift
//  KWImageBrowser
//
//  Created by yuekewei on 2020/11/18.
//

import Foundation
import UIKit

@objc protocol KWIBDataProtocol: NSObjectProtocol {
    weak var imageBrowser: KWImageBrowser? { get set }
    
    var page: Int { get set }
    
    /// 手势交互动效配置文件
    var interactionProfile: KWIBInteractionConfig { get set }
    
    /// 获取投影视图，当前数据模型对应外界业务的 UIView (通常为 UIImageView)，做转场动效用
    /// 这个方法会在做出入场动效时调用，若未实现时将无法进行平滑的入场
    /// - Returns: 投影视图
    @objc optional func kw_projectiveView() -> UIView?
    
    /// 通过一系列数据，计算并返回图片视图在容器中的 frame
    /// 这个方法会在做入场动效时调用，若未实现时将无法进行平滑的入场
    /// - Parameters:
    ///   - containerSize: 容器大小
    ///   - imageSize: 图片大小 (逻辑像素)
    ///   - orientation: 图片浏览器的方向
    /// - Returns: 计算好的 frame
    @objc optional func kw_imageViewFrame(withContainerSize containerSize: CGSize, imageSize: CGSize, orientation: UIInterfaceOrientation) -> CGRect
    
    /// 预加载数据，有效的预加载能提高性能，请注意管理内存
    @objc optional func kw_preload()
    
    /// 保存到相册
    @objc optional func kw_saveToPhotoAlbum()
    
    /// 是否允许保存到相册
    @objc func kw_allowSaveToPhotoAlbum() -> Bool
    
    /// 返回index对应的cell
    /// - Parameters:
    ///   - imageBrowser: KWImageBrowser
    ///   - index: 目标index
    @objc func kw_imageBrowser(_ imageBrowser: KWImageBrowser, cellForItemAt index: Int) -> KWIBBaseCollectionCell
    
    /// 注册cell class
    /// - Parameter imageBrowser: KWImageBrowser
    @objc func registerCellClass(_ imageBrowser: KWImageBrowser)
}
