//
//  SAEgg.swift
//  Nian iOS
//
//  Created by Sa on 15/7/16.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation
import SpriteKit

@objc protocol ShareDelegate {
    func onShare(avc: UIActivityViewController)
    
    optional func saEgg(saEgg: SAEgg, tapBackground: Bool)
    optional func saEgg(saEgg: SAEgg, lotteryResult: NSDictionary)
}

class SAEgg: NIAlert, NIAlertDelegate {
    var confirmNiAlert = NIAlert()
    var lotteryNiAlert = NIAlert()
    var coinLessNiAlert = NIAlert()
    var petData: NSDictionary!
    var delegateShare: ShareDelegate?
    var skView: SKView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func niAlert(niAlert: NIAlert, tapBackground: Bool) {
        // 点击了 saEgg 的 background ，然后交给 delegate 处理
        delegateShare?.saEgg?(self, tapBackground: true)
        
        if niAlert == self {
            self.dismissWithAnimation(.normal)
        } else if niAlert == self.confirmNiAlert {
            self.dismissWithAnimation(.normal)
            self.confirmNiAlert.dismissWithAnimation(.normal)
        } else if niAlert == self.lotteryNiAlert {
            self.dismissWithAnimation(.normal)
            self.lotteryNiAlert.dismissWithAnimation(.normal)
            self.confirmNiAlert.dismissWithAnimation(.normal)
        } else if niAlert == self.coinLessNiAlert {
            self.dismissWithAnimation(.normal)
            self.coinLessNiAlert.dismissWithAnimation(.normal)
            self.confirmNiAlert.dismissWithAnimation(.normal)
        }
    }
    
    func niAlert(niAlert: NIAlert, didselectAtIndex: Int) {
        if niAlert == self {
            if didselectAtIndex == 1 {
                niAlert.dismissWithAnimation(.normal)
            } else if didselectAtIndex == 0 {
                // 确认抽蛋页面
                self.confirmNiAlert.delegate = self
                self.confirmNiAlert.dict = NSMutableDictionary(objects: ["", "抽蛋", "在上方随便选一个蛋！", []],
                    forKeys: ["img", "title", "content", "buttonArray"])
                let img1 = self.setupEgg(40, named: "pet_egg1")
                let img2 = self.setupEgg(104, named: "pet_egg2")
                let img3 = self.setupEgg(168, named: "pet_egg3")
                img1.tag = 1
                img2.tag = 2
                img3.tag = 3
                self.confirmNiAlert._containerView?.addSubview(img1)
                self.confirmNiAlert._containerView?.addSubview(img2)
                self.confirmNiAlert._containerView?.addSubview(img3)
                self.dismissWithAnimationSwtich(self.confirmNiAlert)
            }
        } else if niAlert == lotteryNiAlert {
            if didselectAtIndex == 0 {
                let card = (NSBundle.mainBundle().loadNibNamed("Card", owner: self, options: nil) as NSArray).objectAtIndex(0) as! Card
                let petName = self.petData.stringAttributeForKey("name")
                let petImage = self.petData.stringAttributeForKey("image")
                let content = "我在念里拿到了可爱的「\(petName)」"
                card.content = content
                card.widthImage = "360"
                card.heightImage = "360"
                card.url = "http://img.nian.so/pets/\(petImage)!d"
                let img = card.getCard()
                let avc = SAActivityViewController.shareSheetInView([img, content], applicationActivities: [], isStep: true)
                delegateShare?.onShare(avc)
            } else if didselectAtIndex == 1 {
                self.dismissWithAnimation(.normal)
                self.confirmNiAlert.dismissWithAnimation(.normal)
                self.lotteryNiAlert.dismissWithAnimation(.normal)
            }
        } else if niAlert == coinLessNiAlert {
            self.dismissWithAnimation(.normal)
            self.confirmNiAlert.dismissWithAnimation(.normal)
            self.coinLessNiAlert.dismissWithAnimation(.normal)
        }
    }
    
    func onEggTouchDown(sender: UIButton) {
        sender.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
    }
    
    func onEggTouchCancel(sender: UIButton) {
        sender.backgroundColor = UIColor.clearColor()
    }
    
