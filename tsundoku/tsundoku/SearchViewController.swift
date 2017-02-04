import UIKit

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchTextField: UITextField!
    
    let titles = ["こころ", "舞姫", "吾輩は猫である"]
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //GoogleBooksAPIから返される情報の数によって要更新
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let suggestionCell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexPath)
        
        // セルに表示する値を設定する
        suggestionCell.textLabel!.text = titles[indexPath.row]
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
