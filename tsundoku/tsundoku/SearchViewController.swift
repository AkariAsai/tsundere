import UIKit
import Alamofire

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate{
    
    var read_flag : Int = 0
    var suggestedBooks : [(title:String, author: String, ISBN: String, image_url: String, page_number: Int)] = []
    
    @IBOutlet weak var suggestTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBAction func didTapSearchButton(_ sender: Any) {
                    self.view.endEditing(true)
        searchBookAPI(keyword: searchTextField.text!, callback : {books in for book in books {
            print(book)
            
            self.suggestedBooks.append((book.0, book.1, book.2, book.3, book.4))
            }
            self.suggestTableView.isHidden = false
            
            for view in  self.view.subviews{
                if view is UIImageView{
                    view.removeFromSuperview()
                }
            }
            self.suggestTableView.reloadData()
        })
        
    }
    
    typealias Book = (String, String, String, String, Int)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        self.suggestTableView.isHidden = true
        let beforeSearchImgView = UIImageView.init(frame:CGRect(x: (self.view.bounds.width - 200)/2, y: self.view.bounds.maxY/2, width: 200, height: 200))
        beforeSearchImgView.image = (image:#imageLiteral(resourceName: "beforeSearch"))
        self.view.addSubview(beforeSearchImgView)
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
        let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate;
        let alertButton = UIAlertController(title: book.title + "を追加しますか？", message: "", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title:"OK", style: .default, handler: {
            (action:UIAlertAction!) -> Void in
            let data : [String: Any] = ["title":book.title, "author":book.author, "ISBN":book.ISBN, "page_number":book.page_number, "image_url":book.image_url, "read_flag":appDelegate.read_flag];
            
            Alamofire.request("https://app.ut-hackers.tk/user/\(id)/book/add", method: .post, parameters: data).responseJSON { response in
                print("searchBookAPI: Status Code: \(response.result.isSuccess)")
            }
            
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "indivisual") as! IndividualPageViewController
            self.present(nextView, animated: true, completion: nil)
            print("セル番号：(indexPath.row) セルの内容：(titles[indexPath.row])")
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action) -> Void in
            print("Cancel")
        })
        
        alertButton.addAction(defaultAction)
        alertButton.addAction(cancelAction)
        self.present(alertButton, animated: true, completion: nil);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
