# MZAd
应用App启动后广告页面

放在应用启动的方法内

    self.window = UIWindow(frame: UIScreen.main.bounds)
    self.window?.backgroundColor = UIColor.white
    let mainViewController = ViewController()
    let nav = UINavigationController.init(rootViewController: mainViewController)
    if launchOptions != nil {
        window?.rootViewController = nav
    } else {
        // 正常点击icon启动页面，加载广告页
        let adViewController = MZAdViewController.init(defaultDuration: 6, completion: {
        self.window?.rootViewController = nav
        })
        // 广告地址
        let url = "https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=3313916584,3062335641&fm=26&gp=0.jpg"
        // let url = "http://chatm-icon.oss-cn-beijing.aliyuncs.com/pic/pic_20170724152928869.gif"
        // 倒计时间
        let adDuartion = 10
        let adViewBottomDistance: CGFloat = 0.0
        adViewController.setAdParams(url: url, adDuration: adDuartion, skipBtnType: .timer, skipBtnPosition: .rightTop, adViewBottomDistance: adViewBottomDistance, transitionType: .filpFromLeft, adImageViewClick: {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.orange
        mainViewController.navigationController?.pushViewController(vc, animated: true)
        })
        window?.rootViewController = adViewController
    }
    window?.makeKeyAndVisible()