    func onEggTouchUp(sender: UIButton) {
        let tag = sender.tag
        sender.backgroundColor = UIColor.clearColor()
        self.confirmNiAlert.titleLabel?.hidden = true
        self.confirmNiAlert.contentLabel?.hidden = true
        for view: AnyObject in self.confirmNiAlert._containerView!.subviews {
            if view is UIButton {
                if view as! UIButton != sender {
                    (view as! UIButton).removeFromSuperview()
                }
            }
        }
        UIView.animateWithDuration(0.6, animations: { () -> Void in
            sender.setX(104)
        })
        let ac = UIActivityIndicatorView(frame: CGRectMake(121, 150, 30, 30))
        ac.color = SeaColor
        ac.hidden = false
        ac.startAnimating()
        self.confirmNiAlert._containerView!.addSubview(ac)
        Api.postPetLottery(tag) { json in
            if json != nil {
                let err = json!.objectForKey("error") as! NSNumber
                if err == 0 {
                    // 抽到宠物
                    self.petData = (json!.objectForKey("data") as! NSDictionary).objectForKey("pet") as! NSDictionary
                    let petName = self.petData.stringAttributeForKey("name")
                    let petImage = self.petData.stringAttributeForKey("image")
//                    let petId = self.petData.stringAttributeForKey("id")
                    self.lotteryNiAlert.delegate = self
//                    
//                    // 从缓存里拉取宠物列表
//                    if let tempDataArray = Cookies.get("pets") as? NSDictionary {
//                        let tempData = tempDataArray.objectForKey("data") as! NSDictionary
//                        let tempArr = tempData.objectForKey("pets") as! NSArray
//                        for data in tempArr {
//                            if let d = data as? NSDictionary {
//                                let id = d.stringAttributeForKey("id")
//                                let owned = d.stringAttributeForKey("owned")
//                                if id == petId && owned == "1" {
//                                    print("是新宠物！！！")
//                                }
//                            }
//                        }
//                    }
                    
                    self.lotteryNiAlert.dict = NSMutableDictionary(objects: ["http://img.nian.so/pets/\(petImage)!d", petName, "你获得了一个\(petName)", ["分享", "好"]],
                        forKeys: ["img", "title", "content", "buttonArray"])
                    self.confirmNiAlert.dismissWithAnimationSwtich(self.lotteryNiAlert)
                    
                    // 抽蛋成功扣念币 
                    globalWillNianReload = 1
                    self.delegateShare?.saEgg?(self, lotteryResult: self.petData)
                    
                } else if err == 2 {
                    self.coinLessNiAlert.delegate = self
                    self.coinLessNiAlert.dict = NSMutableDictionary(objects: [UIImage(named: "coinless")!, "念币不足", "没有足够的念币...", ["哦"]],
                        forKeys: ["img", "title", "content", "buttonArray"])
                    self.confirmNiAlert.dismissWithAnimationSwtich(self.coinLessNiAlert)
                } else {
                    self.coinLessNiAlert.delegate = self
                    self.coinLessNiAlert.dict = NSMutableDictionary(objects: [UIImage(named: "coinless")!, "奇怪的错误", "遇到了一个奇怪的错误", ["哦"]],
                        forKeys: ["img", "title", "content", "buttonArray"])
                    self.confirmNiAlert.dismissWithAnimationSwtich(self.coinLessNiAlert)
                }
            }
        }
    }
    
    func setupEgg(x: CGFloat, named: String) -> UIButton {
        let button = UIButton(frame: CGRectMake(x, 40, 64, 80))
        button.addTarget(self, action: "onEggTouchDown:", forControlEvents: UIControlEvents.TouchDown)
        button.addTarget(self, action: "onEggTouchDown:", forControlEvents: UIControlEvents.TouchDragInside)
        button.addTarget(self, action: "onEggTouchUp:", forControlEvents: UIControlEvents.TouchUpInside)
        button.addTarget(self, action: "onEggTouchCancel:", forControlEvents: UIControlEvents.TouchDragOutside)
        button.setBackgroundImage(UIImage(named: named), forState: UIControlState())
        button.setBackgroundImage(UIImage(named: named), forState: UIControlState.Highlighted)
        button.layer.cornerRadius = 8
        return button
    }
}