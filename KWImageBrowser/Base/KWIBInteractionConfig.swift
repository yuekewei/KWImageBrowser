//
//  KWIBInteractionConfig.swift
//  KWImageBrowser
//
//  Created by yuekewei on 2020/11/18.
//

import Foundation
import UIKit

class KWIBInteractionConfig: NSObject {
    /// 是否取消手势交互动效
    var disable = false
    
    /// 拖动的距离与最大高度的比例，达到这个比例就会出场
    var dismissScale: CGFloat = 0.22
    
    /// 拖动的速度，达到这个值就会出场
    var dismissVelocityY: CGFloat = 800
    
    /// 拖动动效复位时的时长
    var restoreDuration: CGFloat = 0.15
    
    /// 拖动触发手势交互动效的起始距离
    var triggerDistance: CGFloat = 3
}
