//
//  MZAdViewController.swift
//  MZAd
//
//  Created by 木木 on 2019/11/7.
//  Copyright © 2019 Mr.Z. All rights reserved.
//

import UIKit

/// 屏幕宽度
let kScreenWidth: CGFloat = UIScreen.main.bounds.size.width
/// 屏幕高度
let kScreenHeight: CGFloat = UIScreen.main.bounds.size.height

enum MZSkipBtnType {
    case none                   // 无跳过按钮
    case timer                  // 方形跳过+倒计时间
    case circle                 // 圆形跳过+倒计动画
}

enum MZSkipBtnPosition {
    case rightTop               // 屏幕右上角
    case rightBottom            // 屏幕右下角
    case rightAdViewBottom      // 广告图右下角
}

enum MZTransitionType {
    case none
    case rippleEffect           // 波纹
    case fade                   // 交叉淡化
    case flipFromTop            // 上下翻转
    case filpFromBottom
    case filpFromLeft           // 左右翻转
    case filpFromRight
}

class MZAdViewController: UIViewController {
    
    // 默认3s
    fileprivate var defaultTime = 3
    
    // 广告图距底部距离
    fileprivate var adViewBottomDistance: CGFloat = 100
    
    // 变换类型
    fileprivate var transitionType: MZTransitionType = .fade
    
    // 跳过按钮位置
    fileprivate var skipBtnPosition: MZSkipBtnPosition = .rightTop
    
    // 广告时间
    fileprivate var adDuration: Int = 0
    
    // 默认定时器
    fileprivate var originalTimer: DispatchSourceTimer?
    
    // 图片显示定时器
    fileprivate var dataTimer: DispatchSourceTimer?
    
    // 图片点击回调
    fileprivate var adImageViewClick: (() -> ())?
    
    // 图片倒计时完成回调
    fileprivate var completion: (() -> ())?
    
    // 动画layer
    fileprivate var animationLayer: CAShapeLayer?
    
    // 跳过按钮类型
    fileprivate var skipBtnType: MZSkipBtnType = .timer {
        didSet {
            let btnWidth: CGFloat = 60
            let btnHeight: CGFloat = 30
            var y: CGFloat = 0
            switch skipBtnPosition {
            case .rightBottom:
                y = kScreenHeight - 50
            case .rightAdViewBottom:
                y = kScreenHeight - adViewBottomDistance - 50
            default:
                y = 50
            }
            let timeRect = CGRect(x: kScreenWidth - 70, y: y, width: btnWidth, height: btnHeight);
            let circleRect = CGRect(x: kScreenWidth - 50, y: y, width: btnHeight, height: btnHeight)
            skipBtn.frame = skipBtnType == .timer ? timeRect : circleRect
            skipBtn.layer.cornerRadius = skipBtnType == .timer ? 5 : btnHeight * 0.5
            skipBtn.titleLabel?.font = UIFont.systemFont(ofSize: skipBtnType == .timer ? 13.5 : 12)
            skipBtn.setTitle(skipBtnType == .timer ? "\(adDuration)s跳过" : "跳过", for: .normal)
        }
    }
    
    // 启动页
    fileprivate lazy var launchImageView: UIImageView = {
        let imageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.image = self.getLaunchImage()
        return imageView
    }()
    
