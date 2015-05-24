//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class DreamCellTop: UITableViewCell, UIGestureRecognizerDelegate{

    @IBOutlet var nickLabel:UILabel!
    @IBOutlet var dreamhead:UIImageView!
    @IBOutlet var View:UIView!
    @IBOutlet var labelDes:UILabel!
    @IBOutlet var btnMain:UIButton!
    @IBOutlet var viewRight:UIView!
    @IBOutlet var viewLeft:UIView!
    @IBOutlet var dotLeft:UIView!
    @IBOutlet var dotRight:UIView!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var numLeft:UIView!
    @IBOutlet var numMiddle:UIView!
    @IBOutlet var numRight:UIView!
    @IBOutlet var numLeftNum:UILabel!
    @IBOutlet var numMiddleNum:UILabel!
    @IBOutlet var numRightNum:UILabel!
    
    @IBOutlet var viewLineRight: UIView!
    @IBOutlet var viewLineLeft: UIView!
    @IBOutlet var viewBG: UIView!
    @IBOutlet var viewHolder: UIView!
    
    var dreamid:String = ""
    var desHeight:CGFloat = 0
    var panStartPoint:CGPoint!
    var toggle:Int = 0
    var panGesture:UIGestureRecognizer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.panGesture = UIPanGestureRecognizer(target: self, action: "pan:")
        self.panGesture.delegate = self
        self.View?.addGestureRecognizer(self.panGesture)
        self.btnMain.backgroundColor = SeaColor
        self.btnMain.hidden = true
        self.btnMain.alpha = 0
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.viewLeft.setX(globalWidth/2-160)
        self.viewRight.setX(globalWidth/2-160+globalWidth)
        self.viewBG.setWidth(globalWidth)
        self.btnMain.setX(globalWidth/2-50)
        self.dotLeft.setX(globalWidth/2-5)
        self.dotRight.setX(globalWidth/2+5)
        self.scrollView.setWidth(globalWidth)
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.contentSize =  CGSizeMake(8, 0)
    }
    
    func moveUp() {
        var bottom = self.nickLabel.bottom()
        
        self.viewRight.setY(0)
        self.viewBG.setY(0)
        self.btnMain.setY(bottom + 84)
        self.dotLeft.setY(bottom + 137)
        self.dotRight.setY(bottom + 137)
        
//        self.nickLabel.setY(self.nickLabel.frame.origin.y - 44)
//        self.dreamhead.setY(self.dreamhead.frame.origin.y - 44)
//        self.View.setY(self.View.frame.origin.y - 44)
//        self.viewLeft.setY(self.viewLeft.frame.origin.y - 44)
//        self.numLeft.setY(self.numLeft.frame.origin.y - 44)
//        self.numMiddle.setY(self.numMiddle.frame.origin.y - 44)
//        self.numRight.setY(self.numRight.frame.origin.y - 44)
//        self.numLeftNum.setY(self.numLeftNum.frame.origin.y - 44)
//        self.numMiddleNum.setY(self.numMiddleNum.frame.origin.y - 44)
//        self.numRightNum.setY(self.numRightNum.frame.origin.y - 44)
//        self.viewLineRight.setY(self.viewLineRight.frame.origin.y - 44)
//        self.viewLineLeft.setY(self.viewLineLeft.frame.origin.y - 44)
//        self.viewHolder.setY(self.viewHolder.frame.origin.y - 44)
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UILongPressGestureRecognizer) {
            return false
        }else{
            let panGesture = gestureRecognizer as! UIPanGestureRecognizer
            let panY = panGesture.locationInView(self).y
            let translation = panGesture.translationInView(self)
            if fabs(translation.y) > fabs(translation.x) {  //如果是往下划
                return false
            }else{
                return true
            }
        }
    }
    
    func pan(pan:UIPanGestureRecognizer){
        var point = pan.locationInView(self.View)
        if pan.state == UIGestureRecognizerState.Began {
            panStartPoint = point
        }
        if pan.state == UIGestureRecognizerState.Changed {
            var distanceX = pan.translationInView(self.View!).x
            self.View!.layer.removeAllAnimations()
            if self.toggle == 0 {
                var ratio:CGFloat = (distanceX > 0) ? 0.5 : 1
                self.viewLeft.frame.origin.x = distanceX * ratio + globalWidth/2 - 160
                self.viewRight.frame.origin.x = distanceX * ratio + globalWidth + globalWidth/2 - 160
            }else{
                var ratio:CGFloat = (distanceX > 0) ? 1 : 0.5
                self.viewLeft.frame.origin.x = distanceX * ratio - globalWidth + globalWidth/2 - 160
                self.viewRight.frame.origin.x = distanceX * ratio + globalWidth/2 - 160
            }
        }
        if pan.state == UIGestureRecognizerState.Ended {
            if panStartPoint.x > point.x {
                self.toggle = 1
                UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
                    self.viewLeft.frame.origin.x = -globalWidth + globalWidth/2 - 160
                    self.viewRight.frame.origin.x = globalWidth/2 - 160
                    self.dotLeft.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:0.05)
                    self.dotRight.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:0.1)
                    }, completion: { (finished:Bool) -> Void in
                        if !finished {
                            return
                        }
                })
            }else{
                self.toggle = 0
                UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
                    self.viewLeft.frame.origin.x = globalWidth/2 - 160
                    self.viewRight.frame.origin.x = globalWidth + globalWidth/2 - 160
                    self.dotLeft.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:0.1)
                    self.dotRight.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:0.05)
                    }, completion: { (finished:Bool) -> Void in
                        if !finished {
                            return
                        }
                })
            }
        }
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
    }
}
