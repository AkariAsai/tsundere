import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate{
    
    var suggestedBooks : [(name:String, author: String)] = []
    
    @IBOutlet weak var suggestTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBAction func didTapSearchButton(_ sender: Any) {
        searchBookAPI(keyword: searchTextField.text!, callback : {books in for book in books {
            print(book)
            self.suggestedBooks.append((book.0, book.1))
            }
            print("hello")
            print(self.suggestedBooks)
            self.suggestTableView.reloadData()
        })
        
    }
    
    typealias Book = (String, String, String, String, Int)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        //searchTextField.addTarget(self, action: #selector(SearchViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
    }
    
    //GoogleBooksAPIから返される情報の数によって要更新
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestedBooks.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let suggestionCell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexPath)
        
        // セルに表示する値を設定する
        suggestionCell.textLabel!.text = suggestedBooks[indexPath.row].name
        suggestionCell.detailTextLabel!.text = suggestedBooks[indexPath.row].author
        return suggestionCell
    }
    
    private func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        print("セル番号：(indexPath.row) セルの内容：(titles[indexPath.row])")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
