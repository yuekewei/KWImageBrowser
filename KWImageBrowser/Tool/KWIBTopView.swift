//
//  KWIBTopView.swift
//  KWImageBrowser
//
//  Created by yuekewei on 2020/11/18.
//

import UIKit

enum KWIBTopViewOperationType : Int {
    case save //保存
    case more //更多
}

class KWIBTopView: UIView {
    
    /// 点击操作按钮的回调
    var clickOperation: ((_ type: KWIBTopViewOperationType) -> Void)?
    /// 按钮类型
    var operationType: KWIBTopViewOperationType = .save {
        willSet(newValue) {
            var image: UIImage? = nil
            switch newValue {
            case .save:
                image = UIImage.kw_imageNamed("kwib_save")
            case .more:
                image = UIImage.kw_imageNamed("kwib_more")
            }
            
            operationButton.setImage(image, for: .normal)
        }
    }
    
    // 页码标签
    private(set) var pageLabel: UILabel = {
        var label = UILabel.init()
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    /// 操作按钮（自定义：直接修改图片或文字，然后添加点击事件）
    private(set) var operationButton: UIButton = {
        var button = UIButton.init(type: .custom)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(clickOperationButton(_:)), for: .touchUpInside)
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 4
        return button
    }()
    

    // MARK: - life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(pageLabel)
        addSubview(operationButton)
        
        self.operationType = .more
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let height = bounds.size.height
        let width = bounds.size.width
        pageLabel.frame = CGRect(x: 16, y: 0, width: width / 3, height: height)
        
        let buttonWidth: CGFloat = 54
        operationButton.frame = CGRect(x: width - buttonWidth, y: 0, width: buttonWidth, height: height)
    }
    
    // MARK: - public
    
    /// 设置页码
    /// - Parameters:
    ///   - page: 当前页码
    ///   - totalPage: 总页码数
    func setPage(_ page: Int, totalPage: Int) {
        if totalPage <= 1 {
            pageLabel.isHidden = true
        }
        else {
            pageLabel.isHidden = false
            
            let text = String(format: "%ld/%ld", page + Int(1), totalPage)
            let shadow = NSShadow()
            shadow.shadowBlurRadius = 4
            shadow.shadowOffset = CGSize(width: 0, height: 1)
            shadow.shadowColor = UIColor.darkGray
            let attr = NSMutableAttributedString(string: text, attributes: [
                NSAttributedString.Key.shadow: shadow
            ])
            pageLabel.attributedText = attr
        }
    }
    
    class func defaultHeight() -> CGFloat {
        return 50
    }
    
    // MARK: - event
    @objc func clickOperationButton(_ button: UIButton?) {
        clickOperation?(operationType)
        
    }
    
}

