//
//  ViewController.swift
//  KWImageBrowser
//
//  Created by yuekewei on 2020/11/12.
//

import UIKit
import SnapKit
import Kingfisher
import Alamofire

class ViewController: UIViewController {
    var collectionView: UICollectionView = {
        
        let padding: CGFloat = 5
        let cellLength = (UIScreen.main.bounds.size.width - padding * 2) / 3
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: cellLength, height: cellLength)
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        
        let collectionView: UICollectionView = UICollectionView(frame: CGRect(x: 0, y: 100, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    var dataArray:[String] = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white;
        
        
        
        //                dataArray.append("https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1595911873051&di=f4756c05486f45656ad3dafa244f5b2b&imgtype=0&src=http%3A%2F%2Ftva1.sinaimg.cn%2Fmw690%2Fa0f171a9ly1fdnk0i00prg20b406bb2b.gif")
        
        //        dataArray.append("https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1595911873050&di=0f4653826e9b38d8f327418eeba72205&imgtype=0&src=http%3A%2F%2Fww2.sinaimg.cn%2Flarge%2F00650UXkjw9er7nj4l65xg308v06d4qp.gif")
        //                dataArray.append("https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=174513156,3963217582&fm=26&gp=0.jpg")
        //        dataArray.append("https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1595925051681&di=3b8796e206885972aa4834e7153f6d7a&imgtype=0&src=http%3A%2F%2Fqiniuimg.qingmang.mobi%2Fimage%2Forion%2Ff1d9602118a59581c95013af8ecb7d36_350_197.gif")
        //        dataArray.append("https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1595925119467&di=1ec7875e11ab05b854ac8c1971cd49b4&imgtype=0&src=http%3A%2F%2Fztd00.photos.bdimg.com%2Fztd%2Fw%3D700%3Bq%3D50%2Fsign%3De4fb138eefcd7b89e96c38833f1f339a%2F3bf33a87e950352af6a0364c5a43fbf2b3118bb4.jpg")
        //        dataArray.append("https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1595925259969&di=c7bd4f13f75f5bee111a32ed6a6eec14&imgtype=0&src=http%3A%2F%2F01.minipic.eastday.com%2F20170421%2F20170421143734_ba2eace48dd7194f8c64d545ad7c50ca_8.jpeg")
        //        dataArray.append("https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1595926164985&di=c0999d0fe08ac3941b3fff44a34d23a0&imgtype=0&src=http%3A%2F%2F01.minipic.eastday.com%2F20170314%2F20170314093020_61f5e1c760157917576b50b62bc59c80_7.jpeg")
        
        //        dataArray.append("https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1596779537027&di=107cb52f754239b6faabd34245d75e2f&imgtype=0&src=http%3A%2F%2Fattach.bbs.miui.com%2Fforum%2F201505%2F27%2F172736r8qcystlxcil9s9l.jpg")
        //
        //        dataArray.append("http://imgsrc.baidu.com/forum/pic/item/ad2f98cb0a46f21f9c59d284fb246b600e33aeda.jpg")
        //        dataArray.append("https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1596793126452&di=e5c2b9f91df5971017acd33d3470aac1&imgtype=0&src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fimages%2F20171117%2F399572cb33b64bf8b1fdf298c978a3c5.gif")
        //        dataArray.append("https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1596793269324&di=60db492c7ef9f5c6b26677797dbc98d1&imgtype=0&src=http%3A%2F%2Fimg.mp.itc.cn%2Fupload%2F20170326%2F38d3ea08e42243318134a42e340d0fc9_th.gif")
        //                dataArray.append("https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1596793418883&di=200a07c42e99a822e4414422b51f03fa&imgtype=0&src=http%3A%2F%2Fimg.mp.itc.cn%2Fupload%2F20160909%2F8e3f3181a20a41cb991b6c5b6d0e7aa3_th.gif")
        //        dataArray.append("http://i-2-yxdown.715083.com/2014/11/14/0372d212-9a73-44ce-bb27-6beae4a237cc.jpg?imageView2/2/q/85")
        
//        dataArray.append("18000 × 12006 9.4 MB");
        dataArray.append("22524 × 12260 15M");
//        dataArray.append("24096 × 16096 20.2 MB");
        
        self.collectionView.register(KWImageCell.self, forCellWithReuseIdentifier: "cell")
        self.view.addSubview(self.collectionView);
        self.collectionView.snp.makeConstraints { (make: ConstraintMaker) in
            make.edges.equalToSuperview()
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    
}

extension ViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:KWImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! KWImageCell
        
        var imgName = dataArray[indexPath.row]
        
        var image = UIImage.init(contentsOfFile: Bundle.main.path(forResource: imgName, ofType: "jpg") ?? "")
        
        DispatchQueue.global().async{
            image = image?.yy_imageByDecoded()
            DispatchQueue.main.async {
                cell.imageView.image = image
            }
            
        }
        
        //                        cell.imageView.kf.setImage(with: URL.init(string: dataArray[indexPath.row]));
                
        //        cell.imageView.sd_setImage(with: URL.init(string: dataArray[indexPath.row]), placeholderImage: nil, options: [], context: nil)
        return  cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var array: [KWIBImageData] = []
        
        (dataArray as NSArray).enumerateObjects { (obj, idx, stop) in
            
            let cell: KWImageCell = collectionView.cellForItem(at: IndexPath.init(row: idx, section: 0)) as! KWImageCell;
            
            let data = KWIBImageData()
            data.projectiveView = cell.imageView;
            //            data.createImageContainerBlock = {
            //                return AnimatedImageView.init()
            //            }
            array.append(data)
        }
        
        let browser = KWImageBrowser()
        
        browser.delegate = self
        browser.dataSourceArray = array
        browser.currentPage = indexPath.row
        browser.show()
        // 只有一个保存操作的时候，可以直接右上角显示保存按钮
        //        browser.defaultToolViewHandler?.topView.operationType = KWIBTopViewOperationType(rawValue: 0);
        //        browser.defaultToolViewHandler!.topView.operationType = .save;
        //        browser.show()
    }
}

extension ViewController : KWImageBrowserProtocol {
    
