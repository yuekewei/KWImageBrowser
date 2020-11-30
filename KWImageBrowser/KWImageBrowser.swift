//
//  KWImageBrowser.swift
//  KWImageBrowser
//
//  Created by yuekewei on 2020/11/18.
//

import UIKit

class KWImageBrowser: UIView {
    
    // MARK: - publie var
    /// 状态回调代理
    weak var delegate:KWImageBrowserProtocol?
    /// 默认工具视图处理器
    weak var defaultToolViewHandler: KWIBToolViewProtocol?
    /// 数据源数组
    var dataSourceArray: [KWIBDataProtocol] = [KWIBDataProtocol]()
    
    /// 是否自动隐藏 id<KWIBImageData> 设置的映射视图，默认为 YES
    var autoHideProjectiveView = true
    
    /// 是否隐藏状态栏，默认为 YES（该值为 YES 时需要在 info.plist 中添加 View controller-based status bar appearance : NO 才能生效）
    var shouldHideStatusBar = true
    /// 工具视图处理器
    /// 赋值可自定义，实现者可以直接用 UIView，或者创建一个中介者管理一系列的 UIView。
    /// 内部消息是按照数组下标顺序调度的，所以如果有多个处理器注意添加 UIView 的视图层级。
    var toolViewHandlers: [KWIBToolViewProtocol] = [KWIBDefaultToolView()]
    /// Toast/Loading 处理器 (赋值可自定义)
    var auxiliaryViewHandler: KWIBHudProtocol = KWIBHud()
    /// 转场实现类 (赋值可自定义) 默认KWIBDefaultTransition (可配置其属性)
    var animatedTransition: KWIBTransitionProtocol = KWIBDefaultTransition()
//    var OrientationObserver: KWIBOrientationObserver = KWIBOrientationObserver()
    
    /// 当前页码
    var currentPage: Int = 0 {
        didSet {
            let rows = browserViewModel.numberOfCells
            if rows > 0 {
                let maxPage = browserViewModel.numberOfCells - 1
                var page: Int = max(0, currentPage)
                page = min(page, maxPage)
                currentPage = page
            }
        }
    }
    
    /// 分页间距
    var distanceBetweenPages: CGFloat  {
        set {
            self.collectionView.layout.distanceBetweenPages = newValue
        }
        
        get {
            return CGFloat(self.collectionView.layout.distanceBetweenPages)
        }
        
    }
    /// 图片浏览器支持的方向 (仅当前控制器不支持旋转时有效，否则将跟随控制器旋转)
    var supportedOrientations: UIInterfaceOrientationMask {
        set {
            self.rotationObserver.supportedOrientations = newValue
        }
        
        get {
            return self.rotationObserver.supportedOrientations
        }
    }
    /// 预加载数量 (默认为 2，低内存设备默认为 0)
    var preloadCount: Int {
        set {
            self.browserViewModel.preloadCount = newValue
        }
        
        get {
            return self.browserViewModel.preloadCount
        }
    }
    
    /// 当前图片浏览器的方向
    var currentOrientation: UIInterfaceOrientation {
        return self.rotationObserver.currentOrientation
    }
    
    // MARK: - private var
    private var originStatusBarHidden: Bool = false
    private weak var hiddenProjectiveView: UIView? {
        didSet {
            if oldValue != nil {
                oldValue!.isHidden = false
            }
            if !autoHideProjectiveView {
                return
            }
            if hiddenProjectiveView != nil {
                hiddenProjectiveView!.isHidden = true
            }
        }
    }
    /// 初始化页码
    private(set) var fromPage = 0
    
    /// 是否正在转场
    private(set) var transitioning = false
    /// 是否正在进行展示过程转场
    private(set) var showTransitioning = false
    /// 是否正在进行隐藏过程转场
    private(set) var hideTransitioning = false
    
    // MARK: - lazy
    /// 核心集合视图
    lazy var collectionView: KWIBCollectionView = {
        var  collection: KWIBCollectionView = KWIBCollectionView.init(frame: CGRect.zero, collectionViewLayout: KWIBCollectionViewLayout.init());
        collection.delegate = self;
        collection.dataSource = self;
        return collection;
    }()
    
