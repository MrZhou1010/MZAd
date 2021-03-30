//
//  UIImageView+MZGif.swift
//  MZAd
//
//  Created by Mr.Z on 2019/11/7.
//  Copyright © 2019 Mr.Z. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    /// 设置Gif图像
    /// - Parameters:
    ///   - urlString: 图像地址
    ///   - completion: callback
    public func setImage(_ urlString: String, completion: (() -> ())?) {
        DispatchQueue.global().async {
            guard let url = URL(string: urlString) else {
                return
            }
            guard let data = try? Data(contentsOf: url) else {
                return
            }
            guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
                return
            }
            // 图片帧数
            let totalCount = CGImageSourceGetCount(imageSource)
            var images = [UIImage]()
            var gifDuration = 0.0
            for i in 0 ..< totalCount {
                // 获取对应帧的CGImage
                guard let imageRef = CGImageSourceCreateImageAtIndex(imageSource, i, nil) else {
                    return
                }
                if totalCount == 1 {
                    // 单张图片
                    gifDuration = Double.infinity
                    guard let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) else {
                        return
                    }
                    images.append(image)
                } else {
                    // Gif图片
                    guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil), let gifInfo = (properties as NSDictionary)[kCGImagePropertyGIFDictionary as String] as? NSDictionary, let frameDuration = (gifInfo[kCGImagePropertyGIFDelayTime as String] as? NSNumber) else {
                        return
                    }
                    gifDuration += frameDuration.doubleValue
                    // 获取帧的image
                    let image = UIImage(cgImage: imageRef, scale: UIScreen.main.scale, orientation: UIImage.Orientation.up)
                    images.append(image)
                }
            }
            DispatchQueue.main.async {
                self.animationImages = images
                self.animationDuration = gifDuration
                self.animationRepeatCount = 0
                self.startAnimating()
                if completion != nil {
                    completion!()
                }
            }
        }
    }
}