    func kw_loadThumbImage(
        index: Int,
        progress: KWIBWebImageProgressBlock?,
        completed completedBlock: KWIBWebImageCompletedBlock?
    ) {
        let url = dataArray[index]
        
        SDWebImageManager.shared.loadImage(with: URL(string: url), options: [.fromLoaderOnly,.retryFailed], progress: { receivedSize, expectedSize, targetURL in
            progress?(Float(receivedSize), Float(expectedSize))
        }, completed: { image, data, error, cacheType, finished, imageURL in
            print(image)
            completedBlock?(image, data, error, finished)
        })
    }
    func kw_loadLargeImage(
        index: Int,
        progress: KWIBWebImageProgressBlock?,
        completed completedBlock: KWIBWebImageCompletedBlock?
    ) {
        let url = dataArray[index]
        

        
        SDWebImageManager.shared.loadImage(with: URL(string: url), options: [.avoidDecodeImage],
                                           progress: { receivedSize, expectedSize, targetURL in
                                            progress?(Float(receivedSize), Float(expectedSize))
                                           },
                                           completed: { image, data, error, cacheType, finished, imageURL in
                                            print(image ?? "")
                                            var decodeImage = image;
                                            
                                            if image != nil && (image!.size.width > 4096 || image!.size.height > 4096) {
//                                              decodeImage =  SDImageCoderHelper.decodedAndScaledDownImage(with: image!, limitBytes: 1024 * 3)
                                            }
                                            completedBlock?(decodeImage, data, error, finished)
                                           })
    }
}



class KWImageCell: UICollectionViewCell {
    // 图片
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill;
        imageView.clipsToBounds = true;
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setUpLayout(){
        self.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview();
            make.bottom.equalToSuperview();
        }
        
    }
}