    lazy var rotationObserver: KWIBScreenRotationObserver = {
        var rotationHandler = KWIBScreenRotationObserver(browser: self)
        return rotationHandler
    }()
    /// 容器视图 (可在上面添加子视图)
    lazy var containerView: KWIBContainerView = {
        var containerView: KWIBContainerView = KWIBContainerView();
        containerView.layer.masksToBounds = true;
        containerView.backgroundColor = UIColor.clear
        return containerView;
    }()
    
    lazy var browserViewModel: KWImageBrowserViewModel = {
        var viewModel = KWImageBrowserViewModel.init(browser: self)
        viewModel.dataCacheCountLimit = kw_isLowMemory() ? 9 : 27
        viewModel.preloadCount = kw_isLowMemory() ? 0 : 2
        return viewModel
    }()
    
    
    // MARK: -
    // MARK: - life cycle
    deinit {
        hiddenProjectiveView = nil
        showStatusBar()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black
        defaultToolViewHandler = toolViewHandlers[0]
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(respondsLongPress(sender:)))
        addGestureRecognizer(longPress)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private
    private func build() {
        
        addSubview(collectionView)
        collectionView.frame = bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        addSubview(containerView)
        containerView.frame = bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        buildToolView()
        layoutIfNeeded()
        collectionViewScroll(toPage: self.currentPage)
        rotationObserver.startObserveDeviceOrientation()
    }
    
    private func rebuild() {
        hiddenProjectiveView = nil
        showStatusBar()
        containerView.removeFromSuperview()
        collectionView.removeFromSuperview()
        browserViewModel.clear()
        rotationObserver.clear()
    }
    
    private func buildToolView() {
        for handler in toolViewHandlers {
            handler.kw_imageBrowser = self
            handler.kw_containerViewIsReadied()
            handler.kw_hide(false)
        }
    }
    
    private func collectionViewScroll(toPage page: Int) {
        collectionView.scrolltoPage(page: page)
        pageNumberChanged()
    }
    
    private func pageNumberChanged()  {
        let data = dataSourceArray[self.currentPage]
        hiddenProjectiveView = data.kw_projectiveView?()
        delegate?.kw_imageBrowserPageChanged?(imageBrowser: self, page: currentPage, data: data)
        for handler in toolViewHandlers {
            handler.kw_pageChanged?()
        }
        let visibleCells = collectionView.visibleCells
        for cell in visibleCells {            
            if let _cell: KWIBBaseCollectionCell = cell as? KWIBBaseCollectionCell {
                _cell.kw_pageChanged()
            }
        }
    }
    
    
    // MARK: - 显示/隐藏
    func show()  {
        if dataSourceArray.count < currentPage {return}
        
        self.rotationObserver.startObserveStatusBarOrientation()
        self.originStatusBarHidden = UIApplication.shared.isStatusBarHidden
        fromPage = currentPage
        UIApplication.shared.keyWindow?.addSubview(self)
        self.frame = UIScreen.main.bounds
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.rotationObserver.configContainerSize(self.bounds.size)
        
        self.browserViewModel.preload(withPage: self.currentPage)

        
        let data =  dataSourceArray[currentPage]
        let startView: UIView? = data.kw_projectiveView?()
        var startImage: UIImage?
        
        hiddenProjectiveView = startView
        if startView != nil {
            if startView is UIImageView {
                startImage = (startView as? UIImageView)?.image
            }
            else {
                startImage = kwib_SnapshotView(startView!)
            }
        }
        let endFrame = data.kw_imageViewFrame?(withContainerSize: self.bounds.size, imageSize: startImage?.size ?? CGSize.zero, orientation: UIInterfaceOrientation.portrait)
        
        setTransitioning(transitioning: true, isShow: true)
        self.animatedTransition.kwIB_showTransitioning(withContainer: self, start: startView, start: startImage, endFrame: endFrame ?? CGRect.zero, orientation: UIInterfaceOrientation.portrait) {
            self.hideStatusBar()
            self.build()
            self.setTransitioning(transitioning: false, isShow: true)
        }
    }
    
