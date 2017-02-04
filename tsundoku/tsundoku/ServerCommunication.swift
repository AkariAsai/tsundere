//
//  ServerCommunication.swift
//  tsundoku
//
//  Created by Hiroaki KARASAWA on 2017/02/04.
//  Copyright © 2017年 浅井紀子. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

let HOST_ADDRESS = "153.120.170.146"

// - 引数: user id
// - 返り値: 自分と友人の(username,読了ページ数,積読ページ数)の一覧
typealias UsersInfoOverview = [ String : (String, Int, Int) ]

func fetchFirstView(callback : @escaping (UsersInfoOverview) -> Void) {
    let overview = [
        "123" : (username: "Hiroaki KARASAWA", readNum: 1000, unreadNum: 2000),
        "124" : (username: "Kotatsu Shiraki", readNum: 2000, unreadNum: 2000),
        "125" : (username: "Akari Asai", readNum: 3000, unreadNum: 1000),
        "126" : (username: "Toby Chang", readNum: 1000, unreadNum: 5000),
        "127" : (username: "HOGE FUGA", readNum: 1000, unreadNum: 2000),
        "128" : (username: "PIYO PIYO", readNum: 2000, unreadNum: 2000),
        "129" : (username: "AIUEO KKKKK", readNum: 3000, unreadNum: 1000),
        "130" : (username: "MacBook Pro", readNum: 1000, unreadNum: 5000),
        "131" : (username: "MacBook Air", readNum: 1000, unreadNum: 2000),
        "132" : (username: "Mac Pro", readNum: 2000, unreadNum: 2000),
        "133" : (username: "MacBook", readNum: 3000, unreadNum: 1000),
        "134" : (username: "iMac", readNum: 1000, unreadNum: 5000)
    ]
    
    callback(overview)
    
    return // DEBUG
    
    let id = UserDefaults.standard.string(forKey: "id")
    
    Alamofire.request("https://\(HOST_ADDRESS)/\(id)/page_number", method: .post, parameters: nil, encoding: JSONEncoding.default).responseJSON { response in
        print("fetchFirstView: Status Code: \(response.result.isSuccess)")
        
        guard let object = response.result.value else { return }
        let json = JSON(object)
        
        var overview : [ String: (String, Int, Int) ] = [ : ]
        let user_id = json["user"]["user_id"].string!
        let user_name = json["user"]["user_name"].string!
        let read_pages = json["user"]["page_number"]["read_pages"].intValue
        let unread_pages = json["user"]["page_number"]["unread_pages"].intValue
        
        overview[user_id] = (user_name, read_pages, unread_pages)
        
        json["friends"].arrayValue.forEach {
            overview[$0["user_id"].string!] = ($0["user_name"].string!, $0["page_number"]["read_pages"].intValue, $0["page_number"]["unread_pages"].intValue)
        }
        
        callback(overview)
    }
}

func pushUserData(id : String, name : String, friends : [[ String : String ]], callback : (Void) -> Void) {
    let data : [String : Any] = [ "id" : id, "name" : name, "friends" : friends ]
    
    Alamofire.request("https://\(HOST_ADDRESS)/user/login", method: .post, parameters: data, encoding: JSONEncoding.default).responseJSON { response in
        print("pushUserData: Status Code: \(response.result.isSuccess)")
    }
}


