//
//  KWIBHud.swift
//  KWImageBrowser
//
//  Created by yuekewei on 2020/11/19.
//

import Foundation
import UIKit

protocol KWIBHudProtocol {
    /// 展示正确情况的提示
    func kw_showCorrectToast(withContainer container: UIView?, text: String?)
    /// 展示错误情况的提示
    func kw_showIncorrectToast(withContainer container: UIView?, text: String?)
    /// 隐藏所有提示
    func kw_hideToast(withContainer container: UIView?)
    /// 展示加载视图
    func kw_showLoading(withContainer container: UIView?)
    /// 展示带进度的加载视图
    func kw_showLoading(withContainer container: UIView?, progress: CGFloat)
    /// 展示带文字的视图
    func kw_showLoading(withContainer container: UIView?, text: String?)
    /// 隐藏所有视图
    func kw_hideLoading(withContainer container: UIView?)
}


class KWIBHud: KWIBHudProtocol {
// MARK: - <KWIBAuxiliaryViewHandler>
    func kw_showCorrectToast(withContainer container: UIView?, text: String?) {
        container?.kwib_showHookToast(text)
    }

    func kw_showIncorrectToast(withContainer container: UIView?, text: String?) {
        container?.kwib_showForkToast(text)
    }

    func kw_hideToast(withContainer container: UIView?) {
        container?.kwib_hideToast()
    }

    func kw_showLoading(withContainer container: UIView?) {
        container?.kwib_showLoading()
    }

    func kw_showLoading(withContainer container: UIView?, progress: CGFloat) {
        container?.kwib_showLoading(withProgress: progress)
    }

    func kw_showLoading(withContainer container: UIView?, text: String?) {
        container?.kwib_showLoading(withText: text, click: nil)
    }

    func kw_hideLoading(withContainer container: UIView?) {
        container?.kwib_hideLoading()
    }
}
