//
//  PhotosViewController.swift
//  InstaDude
//
//  Created by Ashley Robinson on 19/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import UIKit
import StoreKit

class CoinViewController: UIViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, LTMorphingLabelDelegate {
    
    typealias CoinCellData = (icon: String, title: String, description: String, cost: String)
    
    let coinItems: [CoinCellData] = [
        ("12", "12 念币", "", "¥ 6.00"),
        ("30", "30 念币", "", "¥ 12.00"),
        ("65", "65 念币", "", "¥ 25.00"),
        ("140", "140 念币", "", "¥ 50.00"),
        ("295", "295 念币", "", "¥ 98.00")
    ]
    
    let propItems: [CoinCellData] = [
        ("trip", "请假", "72小时不被停号", "2 念币"),
        ("star_line", "毕业证", "永不停号", "100 念币")
    ]
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var viewCircleBackground:UIView!
    @IBOutlet var viewTop: UIView!
    @IBOutlet var labelCoin: LTMorphingLabel!
    @IBOutlet var viewCircle: UIView!
    var top:CAShapeLayer!
    var navView: UIView!
    var memorySafe = [Payment]()
    
    override func viewDidLoad() {
        setupViews()
    }
    
    func setupViews() {
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.view.addSubview(self.navView)
        viewBack(self)
        self.navigationController!.interactivePopGestureRecognizer.delegate = self
        
        // 关闭了念币详情
        // self.viewCircle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onHeaderCoinClick"))
        
        self.scrollView.contentSize.height = 800
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 0, 0))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "念币"
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
        self.view.backgroundColor = BGColor
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.allowsSelection = false
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        var header = UIView(frame: CGRectMake(0, 0, globalWidth, 200))
        
        self.viewCircleBackground.layer.cornerRadius = 84
        self.viewCircleBackground.layer.masksToBounds = true
        self.viewCircleBackground.layer.borderColor = UIColor.whiteColor().CGColor
        self.viewCircleBackground.layer.borderWidth = 8
        
        self.labelCoin.textColor = SeaColor
        self.labelCoin.morphingEffect = .Evaporate
        self.labelCoin.delegate = self
        
        self.SACircle(1)
        self.viewTop.setHeight(234)
        
        Api.getUserMe() { json in
            if json != nil {
                var sa: AnyObject! = json!.objectForKey("user")
                var coin: String! = sa.objectForKey("coin") as String
                self.levelLabelCount(coin.toInt()!)
            }
        }
    }
    
    func levelLabelCount(totalNumber:Int){
        var x = Int(floor(Double(totalNumber) / 20) + 1)
        var y:Double = 0
        var z = 0
        for i:Int in 0...20 {
            z = z + x
            var j = z + i
            if j < totalNumber {
                var textI = "0"
                if j <= 0 {
                    textI = "\(j)"
                }else if j >= 10 {
                    textI = "\(j)"
                }else{
                    textI = "0\(j)"
                }
                y = y + 0.1
                delay( y , {
                    self.labelCoin.text = textI
                })
            }else{
                delay( y + 0.1 , {
                    var textI = "0"
                    if totalNumber <= 0 {
                        textI = "\(totalNumber)"
                    }else if totalNumber >= 10 {
                        textI = "\(totalNumber)"
                    }else{
                        textI = "0\(totalNumber)"
                    }
                    
                    self.labelCoin.text = textI
                })
                break
            }
        }
    }
    
    func back() {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return coinItems.count
        case 1:
            return propItems.count
        default:
            break
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CoinCell", forIndexPath: indexPath) as? CoinCell
        cell!.btnBuy.tag = indexPath.row + 100 * indexPath.section
        var (icon, title, desp, cost) = indexPath.section == 0 ? coinItems[indexPath.row] : propItems[indexPath.row]
        cell!.setupView(icon, title: title, description: desp, cost: cost, sectionNumber: indexPath.section)
        if indexPath.section == 0 {
            cell!.btnBuy.addTarget(self, action: "onBuyCoinClick:", forControlEvents: UIControlEvents.TouchUpInside)
        } else {
            cell!.btnBuy.addTarget(self, action: "onBuyPropClick:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let (_, _, desp, _) = indexPath.section == 0 ? coinItems[indexPath.row] : propItems[indexPath.row]
        return CoinCell.getDespHeight(desp) + 62
    }
    
    func onHeaderCoinClick() {
        var storyboard = UIStoryboard(name: "CoinDetail", bundle: nil)
        var viewController = storyboard.instantiateViewControllerWithIdentifier("CoinDetailViewController") as UIViewController
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    func onBuyCoinClick(sender: UIButton) {
        var tag = sender.tag
        var coinData = coinItems[tag]
        showFilm("购买念币", prompt: "立刻获得 \(coinData.title)", button: coinData.cost) {
            film in
            var payment = Payment() {
                state, data in
                if film.hidden {
                    film.removeFromSuperview()
                    switch state {
                    case .Purchased:
                        self.view.showTipText("刚刚一笔支付成功了，刷新念币看看！", delay: 1)
                        break
                    case .Failed:
                        break
                    case .Cancelled:
                        break
                    default:
                        break
                    }
                } else {
                    var prompt = "Sa爱你呀"
                    switch state {
                    case .OnPurchasing:
                        prompt = "正在刷爆你的卡"
                        break
                    case .OnVerifying:
                        prompt = "正在英俊地清点念币"
                        break
                    case .Cancelled:
                        prompt = "支付已取消"
                        film.showOK()
                        break
                    case .Failed:
                        prompt = "支付失败"
                        film.showError("再试一试")
                        break
                    case .Purchased:
                        prompt = "念币买好啦"
                        film.showOK()
                        self.levelLabelCount((data!["coin"] as String).toInt()!)
                        globalWillNianReload = 1
                        break
                    case .VerifyFailed:
                        prompt = "出了点问题...\n如果念币没到账，记得和管理员联系！"
                        film.showOK()
                        break
                    default:
                        break
                    }
                    film.labelDes.text = prompt
                }
            }
            switch tag {
            case 0:
                payment.pay(product_coin12)
                break
            case 1:
                payment.pay(product_coin30)
                break
            case 2:
                payment.pay(product_coin65)
                break
            case 3:
                payment.pay(product_coin140)
                break
            case 4:
                payment.pay(product_coin295)
                break
            default:
                break
            }
            self.memorySafe.append(payment)
        }
    }
    
    func onBuyPropClick(sender: UIButton) {
        var title = ""
        var des = ""
        var button = ""
        switch sender.tag {
        case 100:   //请假
            title = "请假"
            des = "72 小时内不会被停号\n出去玩时记得买张请假条"
            button = "2 念币"
            break
        case 101:   //毕业
            title = "毕业证"
            des = "永不封号\n希望你已从念获益"
            button = "100 念币"
            break
        default:
            break
        }
        var tag = sender.tag
        showFilm(title, prompt: des, button: button) {
            film in
            Api.postLabTrip("\(tag)") {
                json in
                if film.hidden {
                    film.superview!.removeFromSuperview()
                } else {
                    if json != nil {
                        if json!["success"] as String == "1" {
                            film.showOK()
                            self.levelLabelCount((json!["coin"] as String).toInt()!)
                            globalWillNianReload = 1
                        }else if json!["success"] as String == "2" {
                            film.showError("念币不足")
                        }else if json!["success"] as String == "3" {
                            film.showError("毕业过啦")
                        }
                    }else{
                        film.showError("念没有踩你，再试试")
                    }
                }
            }
        }
    }
    
    let FILM_TAG = 21233
    
    func showFilm(title: String, prompt: String, button: String, callback: (FilmCell) -> Void) {
        var viewFilm = ILTranslucentView(frame: CGRectMake(0, 0, globalWidth, globalHeight))
        viewFilm.alpha = 0
        viewFilm.translucentAlpha = 1
        viewFilm.translucentStyle = UIBarStyle.Default
        viewFilm.translucentTintColor = UIColor.clearColor()
        viewFilm.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
        viewFilm.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onFilmTap:"))
        viewFilm.userInteractionEnabled = true
        var nib = NSBundle.mainBundle().loadNibNamed("Film", owner: self, options: nil) as NSArray
        var viewFilmDialog: FilmCell = nib.objectAtIndex(0) as FilmCell
        viewFilmDialog.frame.origin.x = ( globalWidth - 270 ) / 2
        viewFilmDialog.frame.origin.y = -270
        viewFilmDialog.labelTitle.text = title
        viewFilmDialog.labelDes.text = prompt
        viewFilmDialog.labelDes.setHeight(prompt.stringHeightWith(12, width: 200))
        viewFilmDialog.btnBuy.setTitle(button, forState: UIControlState.Normal)
        viewFilmDialog.btnBuy.setY(viewFilmDialog.labelDes.bottom()+22)
        viewFilmDialog.callback = callback;
        viewFilmDialog.tag = FILM_TAG
        viewFilm.addSubview(viewFilmDialog)
        view.addSubview(viewFilm)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            viewFilm.alpha = 1
            viewFilmDialog.frame.origin.y = (globalHeight - globalWidth)/2 + 45
        })
        delay(0.3, { () -> () in
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                viewFilmDialog.frame.origin.y = (globalHeight - globalWidth)/2 + 25
            })
        })
    }
    
    func onFilmTap(sender: UIGestureRecognizer){
        UIView.animateWithDuration(0.3, animations: {
            () -> Void in
            sender.view!.alpha = 0
            }, completion: {
                finish in
                var v = sender.view!.viewWithTag(self.FILM_TAG) as? FilmCell
                if v != nil && !v!.closeable {
                    sender.view!.hidden = true
                } else {
                    sender.view!.removeFromSuperview()
                }
        })
    }
    
    func SACircle(float:CGFloat){
        self.top = CAShapeLayer()
        var path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 160, 80)
        CGPathAddCurveToPoint(path, nil, 160, 35.82, 124.18, 0, 80, 0)
        CGPathAddCurveToPoint(path, nil, 35.82, 0, 0, 35.82, 0, 80)
        CGPathAddCurveToPoint(path, nil, 0, 124.18, 35.82, 160, 80, 160)
        CGPathAddCurveToPoint(path, nil, 124.18, 160, 160, 124.18, 160, 80)
        CGPathAddCurveToPoint(path, nil, 160, 35.82, 124.18, 0, 80, 0)
        self.top.path = path
        self.top.strokeColor = SeaColor.CGColor
        self.top.lineWidth = 8
        self.top.lineCap = kCALineCapRound
        self.top.masksToBounds = true
        let strokingPath = CGPathCreateCopyByStrokingPath(top.path, nil, 8, kCGLineCapRound, kCGLineJoinMiter, 4)
        self.top.bounds = CGPathGetPathBoundingBox(strokingPath)
        self.top.anchorPoint = CGPointMake(0, 0)
        self.top.position = CGPointZero
        self.top.strokeStart = 0
        self.top.strokeEnd = 0
        self.top.fillColor = UIColor.clearColor().CGColor
        self.top.actions = [
            "strokeStart": NSNull(),
            "strokeEnd": NSNull(),
            "transform": NSNull()
        ]
        self.viewCircle.layer.addSublayer(top)
        delay(0.5, { () -> () in
            let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
            strokeEnd.toValue = 0.8 * float
            strokeEnd.duration = 1
            self.top.SAAnimation(strokeEnd)
        })
    }
}