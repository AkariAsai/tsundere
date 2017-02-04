import UIKit

extension UIColor {
    clasUserInterfaceState.xcuserstates func rgb(r: Int, g: Int, b: Int, alpha: CGFloat) -> UIColor{
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    class func MainColor() -> UIColor {
        return UIColor.rgb(r: 0, g: 188, b: 188, alpha: 1.0)
    }
}


class IndividualPageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    //UICollectionViews for read/unread books.
    @IBOutlet weak var unreadCollectionView: UICollectionView!
    @IBOutlet weak var readCollectionView: UICollectionView!

    //This is for profile
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    
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
        //ユーザー個人ネーム読み取るように変更
        profileNameLabel.text = "山田太郎"
        //プロフィール画も同様
        profileImage.image = UIImage(named:"iconset")
        profileImage.layer.borderColor = UIColor.MainColor().cgColor
        profileImage.layer.borderWidth = 5.0
        profileImage.layer.cornerRadius = 20.0
        profileImage.layer.masksToBounds = true
        
        unreadCollectionView.delegate = self
        unreadCollectionView.dataSource = self
        
        readCollectionView.delegate = self
        readCollectionView.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        //個人データから読み込み
        if collectionView == self.unreadCollectionView{
            return 100
        } else {
            return 10
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if collectionView == self.unreadCollectionView{
            let BookCell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath as IndexPath) as UICollectionViewCell
            
            //This is a hack.
            let bookImageView = BookCell.contentView.viewWithTag(1) as! UIImageView
            let url = NSURL(string:"https://images-na.ssl-images-amazon.com/images/I/512ru2i5gyL._SX352_BO1,204,203,200_.jpg")
            let imageData = NSData(contentsOf: url! as URL)
            bookImageView.image = UIImage(data:imageData! as Data)
            
            let label = BookCell.contentView.viewWithTag(2) as! UILabel
            label.text = "深層学習"
            return BookCell
        } else {
            let ReadBookCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReadBookCell", for: indexPath as IndexPath) as UICollectionViewCell
            
            //this is a hack
            let bookImageView = ReadBookCell.contentView.viewWithTag(1) as! UIImageView
            let url = NSURL(string:"https://images-na.ssl-images-amazon.com/images/I/51Y8KNTSc1L._SX389_BO1,204,203,200_.jpg")
            let imageData = NSData(contentsOf: url! as URL)
            bookImageView.image = UIImage(data:imageData! as Data)
            
            let label = ReadBookCell.contentView.viewWithTag(2) as! UILabel
            label.text = "データ分析"
            return ReadBookCell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
