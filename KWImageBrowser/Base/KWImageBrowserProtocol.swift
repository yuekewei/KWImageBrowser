//
//  KWImageBrowserProtocol.swift
//  KWImageBrowser
//
//  Created by yuekewei on 2020/11/18.
//

import UIKit

typealias KWIBWebImageProgressBlock = ((_ receivedSize: Float, _ totalSize: Float) -> Void)

typealias KWIBWebImageCompletedBlock = (_ image: UIImage?, _ data: Data?, _ error: Error?, _ finished: Bool) -> Void

@objc protocol KWImageBrowserProtocol: NSObjectProtocol {
    
    /// 显示状态栏
    /// @param imageBrowser KWImageBrowser
    @objc optional func kw_showStatusBar(imageBrowser: KWImageBrowser)
    
    /// 隐藏状态栏
    /// @param imageBrowser KWImageBrowser
    @objc optional func kw_hideStatusBar(imageBrowser: KWImageBrowser)
    
    /// 页码变化
    /// - Parameters:
    ///   - imageBrowser: 图片浏览器
    ///   - page: 当前页码
    ///   - data: 数据
    @objc optional func kw_imageBrowserPageChanged(imageBrowser: KWImageBrowser,
                                                   page: Int,
                                                   data: KWIBDataProtocol?)
    
    /// 响应长按手势（若实现该方法将阻止其它地方捕获到长按事件）
    /// - Parameters:
    ///   - imageBrowser: 图片浏览器
    ///   - data: 数据
    @objc optional func kw_imageBrowserRespondsToLongPress(imageBrowser: KWImageBrowser,
                                                           data: KWIBDataProtocol)
    
    /// 加载缩略图
    /// @param index 图片索引
    /// @param progress 进度回调
    /// @param completedBlock 完成回调
    @objc optional func kw_loadThumbImage(
        index: Int,
        progress: KWIBWebImageProgressBlock?,
        completed completedBlock: KWIBWebImageCompletedBlock?
    )
    
    /// 加载大图
    /// @param index 图片索引
    /// @param progress 进度回调
    /// @param completedBlock 完成回调
    @objc optional func kw_loadLargeImage(
        index: Int,
        progress: KWIBWebImageProgressBlock?,
        completed completedBlock: KWIBWebImageCompletedBlock?
    )
    
    /// 取消下载
    /// @param index 图片索引
    @objc optional func kw_cancelLoadImage(index: Int)
    
    /// 开始转场
    /// - Parameters:
    ///   - imageBrowser: 图片浏览器
    ///   - isShow: YES 表示入场，NO 表示出场
    @objc optional func  kw_imageBrowserBeginTransitioning( imageBrowser: KWImageBrowser, isShow: Bool)
    
    /// 结束转场
    /// - Parameters:
    ///   - imageBrowser: 图片浏览器
    ///   - isShow: YES 表示入场，NO 表示出场
    @objc optional func  kw_imageBrowserEndTransitioning( imageBrowser: KWImageBrowser, isShow: Bool)
}

