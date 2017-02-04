//
//  ServerCommunication.swift
//  tsundoku
//
//  Created by Hiroaki KARASAWA on 2017/02/04.
//  Copyright © 2017年 浅井紀子. All rights reserved.
//

import Foundation

// - 引数: user id
// - 返り値: 自分と友人の(username,読了ページ数,積読ページ数)の一覧


func fetchFirstView() -> [ Int : (String, Int, Int) ] {
    return [
        123 : (username: "Hiroaki KARASAWA", readNum: 1000, unreadNum: 2000)
    ];
}