    func hide() {
        var startView: UIView?
        var endView: UIView?
        let cell = collectionView.centerCell()
        
        startView = cell?.kw_foregroundView()
        endView = cell?.cellData?.kw_projectiveView?()
        
        if endView == nil {
            let fromData = dataSourceArray[fromPage]
            endView = fromData.kw_projectiveView?()
            
        }
        showStatusBar()
        self.setTransitioning(transitioning: true, isShow: false)
        animatedTransition.kwIB_hideTransitioning(withContainer: self, start: startView, end: endView, orientation: UIInterfaceOrientation.portrait) {
            self.hideStatusBar()
            self.rebuild()
            self.removeFromSuperview()
            self.setTransitioning(transitioning: false, isShow: false)
        }
    }
    
    
    // MARK: - public
    func setTransitioning(transitioning: Bool, isShow: Bool) {
        self.transitioning = transitioning
        showTransitioning = transitioning && isShow
        hideTransitioning = transitioning && !isShow

        // Make 'self.userInteractionEnabled' always 'YES' to block external interaction.
        containerView.isUserInteractionEnabled = !transitioning
        collectionView.isUserInteractionEnabled = !transitioning

        if transitioning {
            delegate?.kw_imageBrowserBeginTransitioning?(imageBrowser: self, isShow: isShow)
        } else {
            delegate?.kw_imageBrowserEndTransitioning?(imageBrowser: self, isShow: isShow)
        }
    }
    
    func reloadData() {
        browserViewModel.clear()
        collectionView.reloadData()
        collectionViewScroll(toPage: self.currentPage)
    }
    
    func currentData() -> KWIBDataProtocol? {
        return browserViewModel.dataForCell(at: currentPage)
    }
    
    /// 判断当前展示的 cell 是否恰好在屏幕中间
    func cellIsInCenter() -> Bool {
        let pageF = collectionView.contentOffset.x / collectionView.bounds.size.width
        // '0.001' is admissible error.
        return Double(abs(pageF - CGFloat(Int(pageF)))) <= 0.001
    }
    
    func hideToolViews(_ hide: Bool) {
        for handler in toolViewHandlers {
            handler.kw_hide(hide)
        }
    }
    
    func showStatusBar() {
        if shouldHideStatusBar {
            if delegate?.kw_showStatusBar?(imageBrowser: self) == nil {
                UIApplication.shared.isStatusBarHidden = originStatusBarHidden
            }
        }
    }
    
    func hideStatusBar() {
        if shouldHideStatusBar {
            if delegate?.kw_hideStatusBar?(imageBrowser: self) == nil {
                UIApplication.shared.isStatusBarHidden = true
            }
        }
    }
    
    
    // MARK: - event
    @objc func respondsLongPress( sender: UILongPressGestureRecognizer?) {
        if sender?.state == .began {
            if delegate?.kw_imageBrowserRespondsToLongPress?(imageBrowser: self, data: currentData()!) == nil {
                for handler in toolViewHandlers {
                    handler.kw_respondsToLongPress?()
                }
            }
        }
    }
}


extension KWImageBrowser: UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSourceArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var data: KWIBDataProtocol?
        if indexPath.row < dataSourceArray.count {
            data = dataSourceArray[indexPath.item]
        }
        data?.imageBrowser = self
        data?.page = indexPath.row
        data?.registerCellClass(self)
        let cell = data?.kw_imageBrowser(self, cellForItemAt: indexPath.row)
        if cell != nil {
            cell?.page = indexPath.row
            cell?.imageBrowser = self
            cell?.cellData = data
            return cell!
        }
        else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageF = scrollView.contentOffset.x / scrollView.bounds.size.width
        let page = Int(pageF + 0.5)
        
        for handler in toolViewHandlers {
            handler.kw_offsetXChanged?(pageF)
        }
        
        if !scrollView.isDecelerating && !scrollView.isDragging {
            // Return if not scrolled by finger.
            return
        }
        if page < 0 || page > browserViewModel.numberOfCells - 1 {
            return
        }
        if rotationObserver.rotating {
            return
        }
        
        if page != currentPage {
            currentPage = page
            pageNumberChanged()
        }
    }
}