    // 广告图
    fileprivate lazy var launchAdImageView: UIImageView = {
        let adImageRect = CGRect(x: 0,y: 0, width: kScreenWidth, height: kScreenHeight - adViewBottomDistance)
        let adImageView = UIImageView(frame: adImageRect)
        adImageView.isUserInteractionEnabled = true
        adImageView.alpha = 0.2
        let tap = UITapGestureRecognizer(target: self, action: #selector(launchAdTapAction(sender:)))
        adImageView.addGestureRecognizer(tap)
        return adImageView
    }()
    
    // 跳过按钮
    fileprivate lazy var skipBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(skipBtnClick), for: .touchUpInside)
        return button
    }()
    
    @objc fileprivate func launchAdTapAction(sender: UITapGestureRecognizer) {
        self.dataTimer?.cancel()
        self.launchAdRemove {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4, execute: {
                if self.adImageViewClick != nil {
                    self.adImageViewClick!()
                }
            })
        }
    }
    
    @objc fileprivate func skipBtnClick() {
        self.dataTimer?.cancel()
        self.launchAdRemove(completion: nil)
    }
    
    // 关闭广告
    fileprivate func launchAdRemove(completion: (() -> ())?) {
        if self.originalTimer?.isCancelled == false {
            self.originalTimer?.cancel()
        }
        if self.dataTimer?.isCancelled == false {
            self.dataTimer?.cancel()
        }
        let trans = CATransition()
        trans.duration = 0.5
        switch transitionType {
        case .rippleEffect:
            trans.type = CATransitionType(rawValue: "rippleEffect")
        case .filpFromLeft:
            trans.type = CATransitionType(rawValue: "oglFlip")
            trans.subtype = CATransitionSubtype.fromLeft
        case .filpFromRight:
            trans.type = CATransitionType(rawValue: "oglFlip")
            trans.subtype = CATransitionSubtype.fromRight
        case .flipFromTop:
            trans.type = CATransitionType(rawValue: "oglFlip")
            trans.subtype = CATransitionSubtype.fromRight
        case .filpFromBottom:
            trans.type = CATransitionType(rawValue: "oglFlip")
            trans.subtype = CATransitionSubtype.fromBottom
        default:
            trans.type = CATransitionType(rawValue: "fade")
        }
        UIApplication.shared.keyWindow?.layer.add(trans, forKey: nil)
        if self.completion != nil {
            self.completion!()
            if completion != nil {
                completion!()
            }
        }
    }
    
    // 初始化 设置默认显示时间defaultDuration,如果不设置,默认3s
    convenience init(defaultDuration: Int = 3, completion: (() -> ())?) {
        self.init(nibName: nil, bundle: nil)
        if defaultDuration >= 1 {
            self.defaultTime = defaultDuration
        }
        self.completion = completion
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.addSubview(self.launchImageView)
        self.dataTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        self.startTimer()
    }
}

// MARK: -- 参数设置
extension MZAdViewController {
    /* 设置广告参数 - Parameters:
     **   - url: 路径
     **   - adDuration:             显示时间
     **   - skipBtnType:            跳过按钮类型，默认方形跳过+倒计时间
     **   - skipBtnPosition:        跳过按钮位置，默认右上角
     **   - adViewBottomDistance:   图片距底部的距离，默认100
     **   - transitionType:         过渡的类型，默认“fade”
     **   - adImageViewClick:       点击广告回调
     **   - completion:             完成回调
     */
    public func setAdParams(url: String, adDuration: Int = 3, skipBtnType: MZSkipBtnType = .timer, skipBtnPosition: MZSkipBtnPosition = .rightTop, adViewBottomDistance: CGFloat = 100, transitionType: MZTransitionType = .fade, adImageViewClick: (() -> ())?) {
        self.adDuration = adDuration
        self.skipBtnType = skipBtnType
        self.skipBtnPosition = skipBtnPosition
        self.adViewBottomDistance = adViewBottomDistance
        self.transitionType = transitionType
        if adDuration < 1 {
            self.adDuration = 1
        }
        if url != "" {
            self.view.addSubview(launchAdImageView)
            self.launchAdImageView.setImage(url: url, completion: {
                // 如果带缓存,并且需要改变按钮状态
                self.skipBtn.removeFromSuperview()
                if self.animationLayer != nil {
                    self.animationLayer?.removeFromSuperlayer()
                    self.animationLayer = nil
                }
                if skipBtnType != .none {
                    self.view.addSubview(self.skipBtn)
                    if self.skipBtnType == .circle {
                        self.addLayer(view: self.skipBtn)
                    }
                }
                self.adStartTimer()
                UIView.animate(withDuration: 0.8, animations: {
                    self.launchAdImageView.alpha = 1
                })
            })
        }
        self.adImageViewClick = adImageViewClick
    }
    
