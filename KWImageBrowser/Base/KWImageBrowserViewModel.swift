//
//  KWImageBrowserViewModel.swift
//  KWImageBrowser
//
//  Created by yuekewei on 2020/11/19.
//

import Foundation
import UIKit


class KWImageBrowserViewModel {
    
    weak var browser: KWImageBrowser?
    var preloadCount = 0
    private var dataCache: NSCache<NSNumber, KWIBDataProtocol> = {
        return NSCache()
    }()
    
    var dataCacheCountLimit = 0 {
        willSet {
            dataCache.countLimit = newValue
        }
    }
    
    // MARK: - life cycle
    init(browser: KWImageBrowser) {
        self.browser = browser
    }
    
    // MARK: - public
    var numberOfCells: Int {
        return browser?.dataSourceArray.count ?? 0
    }

    func dataForCell(at index: Int) -> KWIBDataProtocol? {
        if index < 0 || index > numberOfCells - 1 {
            return nil
        }

        var data:KWIBDataProtocol? = dataCache.object(forKey: NSNumber(value: index))
        if data == nil {
            data = browser?.dataSourceArray[index]
        }
        
        if data != nil {
            data?.imageBrowser = browser
            data?.page = index
            dataCache.setObject(data!, forKey: NSNumber(value: index))
        }
        return data
    }
    
    
    func clear() {
        dataCache.removeAllObjects()
    }

    func preload(withPage page: Int) {
        if preloadCount == 0 {
            return
        }

        let targetData = dataForCell(at: page)
        targetData?.kw_preload?()
    }
    
    
}
