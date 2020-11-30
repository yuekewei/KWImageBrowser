//
//  KWIBBaseCollectionCell.swift
//  KWImageBrowser
//
//  Created by yuekewei on 2020/11/18.
//

import Foundation
import UIKit

class KWIBBaseCollectionCell: UICollectionViewCell {
    weak var imageBrowser : KWImageBrowser?
    
    var cellData: KWIBDataProtocol?
    
    var page: Int = 0
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    /// 获取前景视图，出入场时需要用这个返回值做动效
    /// - Returns: 前景视图
    func kw_foregroundView() -> UIView? {
        return nil;
    }

    /// 页码变化了
    func kw_pageChanged() {
        
    }
}


extension KWIBBaseCollectionCell: KWIBOrientationProtocol {
    func kw_orientationWillChange(expectOrientation: UIInterfaceOrientation) {
        
    }
    
    func kw_orientationChangeAnimation(expectOrientation: UIInterfaceOrientation) {
        
    }
    
    func kw_orientationDidChanged(expectOrientation: UIInterfaceOrientation) {
        
    }
}
