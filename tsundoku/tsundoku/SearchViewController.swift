import UIKit
import Alamofire

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate{
    
    var read_flag : Int = 0
    var suggestedBooks : [(title:String, author: String, ISBN: String, image_url: String, page_number: Int)] = []
    
    @IBOutlet weak var suggestTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBAction func didTapSearchButton(_ sender: Any) {
        searchBookAPI(keyword: searchTextField.text!, callback : {books in for book in books {
            print(book)
            self.suggestedBooks.append((book.0, book.1, book.2, book.3, book.4))
            }
            print(self.suggestedBooks)
            self.suggestTableView.reloadData()
        })
        
    }
    
    typealias Book = (String, String, String, String, Int)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
    }
    
    //GoogleBooksAPIから返される情報の数によって要更新
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestedBooks.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let suggestionCell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexPath)
        
        // セルに表示する値を設定する
        suggestionCell.textLabel!.text = suggestedBooks[indexPath.row].title
        suggestionCell.detailTextLabel!.text = suggestedBooks[indexPath.row].author
        return suggestionCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = UserDefaults.standard.object(forKey: "id")!
        let book = suggestedBooks[indexPath.row];
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate;
        
        let data : [String: Any] = ["title":book.title, "author":book.author, "ISBN":book.ISBN, "page_number":book.page_number, "image_url":book.image_url, "read_flag":appDelegate.read_flag];
        
        Alamofire.request("https://app.ut-hackers.tk/user/\(id)/book/add", method: .post, parameters: data).responseJSON { response in
            print("searchBookAPI: Status Code: \(response.result.isSuccess)")
        }
        print("セル番号：(indexPath.row) セルの内容：(titles[indexPath.row])")
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
