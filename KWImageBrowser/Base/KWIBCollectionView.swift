//
//  KWIBCollectionView.swift
//  KWImageBrowser
//
//  Created by yuekewei on 2020/11/18.
//

import Foundation
import UIKit

class KWIBCollectionView: UICollectionView {

    var layout = KWIBCollectionViewLayout()
    var reuseSet = Set<String>()
    
    
    // MARK: - life cycle
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        backgroundColor = UIColor.clear
        isPagingEnabled = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        alwaysBounceVertical = false
        alwaysBounceHorizontal = false
        decelerationRate = .fast
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - public
    func reuseIdentifier(forCellClass cellClass: AnyClass) -> String? {
        let identifier = NSStringFromClass(cellClass.self)
        if !reuseSet.contains(identifier) {
            let path = Bundle.main.path(forResource: identifier, ofType: "nib")
            if path != nil {
                register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
            }
            else {
                register(cellClass, forCellWithReuseIdentifier: identifier)
            }
            reuseSet.insert(identifier)
        }
        return identifier
    }

    func centerCell() -> KWIBBaseCollectionCell? {
        let cells = visibleCells
        if cells.count == 0 {
            return nil
        }

        var res = cells[0]
        let centerX = contentOffset.x + (bounds.size.width / 2.0)
        for i in 1..<cells.count {
            if abs(cells[i].center.x - centerX) < abs(res.center.x - centerX) {
                res = cells[i]
            }
        }
        
        return res as? KWIBBaseCollectionCell
    }

    func scrolltoPage(page: Int) {
        let offost: CGFloat = bounds.size.width * CGFloat(page);
        contentOffset = CGPoint(x: offost, y: 0)
    }

    // MARK: - hit test
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        // When the hit-test view is 'UISlider', set '_scrollEnabled' to 'NO', avoid gesture conflicts.
        isScrollEnabled = !(view is UISlider)
        return view
    }

}


class KWIBCollectionViewLayout: UICollectionViewFlowLayout {
    var distanceBetweenPages: CGFloat = 10.0;
    
    
    override init() {
        super.init()
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        sectionInset = .zero
        scrollDirection = .horizontal
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func prepare() {
        super.prepare()
        itemSize = collectionView!.bounds.size
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttsArray:[UICollectionViewLayoutAttributes] = super.layoutAttributesForElements(in: rect) ?? [UICollectionViewLayoutAttributes]()
        let halfWidth = collectionView!.bounds.size.width / 2.0
        let centerX = collectionView!.contentOffset.x + halfWidth

        for obj in layoutAttsArray {
            obj.center = CGPoint.init(x: obj.center.x + (obj.center.x - centerX) / halfWidth * CGFloat(distanceBetweenPages), y: obj.center.y)
        }

        return layoutAttsArray
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
