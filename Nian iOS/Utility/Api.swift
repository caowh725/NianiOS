//
//  Nian.swift
//  Nian iOS
//
//  Created by vizee on 14/11/7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//i

import UIKit

struct Api {
    
    private static var s_load = false
    private static var s_uid: String!
    private static var s_shell: String!
    
    private static func loadCookies() {
        if (!s_load) {
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            s_uid = Sa.objectForKey("uid") as String
            s_shell = Sa.objectForKey("shell") as String
            s_load = true
        }
    }
    
    static func requestLoad() {
        s_load = false
    }
    
    static func getCookie() -> (String, String) {
        loadCookies()
        return (s_uid, s_shell)
    }
    
    static func getUserMe(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/user.php?uid=\(s_uid)&myuid=\(s_uid)", callback: callback)
    }
    
    static func getCoinDetial(page: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/coindes.php?uid=\(s_uid)&shell=\(s_shell)&page=\(page)", callback: callback)
    }
    
    static func getExploreFollow(page: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/explore_fo.php?page=\(page)&uid=\(s_uid)", callback: callback)
    }
    
    static func getExploreDynamic(page: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/explore_like.php?page=\(page)&uid=\(s_uid)", callback: callback)
    }
    
    static func getExploreHot(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/explore_hot.php", callback: callback)
    }
    
    static func getExploreNew(page: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/explore_all.php?page=\(page)", callback: callback)
    }
    
    static func postReport(type: String, id: String, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/a.php", content: "uid=\(s_uid)&&shell\(s_shell)", callback: callback)
    }
    
    static func getFriendFromWeibo(page: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/weibo.php?uid=\(s_uid)&shell=\(s_shell)&page=\(page)", callback: callback)
    }
    
    static func getFriendFromTag(page: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/friend_tag.php?uid=\(s_uid)&shell=\(s_shell)&page=\(page)", callback: callback)
    }
    
    static func postLikeStep(sid: String, like: Int, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/like_query.php", content: "uid=\(s_uid)&&shell=\(s_shell)&&step=\(sid)&&like=\(like)", callback)
    }
    
    static func postFollow(uid: String, follow: Int, callback: V.StringCallback) {
        loadCookies()
        V.httpPostForString("http://nian.so/api/fo.php", content: "uid=\(uid)&&myuid=\(s_uid)&&shell=\(s_shell)&&fo=\(follow)", callback: callback)
    }
    
    static func postCircle(page: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/circle_list.php", content: "uid=\(s_uid)&&shell=\(s_shell)&&page=\(page)", callback: callback)
    }
    
    static func getLevelCalendar(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/calendar.php?uid=\(s_uid)", callback: callback)
    }
    
    static func getUserTop(uid:Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/user.php?uid=\(uid)&myuid=\(s_uid)", callback: callback)
    }
    
    static func getDreamNewest(callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/addstep_dream.php?uid=\(s_uid)&shell=\(s_shell)", callback: callback)
    }
    
    static func getDreamTag(tag:Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/circle_join_dream.php?uid=\(s_uid)&shell=\(s_shell)&tag=\(tag)", callback: callback)
    }
    
    static func getCircleJoinConfirm(circle:String, dream:String, word:String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/circle_notice_confirm.php?uid=\(s_uid)&shell=\(s_shell)&circle=\(circle)&dream=\(dream)&word=\(word)", callback: callback)
    }
    
    static func getCircleJoinConfirmOK(id:String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/circle_confirm_ok.php?uid=\(s_uid)&shell=\(s_shell)&id=\(id)", callback: callback)
    }
    
    static func getCircleDetail(circle:String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/circle_detail.php?uid=\(s_uid)&id=\(circle)", callback: callback)
    }
    
    static func postIapVerify(transactionId: String, data: NSData, callback: V.JsonCallback) {
        loadCookies()
        var receiptData = ["receipt-data" : data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)]
        var err: NSError?
        var jsonData = NSJSONSerialization.dataWithJSONObject(receiptData, options: NSJSONWritingOptions.allZeros, error: &err)
        V.httpPostForJson("http://nian.so/api/iap_verify.php", content: "uid=\(s_uid)&shell=\(s_shell)&transaction_id=\(transactionId)&data=\(jsonData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros))", callback: callback)
    }
    
    static func postLabTrip(id: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/lab_trip.php", content: "id=\(id)&&uid=\(s_uid)&&shell=\(s_shell)", callback: callback)
    }
    
    static func postCircleNew(name: String, content: String, img: String, privateType: Int, tag: Int, dream: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/circle_new.php", content: "uid=\(s_uid)&shell=\(s_shell)&title=\(name)&content=\(content)&img=\(img)&private=\(privateType)&tag=\(tag)&dream=\(dream)", callback: callback)
    }
    
    static func postCircleEdit(name: String, content: String, img: String, privateType: Int, ID: Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/circle_edit.php", content: "id=\(ID)&uid=\(s_uid)&shell=\(s_shell)&title=\(name)&content=\(content)&img=\(img)&private=\(privateType)", callback: callback)
    }
    
    static func postCircleQuit(Id: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/circle_quit.php", content: "uid=\(s_uid)&shell=\(s_shell)&id=\(Id)", callback: callback)
    }
    
    static func postCircleDelete(Id: String, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/circle_delete.php", content: "uid=\(s_uid)&shell=\(s_shell)&id=\(Id)", callback: callback)
    }
    
    static func postCircleFire(Id: String, fireuid:Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/circle_fire.php", content: "uid=\(s_uid)&shell=\(s_shell)&id=\(Id)&fireuid=\(fireuid)", callback: callback)
    }
    
    static func postCirclePromo(Id: String, promouid:Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/circle_promote.php", content: "uid=\(s_uid)&shell=\(s_shell)&id=\(Id)&promouid=\(promouid)", callback: callback)
    }
    
    static func postCircleDemo(Id: String, demouid:Int, callback: V.JsonCallback) {
        loadCookies()
        V.httpPostForJson("http://nian.so/api/circle_demote.php", content: "uid=\(s_uid)&shell=\(s_shell)&id=\(Id)&demouid=\(demouid)", callback: callback)
    }
    
    static func getCircleExplore(page:String, callback: V.JsonCallback) {
        loadCookies()
        V.httpGetForJson("http://nian.so/api/circle_explore.php?page=\(page)", callback: callback)
    }
    
}