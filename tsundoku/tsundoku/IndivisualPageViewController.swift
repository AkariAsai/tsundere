import UIKit

class IndividualPageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    var userName : String = ""
    var userID : String = ""
    
    //UICollectionViews for read/unread books.
    @IBOutlet weak var unreadCollectionView: UICollectionView!
    @IBOutlet weak var readCollectionView: UICollectionView!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var readLabel: UILabel!
    @IBOutlet weak var unreadLabel: UILabel!
    
    var readBooks : [Book] = []
    var unreadBooks : [Book] = []
    
    var imageViewsOfReadBooks : [ UIImageView ] = [ ]
    var imageViewsOfUnreadBooks : [ UIImageView ] = [ ]
    
    @IBAction func readButton(_ sender: Any) {
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.read_flag = 0
    }
    
    @IBAction func unreadButton(_ sender: Any) {
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.read_flag = 1
    }
    
    @IBAction func backButtonPushed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GraphView")
        show(vc, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileNameLabel.text = userName.components(separatedBy: " ").first!

        profileImage.image = UIImage(named: "iconset")
        profileImage.layer.borderColor = UIColor.MainColor(index: 0).cgColor
        profileImage.layer.borderWidth = 2.0
        profileImage.layer.cornerRadius = 20.0
        profileImage.layer.masksToBounds = true
        
        unreadCollectionView.delegate = self
        unreadCollectionView.dataSource = self
        unreadCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")
        
        readCollectionView.delegate = self
        readCollectionView.dataSource = self
        readCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")
        
        fetchBookList(callback: { readBooks, unreadBooks in
            self.readBooks = readBooks
            self.unreadBooks = unreadBooks
            
            var readPageCount = 0
            var unreadPageCount = 0
            
            for book in readBooks {
                readPageCount += book.pageCount
                
                let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 85, height: 100))
                
                if book.image.hasPrefix("http") && !book.image.hasPrefix("https") {
                    let str = book.image
                    let currentIndex = str.index(str.startIndex, offsetBy: 4)
                    let imageUrl = "https" + str.substring(from: currentIndex)

                    if let url = NSURL(string: imageUrl) as? URL {
                        if let data = NSData(contentsOf: url) as? Data {
                            imageView.image = UIImage(data: data)
                        }
                    }
                }
                
                 self.imageViewsOfReadBooks.append(imageView)
            }
            
            for book in unreadBooks {
                unreadPageCount += book.pageCount
                
                let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 85, height: 100))
                
                if book.image.hasPrefix("http") && !book.image.hasPrefix("https") {
                    let str = book.image
                    let currentIndex = str.index(str.startIndex, offsetBy: 4)
                    let imageUrl = "https" + str.substring(from: currentIndex)
                    
                    if let url = NSURL(string: imageUrl) as? URL {
                        if let data = NSData(contentsOf: url) as? Data {
                            imageView.image = UIImage(data: data)
                        }
                    }
                }
                
                self.imageViewsOfUnreadBooks.append(imageView)
            }
            
            self.readLabel.text = "読了: \(readPageCount)ページ"
            self.unreadLabel.text = "未読: \(unreadPageCount)ページ"
            
            self.loadingLabel.text = ""
            self.readCollectionView.reloadData()
            self.unreadCollectionView.reloadData()
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.readCollectionView {
            return self.readBooks.count
        } else {
            return self.unreadBooks.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let book = (collectionView == self.readCollectionView ? self.readBooks : self.unreadBooks)[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath as IndexPath)
        let imageViews = (collectionView == self.readCollectionView ? self.imageViewsOfReadBooks : self.imageViewsOfUnreadBooks)
        
        let label = UILabel()

        label.adjustsFontSizeToFitWidth = false
        label.text = book.title
        label.sizeToFit()
        label.frame = CGRect(x: 5, y: 115, width: 85, height: 10)
        label.numberOfLines = 0
        
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        cell.contentView.addSubview(imageViews[indexPath.row])
        cell.contentView.addSubview(label)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 95, height: 125)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
