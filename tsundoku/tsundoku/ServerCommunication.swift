import Foundation
import Alamofire
import SwiftyJSON

let HOST_ADDRESS = "app.ut-hackers.tk"

// - 引数: user id
// - 返り値: 自分と友人の(username,読了ページ数,積読ページ数)の一覧
typealias UsersInfoOverview = [ String : (String, Int, Int) ]

func fetchFirstView(callback : @escaping (UsersInfoOverview) -> Void) {
    let overview = [
        "123" : (username: "Hiroaki KARASAWA", readNum: 1000, unreadNum: 2000),
        "124" : (username: "Kotatsu Shiraki", readNum: 2000, unreadNum: 2000),
        "125" : (username: "Akari Asai", readNum: 3000, unreadNum: 1000),
        "126" : (username: "Toby Chang", readNum: 4000, unreadNum: 5000),
        "127" : (username: "HOGE FUGA", readNum: 5000, unreadNum: 2000),
        "128" : (username: "PIYO PIYO", readNum: 5000, unreadNum: 2000),
        "129" : (username: "AIUEO KKKKK", readNum: 5000, unreadNum: 1000),
        "130" : (username: "MacBook Pro", readNum: 6000, unreadNum: 5000),
        "131" : (username: "MacBook Air", readNum: 7000, unreadNum: 2000),
        "132" : (username: "Mac Pro", readNum: 8000, unreadNum: 2000),
        "133" : (username: "MacBook", readNum: 8000, unreadNum: 1000),
        "134" : (username: "iMac", readNum: 9000, unreadNum: 5000)
    ]
    
    callback(overview)
    
    return // DEBUG
    
    let id = UserDefaults.standard.string(forKey: "id")!
    
    Alamofire.request("https://\(HOST_ADDRESS)/user/\(id)/page_number").responseJSON { response in
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

func fetchBookList(callback: @escaping ([ Book ], [ Book ]) -> Void) {
    let id = UserDefaults.standard.string(forKey: "id")!
    Alamofire.request("https://\(HOST_ADDRESS)/user/\(id)/list").responseJSON { response in
        print("fetchBookList: Status Code: \(response.result.isSuccess)")
        guard let object = response.result.value else { return }
        let json = JSON(object)
        var read_books : [Book] = []
        var unread_books : [Book] = []
        
        json["read_books"].arrayValue.forEach {
            let title = $0["book"]["title"].string!
            let author = $0["book"]["author"].string!
            let isbn = $0["book"]["ISBN"].string!
            let page_number = $0["book"]["page_number"].intValue
            let image_url = $0["book"]["image_url"].string!
            
            read_books.append((title, author, isbn, image_url, page_number))
        }
        
        json["unread_books"].arrayValue.forEach {
            let title = $0["book"]["title"].string!
            let author = $0["book"]["author"].string!
            let isbn = $0["book"]["ISBN"].string!
            let page_number = $0["book"]["page_number"].intValue
            let image_url = $0["book"]["image_url"].string!
            
            unread_books.append((title, author, isbn, image_url, page_number))
        }
        
        callback(read_books, unread_books)
    }
}

func pushUserData(id : String, name : String, friends : [[ String : String ]], callback : (Void) -> Void) {
    let data : [String : Any] = [ "id" : id, "name" : name, "friends" : friends ]
    
    Alamofire.request("https://\(HOST_ADDRESS)/user/login", method: .post, parameters: data, encoding: JSONEncoding.default).responseJSON { response in
        print("pushUserData: Status Code: \(response.result.isSuccess)")
    }
}

// (タイトル, 著者名, ISBN、商品画像、ページ数)
typealias Book = (String, String, String, String, Int)

func searchBookAPI(keyword : String, callback : @escaping ([ Book ]) -> Void) {
    let data : [ String : AnyObject ] = [ "q" : keyword as AnyObject ]
    
    Alamofire.request("https://www.googleapis.com/books/v1/volumes", parameters: data).responseJSON { response in
        print("searchBookAPI: Status Code: \(response.result.isSuccess)")
        
        guard let object = response.result.value else { return }
        let json = JSON(object)
        var books : [Book] = []

        json["items"].arrayValue.forEach {
            let title = $0["volumeInfo"]["title"].string!
            let authors = $0["volumeInfo"]["authors"].arrayValue.map { $0.string! }.joined(separator: ",")
            let isbn = $0["volumeInfo"]["industryIdentifiers"][0]["identifier"].string ?? ""
            let image = $0["volumeInfo"]["imageLinks"]["smallThumbnail"].string ?? ""
            let pageCount = $0["volumeInfo"]["pageCount"].intValue
            
            books.append((title, authors, isbn, image, pageCount))
        }
        
        callback(books)
    }
}
