//
//  AppDelegate.swift
//  MZAd
//
//  Created by Mr.Z on 2019/11/7.
//  Copyright © 2019 Mr.Z. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        let mainViewController = ViewController()
        let nav = UINavigationController.init(rootViewController: mainViewController)
        if launchOptions != nil {
            self.window?.rootViewController = nav
        } else {
            // 正常点击icon启动页面,加载广告页
            let adViewController = MZAdViewController.init(defaultDuration: 3, completion: {
                self.window?.rootViewController = nav
            })
            let urlStr = "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1589372597330&di=a7d6e2137594a59368c7a919af979ae8&imgtype=0&src=http%3A%2F%2Fimg2.tgbusdata.cn%2Fv2%2Fthumb%2Fjpg%2FZmFlMCwwLDAsNCwzLDEsLTEsMCxyazUw%2Fu%2Folpic.tgbusdata.cn%2Fuploads%2Fallimg%2F130904%2F15-130Z4200F9.gif"
            let adDuartion = 3
            let adViewBottomDistance: CGFloat = 0.0
            adViewController.setAdParams(urlStr: urlStr, adDuration: adDuartion, skipBtnType: .circle, skipBtnPosition: .rightTop, adViewBottomDistance: adViewBottomDistance, transitionType: .filpFromLeft, adImageViewClicked: {
                let vc = UIViewController()
                vc.view.backgroundColor = UIColor.orange
                mainViewController.navigationController?.pushViewController(vc, animated: true)
            })
            self.window?.rootViewController = adViewController
        }
        self.window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
