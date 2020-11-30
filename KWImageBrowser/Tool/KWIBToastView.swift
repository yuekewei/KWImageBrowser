//
//  KWIBToastView.swift
//  KWImageBrowser
//
//  Created by yuekewei on 2020/11/18.
//

import Foundation
import UIKit

enum KWIBToastType : Int {
    case none
    case hook
    case fork
}

fileprivate struct KWIBToastViewKeys {
    static var KWIBToastKey: String = "KWIBToastKey"
}

extension UIView {
    
    var kwib_toast: KWIBToastView {
        set {
            objc_setAssociatedObject(self, &KWIBToastViewKeys.KWIBToastKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            var toast = objc_getAssociatedObject(self, &KWIBToastViewKeys.KWIBToastKey) as? KWIBToastView
            if toast == nil {
                toast = KWIBToastView.init()
                self.kwib_toast = toast!
            }
            return toast!
        }
    }
    
    @objc func kwib_hideToast() {
        if kwib_toast.superview != nil {
            UIView.animate(withDuration: 0.25, animations: {
                self.kwib_toast.alpha = 0
            }) { [self] finished in
                self.kwib_toast.removeFromSuperview()
                self.kwib_toast.alpha = 1
            }
        }
    }
    
    func kwib_showHookToast(_ text: String?) {
        kwib_showToast(withText: text, type: .hook, hideAfterDelay: 1.7)
    }

    func kwib_showForkToast(_ text: String?) {
        kwib_showToast(withText: text, type: .fork, hideAfterDelay: 1.7)
    }
    
    func kwib_showToast(withText text: String?, type: KWIBToastType, hideAfterDelay delay: TimeInterval) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(kwib_hideToast), object: nil)
        
        let toast = kwib_toast
        if toast.superview == nil {
            addSubview(toast)
            toast.translatesAutoresizingMaskIntoConstraints = false
            let layA = NSLayoutConstraint(item: toast, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
            let layB = NSLayoutConstraint(item: toast, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
            let layC = NSLayoutConstraint(item: toast, attribute: .left, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .left, multiplier: 1, constant: 40)
            let layD = NSLayoutConstraint(item: toast, attribute: .right, relatedBy: .lessThanOrEqual, toItem: self, attribute: .right, multiplier: 1, constant: -40)
            addConstraints([layA, layB, layC, layD])
        }
        toast.show(withText: text, type: type)
        perform(#selector(self.kwib_hideToast), with: nil, afterDelay: delay)
    }
}


class KWIBToastView: UIView {
    var type: KWIBToastType = .none
    
    var shapeLayer: CAShapeLayer?
    
    // MARK: - Lazy
    lazy var textLabel: UILabel = {
        var label = UILabel.init()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        isUserInteractionEnabled = false
        layer.cornerRadius = 7
        
        addSubview(textLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - override
    override func layoutSubviews() {
        super.layoutSubviews()
        startAnimation()
    }
    
    override func updateConstraints() {
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        let layA: NSLayoutConstraint = NSLayoutConstraint(item: textLabel, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 20)
        let layB: NSLayoutConstraint = NSLayoutConstraint(item: textLabel, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -20)
        let layC: NSLayoutConstraint = NSLayoutConstraint(item: textLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -15)
        let layD: NSLayoutConstraint = NSLayoutConstraint(item: textLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 70)
        let layE: NSLayoutConstraint = NSLayoutConstraint(item: textLabel, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60)
        addConstraints([layA, layB, layC, layD, layE])
        super.updateConstraints()
    }
    
    // MARK: - animation
    func show(withText text: String?, type: KWIBToastType) {
        textLabel.text = text
        self.type = type
        setNeedsLayout()
    }
    
    func startAnimation() {
        if shapeLayer != nil && (shapeLayer!.superlayer != nil) {
            shapeLayer?.removeFromSuperlayer()
        }
        shapeLayer = CAShapeLayer()
        shapeLayer!.strokeColor = UIColor.white.cgColor
        shapeLayer!.fillColor = UIColor.clear.cgColor
        shapeLayer!.lineWidth = 5.0
        shapeLayer!.lineCap = CAShapeLayerLineCap(rawValue: "round")
        shapeLayer!.lineJoin = CAShapeLayerLineJoin(rawValue: "round")
        shapeLayer!.strokeStart = 0.0
        shapeLayer!.strokeEnd = 0.0
        
        let bezierPath = UIBezierPath()
        let r: CGFloat = 13.0
        let x: CGFloat = bounds.size.width / 2.0
        let y: CGFloat = 38.0
        
        switch type {
        case .hook:
            bezierPath.move(to: CGPoint(x: x - r - r / 2, y: y))
            bezierPath.addLine(to: CGPoint(x: x - r / 2, y: y + r))
            bezierPath.addLine(to: CGPoint(x: x + r * 2 - r / 2, y: y - r))
        case .fork:
            bezierPath.move(to: CGPoint(x: x - r, y: y - r))
            bezierPath.addLine(to: CGPoint(x: x + r, y: y + r))
            bezierPath.move(to: CGPoint(x: x - r, y: y + r))
            bezierPath.addLine(to: CGPoint(x: x + r, y: y - r))
        default:
            break
        }
        
        let baseAnimation = CABasicAnimation(keyPath: "strokeEnd")
        baseAnimation.fromValue = NSNumber(value: 0.0)
        baseAnimation.toValue = NSNumber(value: 1.0)
        baseAnimation.duration = 0.3
        baseAnimation.isRemovedOnCompletion = false
        baseAnimation.fillMode = .both
        
        shapeLayer!.path = bezierPath.cgPath
        layer.addSublayer(shapeLayer!)
        shapeLayer!.add(baseAnimation, forKey: "strokeEnd")
    }
}
