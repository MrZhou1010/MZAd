# MZAd
应用App启动后广告页面

放在应用启动的方法内

    self.window = UIWindow(frame: UIScreen.main.bounds)
    self.window?.backgroundColor = UIColor.white
    let mainViewController = ViewController()
    let nav = UINavigationController(rootViewController: mainViewController)
    if launchOptions != nil {
        self.window?.rootViewController = nav
    } else {
        // 正常点击icon启动页面,加载广告页
        let adViewController = MZAdViewController(defaultDuration: 6, completion: {
            self.window?.rootViewController = nav
        })
        // 广告地址
        let urlStr = "https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=3009739699,3118462613&fm=26&gp=0.jpg"
        // let urlStr = "http://chatm-icon.oss-cn-beijing.aliyuncs.com/pic/pic_20170724152928869.gif"
        // 倒计时间
        let adDuartion = 10
        let adViewBottomDistance: CGFloat = 0.0
        adViewController.setAdParams(urlStr: urlStr, adDuration: adDuartion, skipBtnType: .circle, skipBtnPosition: .rightTop, adViewBottomDistance: adViewBottomDistance, transitionType: .suckEffect, adImageViewClicked: {
            let vc = UIViewController()
            vc.view.backgroundColor = UIColor.orange
            mainViewController.navigationController?.pushViewController(vc, animated: true)
        })
        self.window?.rootViewController = adViewController
    }
    self.window?.makeKeyAndVisible()
