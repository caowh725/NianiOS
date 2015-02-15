//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class MeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    let identifier = "LetterCell"
    var tableView:UITableView!
    var dataArray = NSMutableArray()
    var Id:String = ""
    var numLeft: String = ""
    var numMiddel: String = ""
    var numRight: String = ""
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        SALoadData()
        SALoadTop()
    }
    
    func noticeShare() {
        SALoadData()
        SALoadTop()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewLoadingHide()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "noticeShare", object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "Letter", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        noticeShare()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "noticeShare", name: "noticeShare", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "Letter:", name: "Letter", object: nil)
    }
    
    func Letter(noti: NSNotification) {
        self.SALoadData()
    }
    
    func setupViews() {
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        var labelNav = UILabel(frame: CGRectMake(0, 20, globalWidth, 44))
        labelNav.text = "消息"
        labelNav.textColor = UIColor.whiteColor()
        labelNav.font = UIFont.systemFontOfSize(17)
        labelNav.textAlignment = NSTextAlignment.Center
        navView.addSubview(labelNav)
        self.view.addSubview(navView)
        
        self.tableView = UITableView(frame:CGRectMake(0, 64, globalWidth, globalHeight - 64 - 49))
        self.tableView!.delegate = self;
        self.tableView!.dataSource = self;
        self.tableView!.backgroundColor = BGColor
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        var nib = UINib(nibName:"LetterCell", bundle: nil)
        var nib2 = UINib(nibName:"MeCellTop", bundle: nil)
        
        self.tableView!.registerNib(nib, forCellReuseIdentifier: identifier)
        self.tableView!.registerNib(nib2, forCellReuseIdentifier: "MeCellTop")
        self.tableView!.tableFooterView = UIView(frame: CGRectMake(0, 0, globalWidth, 20))
        self.view.addSubview(self.tableView!)
    }
    
    func SALoadTop() {
        self.viewLoadingShow()
        var isLoaded = 0
        delay(3, {
            self.viewLoadingHide()
            if isLoaded == 0 {
                self.view.showTipText("念没有踩你，再试试看", delay: 2)
            }
        })
        Api.postLetter() { json in
            if json != nil {
                isLoaded = 1
                self.viewLoadingHide()
                self.numLeft = json!["notice_reply"] as String
                self.numMiddel = json!["notice_like"] as String
                self.numRight = json!["notice_news"] as String
                self.tableView.reloadData()
            }
        }
    }
    
    func SALoadData(){
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safename = Sa.objectForKey("user") as String
        let (resultCircle, errCircle) = SD.executeQuery("SELECT circle FROM `letter` GROUP BY circle ORDER BY lastdate DESC")
        self.dataArray.removeAllObjects()
        for row in resultCircle {
            var id = (row["circle"]?.asString())!
            var title = "玩家 #\(id)"
            let (resultDes, err) = SD.executeQuery("select * from letter where circle = '\(id)' and uid != '\(safeuid)' order by id desc limit 1")
            if resultDes.count > 0 {
                for row in resultDes {
                    title = (row["name"]?.asString())!
                }
            }else if safeuid == id {
                title = safename
            }
            var data = NSDictionary(objects: [id, title], forKeys: ["id", "title"])
            self.dataArray.addObject(data)
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
            if self.dataArray.count == 0 {
                var viewHeader = UIView(frame: CGRectMake(0, 0, globalWidth, 200))
                var viewQuestion = viewEmpty(globalWidth, content: "这里是空的\n要去给好友写信吗")
                viewQuestion.setY(70)
                var btnGo = UIButton()
                btnGo.setButtonNice("  嗯！")
                btnGo.setX(globalWidth/2-50)
                btnGo.setY(viewQuestion.bottom())
                btnGo.addTarget(self, action: "onBtnGoClick", forControlEvents: UIControlEvents.TouchUpInside)
                viewHeader.addSubview(viewQuestion)
                viewHeader.addSubview(btnGo)
                self.tableView.tableFooterView = viewHeader
            }else{
                self.tableView.tableFooterView = UIView()
            }
        })
    }
    
    func onBtnGoClick() {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var LikeVC = LikeViewController()
        LikeVC.Id = safeuid
        LikeVC.urlIdentify = 1
        self.navigationController!.pushViewController(LikeVC, animated: true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return self.dataArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier("MeCellTop", forIndexPath: indexPath) as? MeCellTop
            cell!.numLeft.text = self.numLeft
            cell!.numMiddle.text = self.numMiddel
            cell!.numRight.text = self.numRight
            cell!.numLeft.setColorful()
            cell!.numMiddle.setColorful()
            cell!.numRight.setColorful()
            return cell!
        }else{
            var cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? LetterCell
            var index = indexPath.row
            var data = self.dataArray[index] as NSDictionary
            cell!.data = data
            if let tag = data.stringAttributeForKey("uid").toInt() {
                cell!.imageHead.tag = tag
                cell!.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUserClick:"))
            }
            return cell!
        }
    }
    
    func onUserClick(sender:UIGestureRecognizer) {
        var tag = sender.view!.tag
        var UserVC = PlayerViewController()
        UserVC.Id = "\(tag)"
        self.navigationController?.pushViewController(UserVC, animated: true)
    }
    
    func onDreamClick(sender:UIGestureRecognizer){
        var tag = sender.view!.tag
        var dreamVC = DreamViewController()
        dreamVC.Id = "\(tag)"
        self.navigationController!.pushViewController(dreamVC, animated: true)
    }
    
    func userclick(sender:UITapGestureRecognizer){
        var UserVC = PlayerViewController()
        UserVC.Id = "\(sender.view!.tag)"
        self.navigationController!.pushViewController(UserVC, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 75
        }else{
            return 81
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            var index = indexPath.row
            var data = self.dataArray[index] as NSDictionary
            var letterVC = LetterController()
            if let id = data.stringAttributeForKey("id").toInt() {
                var title = data.stringAttributeForKey("title")
                letterVC.ID = id
                letterVC.circleTitle = title
                self.navigationController?.pushViewController(letterVC, animated: true)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController!.interactivePopGestureRecognizer.enabled = false
    }
}

extension UILabel {
    func setColorful(){
        if let content = self.text?.toInt() {
            if content == 0 {
                self.textColor = UIColor.blackColor()
            }else{
                self.textColor = SeaColor
            }
        }else{
            self.textColor = UIColor.blackColor()
        }
    }
}