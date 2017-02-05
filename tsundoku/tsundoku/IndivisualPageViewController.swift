import UIKit


class IndividualPageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    @IBOutlet weak var unreadCollectionView: UICollectionView!
    @IBOutlet weak var readCollectionView: UICollectionView!

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileNameLabel.text = (UserDefaults.standard.object(forKey: "name") as! String).components(separatedBy: " ").first! // id

        profileImage.image = UIImage(named: "iconset")
        profileImage.layer.borderColor = UIColor.MainColor().cgColor
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
            
            for book in readBooks {
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
