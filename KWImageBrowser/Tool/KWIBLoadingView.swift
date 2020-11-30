//
//  KWIBLoadingView.swift
//  KWImageBrowser
//
//  Created by yuekewei on 2020/11/19.
//

import Foundation
import UIKit

fileprivate struct KWIBLoadingKey {
    static var KWIBLoadingKey: String = "KWIBLoadingKey"
}

extension UIView {
    
    var kwib_loading: KWIBLoadingView {
        set {
            objc_setAssociatedObject(self, &KWIBLoadingKey.KWIBLoadingKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            var toast = objc_getAssociatedObject(self, &KWIBLoadingKey.KWIBLoadingKey) as? KWIBLoadingView
            if toast == nil {
                toast = KWIBLoadingView.init()
                self.kwib_loading = toast!
            }
            return toast!
        }
    }
    
    func kwib_showLoading(withProgress progress: CGFloat) {
        kwib_addLoadingView()
        kwib_loading.showProgress(progress)
    }

    func kwib_showLoading() {
        kwib_addLoadingView()
        kwib_loading.show()
    }

    func kwib_showLoading(withText text: String?, click: (() -> Void)?) {
        kwib_addLoadingView()
        kwib_loading.showText(text, click: click)
    }
    
    func kwib_hideLoading() {
        let loading = kwib_loading
        if loading.superview != nil {
            loading.removeFromSuperview()
        }
    }
        
    func kwib_addLoadingView() {
        let loading = kwib_loading
        if loading.superview == nil {
            addSubview(loading)
            loading.translatesAutoresizingMaskIntoConstraints = false
            let layA: NSLayoutConstraint = NSLayoutConstraint(item: loading, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
            let layB: NSLayoutConstraint = NSLayoutConstraint(item: loading, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
            let layC: NSLayoutConstraint  = NSLayoutConstraint(item: loading, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
            let layD: NSLayoutConstraint = NSLayoutConstraint(item: loading, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
            
            addConstraints([layA, layB, layC, layD].compactMap { $0 })
        }
    }  
}

class KWIBProgressDrawView: UIView {
    var progress: CGFloat = 0.0
    
    override func draw(_ rect: CGRect) {
        if isHidden { return }
        
        let progress = (self.progress.isNaN || self.progress.isInfinite || self.progress < 0) ? 0 : self.progress

        let radius: CGFloat = 17
        let strokeWidth: CGFloat = 3
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        UIColor.lightGray.setStroke()
        let bottomPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        bottomPath.lineWidth = 4.0
        bottomPath.lineCapStyle = .round
        bottomPath.lineJoinStyle = .round
        bottomPath.stroke()
        
        UIColor.white.setStroke()
        let activePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -.pi / 2.0, endAngle: .pi * 2 * progress - .pi / 2.0, clockwise: true)
        activePath.lineWidth = strokeWidth
        activePath.lineCapStyle = .round
        activePath.lineJoinStyle = .round
        activePath.stroke()
        
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 4
        shadow.shadowOffset = CGSize(width: 0, height: 1)
        shadow.shadowColor = UIColor.darkGray
        let string = String(format: "%.0lf%@", progress * 100, "%")
        let atts = NSMutableAttributedString(string: string, attributes: [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.shadow: shadow
        ])
        let size = atts.size()
        atts.draw(at: CGPoint(x: center.x - size.width / 2.0, y: center.y - size.height / 2.0))
    }
}

enum KWImageBrowserProgressType : Int {
    case progress
    case load
    case text
}

class KWIBLoadingView: UIView {
    private var type: KWImageBrowserProgressType = .progress
    
    private var clickTextLabelBlock: (() -> Void)?
    
    var drawView: KWIBProgressDrawView = {
        var drawView = KWIBProgressDrawView()
        drawView.backgroundColor = UIColor.clear
        return drawView
    }()
    
  lazy  var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(KWIBLoadingView.respondsToTapTextlabel))
                 label.addGestureRecognizer(tapGesture)
        label.isUserInteractionEnabled = true
        return label
    }()
    
    var imageView: UIImageView = {
        var img =  UIImageView()
        img.image = UIImage.kw_imageNamed("kwib_loading")
        img.layer.shadowColor = UIColor.darkGray.cgColor
        img.layer.shadowOffset = CGSize(width: 0, height: 1)
        img.layer.shadowOpacity = 1
        img.layer.shadowRadius = 4
        return img
    }()
    
    // MARK: life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0)
        isUserInteractionEnabled = false
        
        addSubview(drawView)
        addSubview(textLabel)
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let layA: NSLayoutConstraint = NSLayoutConstraint(item: textLabel, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 20)
        let layB: NSLayoutConstraint = NSLayoutConstraint(item: textLabel, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -20)
        let layC: NSLayoutConstraint = NSLayoutConstraint(item: textLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let layE: NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let layF: NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        
        drawView.translatesAutoresizingMaskIntoConstraints = false
        let layG = NSLayoutConstraint(item: drawView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let layH = NSLayoutConstraint(item: drawView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        let layI = NSLayoutConstraint(item: drawView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)
        let layJ = NSLayoutConstraint(item: drawView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)

        addConstraints([layA, layB, layC, layE, layF, layG, layH, layI, layJ])
        super.updateConstraints()
    }
    
    // MARK: public
    func showProgress(_ progress: CGFloat) {
        isUserInteractionEnabled = false
        type = .progress
        drawView.isHidden = false
        textLabel.isHidden = true
        imageView.isHidden = true
        stopImageViewAnimation()

        drawView.progress = progress
        drawView.setNeedsDisplay()
    }

    func show() {
        isUserInteractionEnabled = false
        type = .load
        drawView.isHidden = true
        textLabel.isHidden = true
        imageView.isHidden = false

        startImageViewAnimation()
        drawView.setNeedsDisplay()
    }
    
    
    func startImageViewAnimation() {
        
        let ra = CABasicAnimation(keyPath: "transform.rotation.z")
        ra.toValue = NSNumber(value: Double.pi * 2)
        ra.duration = 1
        ra.isCumulative = true
        ra.repeatCount = MAXFLOAT
        ra.isRemovedOnCompletion = false
        ra.fillMode = .forwards
        imageView.layer.add(ra, forKey: "ra")
    }

    func stopImageViewAnimation() {
        imageView.layer.removeAllAnimations()
    }
    
    func showText(_ text: String?, click: (() -> Void)?) {
        isUserInteractionEnabled = click != nil ? true : false
        type = .text
        drawView.isHidden = true
        textLabel.isHidden = false
        imageView.isHidden = true
        stopImageViewAnimation()

        textLabel.text = text
        clickTextLabelBlock = click
        drawView.setNeedsDisplay()
    }
    
    // MARK: - Event
    @objc func respondsToTapTextlabel() {
        clickTextLabelBlock?()
    }
}
