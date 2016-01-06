//
//  UpyunOperation.swift
//  Nian iOS
//
//  Created by Sa on 16/1/3.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary

protocol upYunDelegate {
    func upYunMulti(data: NSDictionary?, count: Int)
}

class UpyunOperation: NSOperation {
    var num = 0
    var image: UIImage!
    var delegate: upYunDelegate?
    var hasUploaded = false
    
    override func main() {
        let uy = UpYun()
        let date = NSDate().timeIntervalSince1970
        /* 由于多图不等待，所以在文件名后加个计数 */
        let name = "/step/\(SAUid())_\(Int(date))\(num).png"
        if !hasUploaded {
            uy.uploadImage(resizedImage(image, newWidth: 500), savekey: name)
            uy.successBlocker = ({(data: AnyObject!) in
                if let d = data as? NSDictionary {
                    var url = d.stringAttributeForKey("url")
                    url = SAReplace(url, before: "/step/", after: "") as String
                    let w = d.stringAttributeForKey("image-width")
                    let h = d.stringAttributeForKey("image-height")
                    setCacheImage("http://img.nian.so/step/\(url)!large", img: self.image, width: globalWidth * globalScale)
                    let data = ["path": url, "width": w, "height": h]
                    self.delegate?.upYunMulti(data, count: self.num)
                }
            })
        } else {
            /* 如果是编辑进展，图片已上传，就跳过上传阶段，直接调用 delegate */
            self.delegate?.upYunMulti(nil, count: self.num)
        }
    }
}