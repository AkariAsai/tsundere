import Foundation

// - 引数: user id
// - 返り値: 自分と友人の(username,読了ページ数,積読ページ数)の一覧
typealias UsersInfoOverview = [ Int : (String, Int, Int) ]

func fetchFirstView(callback : (UsersInfoOverview) -> Void) {
    let overview = [
        123 : (username: "Hiroaki KARASAWA", readNum: 1000, unreadNum: 2000),
        124 : (username: "Kotatsu Shiraki", readNum: 2000, unreadNum: 2000),
        125 : (username: "Akari Asai", readNum: 3000, unreadNum: 1000),
        126 : (username: "Toby Chang", readNum: 1000, unreadNum: 5000),
        127 : (username: "HOGE FUGA", readNum: 1000, unreadNum: 2000),
        128 : (username: "PIYO PIYO", readNum: 2000, unreadNum: 2000),
        129 : (username: "AIUEO KKKKK", readNum: 3000, unreadNum: 1000),
        130 : (username: "MacBook Pro", readNum: 1000, unreadNum: 5000),
        131 : (username: "MacBook Air", readNum: 1000, unreadNum: 2000),
        132 : (username: "Mac Pro", readNum: 2000, unreadNum: 2000),
        133 : (username: "MacBook", readNum: 3000, unreadNum: 1000),
        134 : (username: "iMac", readNum: 1000, unreadNum: 5000)
    ];
    
    callback(overview)
}