    // 添加动画
    fileprivate func addLayer(view: UIView) {
        let bezierPath = UIBezierPath(ovalIn: view.bounds)
        animationLayer = CAShapeLayer()
        animationLayer?.path = bezierPath.cgPath
        animationLayer?.lineWidth = 1
        animationLayer?.strokeColor = UIColor.red.cgColor
        animationLayer?.fillColor = UIColor.clear.cgColor
        let animation = CABasicAnimation(keyPath: "strokeStart")
        animation.duration = Double(adDuration)
        animation.fromValue = 0
        animation.toValue = 1
        animationLayer?.add(animation, forKey: nil)
        view.layer.addSublayer(animationLayer!)
    }
}

/* MARK: -- GCD定时器
 ** APP启动后开始默认定时器，默认3s
 ** 3s内若网络图片加载完成，默认定时器关闭，开启图片倒计时
 ** 3s内若图片加载未完成，执行completion闭包
 */
extension MZAdViewController {
    // 默认定时器
    fileprivate func startTimer() {
        originalTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        originalTimer?.schedule(deadline: DispatchTime.now(), repeating: DispatchTimeInterval.seconds(1), leeway: DispatchTimeInterval.milliseconds(self.defaultTime))
        originalTimer?.setEventHandler(handler: {
            if self.defaultTime == 0 {
                self.launchAdRemove(completion: nil)
            }
            self.defaultTime -= 1
        })
        originalTimer?.resume()
    }
    
    // 图片倒计时
    fileprivate func adStartTimer() {
        if self.originalTimer?.isCancelled == false {
            self.originalTimer?.cancel()
        }
        dataTimer?.schedule(deadline: DispatchTime.now(), repeating: DispatchTimeInterval.seconds(1), leeway: DispatchTimeInterval.milliseconds(self.adDuration))
        dataTimer?.setEventHandler(handler: {
            self.skipBtn.setTitle(self.skipBtnType == .timer ? "\(self.adDuration)s跳过" : "跳过", for: .normal)
            if self.adDuration == 0 {
                self.launchAdRemove(completion: nil)
            }
            self.adDuration -= 1
        })
        dataTimer?.resume()
    }
}

// MARK: -- 状态栏相关
extension MZAdViewController {
    // 状态栏显示、颜色与General -> Deployment Info中设置一致
    override var prefersStatusBarHidden: Bool {
        return Bundle.main.infoDictionary?["UIStatusBarHidden"] as! Bool
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let str = Bundle.main.infoDictionary?["UIStatusBarStyle"] as! String
        return str.contains("Default") ? .default : .lightContent
    }
}

// MARK: -- 获取启动页
extension MZAdViewController {
    fileprivate func getLaunchImage() -> UIImage {
        if self.assetsLaunchImage() != nil || self.storyboardLaunchImage() != nil {
            return self.assetsLaunchImage() != nil ? self.assetsLaunchImage()! : self.storyboardLaunchImage()!
        }
        return UIImage()
    }
    
    // 获取Assets里LaunchImage
    fileprivate func assetsLaunchImage() -> UIImage? {
        let size = UIScreen.main.bounds.size
        // 横屏"Landscape"
        let orientation = "Portrait"
        guard let launchImages = Bundle.main.infoDictionary?["UILaunchImages"] as? [[String: Any]] else {
            return nil
        }
        for dic in launchImages {
            let imageSize = NSCoder.cgSize(for: dic["UILaunchImageSize"] as! String)
            if __CGSizeEqualToSize(imageSize, size) && orientation == (dic["UILaunchImageOrientation"] as! String) {
                let launchImageName = dic["UILaunchImageName"] as! String
                let image = UIImage(named: launchImageName)
                return image
            }
        }
        return nil
    }
    
    // 获取LaunchScreen.Storyboard
    fileprivate func storyboardLaunchImage() -> UIImage? {
        guard let storyboardLaunchName = Bundle.main.infoDictionary?["UILaunchStoryboardName"] as? String,
            let launchViewController = UIStoryboard(name: storyboardLaunchName, bundle: nil).instantiateInitialViewController() else {
                return nil
        }
        let view = launchViewController.view
        view?.frame = UIScreen.main.bounds
        let image = self.viewConvertImage(view: view!)
        return image
    }
    
    // view转换图片
    fileprivate func viewConvertImage(view: UIView) -> UIImage {
        let size = view.bounds.size
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

