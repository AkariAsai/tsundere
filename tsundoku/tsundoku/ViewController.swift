import UIKit

func random(from range: Range<Int>) -> Int {
    let lowerBound = range.lowerBound
    let upperBound = range.upperBound
    
    return lowerBound + Int(arc4random_uniform(UInt32(upperBound - lowerBound)))
}

func random(from range: ClosedRange<Int>) -> Int {
    let lowerBound = range.lowerBound
    let upperBound = range.upperBound
    
    return lowerBound + Int(arc4random_uniform(UInt32(upperBound - lowerBound + 1)))
}

let r1 = random(from: 4 ..< 8)
let r2 = random(from: 6 ... 8)


// As suggested by Dave Abrahams on swift-users@swift.org mailing list
// https://lists.swift.org/pipermail/swift-users/Week-of-Mon-20161010/003701.html
protocol CompleteRange {
    associatedtype Bound : Comparable
    var lowerBound : Bound { get }
    var upperBound : Bound { get }
}

extension CountableRange : CompleteRange {}
extension CountableClosedRange : CompleteRange {}

import Darwin

func random<R: CompleteRange>(from range: R) -> Int where R.Bound == Int, R: Collection {
    return range.lowerBound + Int(arc4random_uniform(numericCast(range.count)))
}


extension UIColor {
    class func rgb(r: Int, g: Int, b: Int, alpha: CGFloat) -> UIColor {
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    class func MainColor(index : Int) -> UIColor {
        let r = random(from: -40 ..< 40)
        return (index == 0 ? UIColor.rgb(r: 0, g: 188 + r, b: 188 + r, alpha: 1.0) : UIColor.rgb(r: 225 + r, g: 150 + r, b: 0, alpha: 1.0))
    }
    class func MyColor(index : Int) -> UIColor {
        return (index == 0 ? UIColor.rgb(r: 0, g: 255, b: 188, alpha: 1.0) : UIColor.rgb(r: 255, g: 30, b: 0, alpha: 1.0))
    }
}

class ViewController: UIViewController, UIScrollViewDelegate  {
    typealias UsersInfoOverview = [ String : (String, Int, Int) ]
    
    var usersByRead : [ (name : String, pageCount : Int) ] = []
    var usersByUnread : [ (name : String, pageCount : Int) ] = []
    var userIDDic =  [String:String]()
    
    var barMargin = 50
    var barWidth = 50
    
    var graphBaseHeight:CGFloat = 0.0
    
    var userInfoOverview = UsersInfoOverview()
    
    var userName: String = ""
    var userID: String = ""
    
    var bars : [ UIView ] = []
    var labels : [ (name : UIButton, pageCount : UILabel) ] = []
    
    @IBOutlet weak var readSegmentation: UISegmentedControl!
    @IBOutlet weak var graphScroll: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchFirstView(callback: { overview in
            for user in overview {
                self.userIDDic[user.1.0.components(separatedBy: " ").first!] = String(user.0)
                self.usersByRead.append((user.1.0.components(separatedBy: " ").first!, user.1.1))
                self.usersByUnread.append((user.1.0.components(separatedBy: " ").first!, user.1.2))
            }
            
            self.usersByRead.sort() { $0.pageCount > $1.pageCount }
            self.usersByUnread.sort() { $0.pageCount > $1.pageCount }

            self.graphScroll.contentSize = CGSize(width: CGFloat(self.usersByRead.count * (self.barWidth + self.barMargin)), height: self.graphScroll.frame.height)
        
            self.graphScroll.minimumZoomScale = 0.5
            self.graphScroll.maximumZoomScale = 5
            
            self.graphScroll.delegate = self
            self.graphScroll.showsHorizontalScrollIndicator = false
            
            self.showPageBar(Index: 0)
        })
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchView(sender:)))  //Swift3
        
        self.view.addGestureRecognizer(pinchGesture)
        print(pinchGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func segementedControllerChanged(_ sender: Any) {
        let selectedIndex = readSegmentation.selectedSegmentIndex
        
        showPageBar(Index: selectedIndex)
    }
    
    func showPageBar(Index : Int){
        removeAllBars()
        
        let myName = (UserDefaults.standard.object(forKey: "name") as! String).components(separatedBy: " ").first!
        
        self.graphScroll.setContentOffset(.zero, animated: false)
        
        let users = (Index == 0 ? usersByRead : usersByUnread)
        let maxHeight = Float(self.graphScroll.frame.height)
        
        if let maxCount = users.first?.pageCount {
            for index in 0 ..< users.count {
                let height = Int(maxHeight * Float(users[index].pageCount) / Float(maxCount) * 0.7)
                let bar = UIView(frame: CGRect(x: (barWidth + barMargin) * index, y: Int(maxHeight - 70), width: barWidth, height: 0))
                
                bar.backgroundColor = (users[index].name != myName ? UIColor.MainColor(index: Index) : UIColor.MyColor(index: Index))
                graphScroll.addSubview(bar)
                bars.append(bar)
                
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: { () -> Void in
                     bar.frame = CGRect(x: (self.barWidth + self.barMargin) * index, y: Int(maxHeight - Float(height) - 70), width: self.barWidth, height: height)
                }, completion: nil)
                
                let nameButton = UIButton()
                nameButton.setTitle(users[index].name, for: .normal)
                nameButton.sizeToFit()
                nameButton.frame = CGRect(x: 0, y: Int(bar.frame.maxY + 50) , width: barWidth + barMargin, height: 15)
                nameButton.backgroundColor = UIColor.clear
                nameButton.setTitleColor(UIColor.MainColor(index: Index), for: .normal)
                nameButton.center = CGPoint(x: CGFloat((barWidth + barMargin) * index + barWidth / 2), y: graphScroll.frame.height - 20)
                nameButton.addTarget(self, action: #selector(didTapNameButton(sender:)), for: .touchUpInside)
                
                graphScroll.addSubview(nameButton)
                
                let pageCountLabel = UILabel()
                pageCountLabel.text = "\(users[index].pageCount)"
                pageCountLabel.sizeToFit()
                pageCountLabel.center = CGPoint(x: CGFloat((barWidth + barMargin) * index + barWidth / 2), y: graphScroll.frame.height - 50)
                graphScroll.addSubview(pageCountLabel)
                
                labels.append((nameButton, pageCountLabel))
            }
        }
    }
    
    func removeAllBars(){
        for view in self.graphScroll.subviews {
            view.removeFromSuperview()
        }
        
        self.bars = []
        self.labels = []
    }
    
    func pinchView(sender: UIPinchGestureRecognizer) {
        print("scale: \(sender.scale)")
        print("velocity: \(sender.velocity)")
        
        let anchor = sender.location(in: graphScroll)
        transform(center: anchor, scale: Float(sender.scale))
    }
    
    func transform(center: CGPoint, scale:Float) -> Void {
        print(center, scale)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if graphScroll.contentOffset.x > 0 {
            fitReadPageMaxHeight(offset: Float(graphScroll.contentOffset.x))
        }
    }
    
    func fitReadPageMaxHeight(offset: Float) {
        let users = (readSegmentation.selectedSegmentIndex == 0 ? self.usersByRead : self.usersByUnread)
        
        let barSpace = barWidth + barMargin
        let maxHeight = Float(self.graphScroll.frame.height)
        
        let maxPageIndex = min(Int(offset / Float(barSpace)), users.count - 1)
        let maxPageCount = users[maxPageIndex].pageCount
        
        let pageOffset = Float(maxPageCount - users[min(maxPageIndex + 1, users.count - 1)].pageCount) / Float(max(1, users[min(maxPageIndex + 1, users.count - 1)].pageCount)) * Float(Int(offset) % barSpace) / Float(barSpace)

        print(offset, maxPageIndex, maxPageCount, users[min(maxPageIndex + 1, users.count - 1)].pageCount, maxHeight, pageOffset)
        
        for index in 0 ..< users.count {
            let height = Int(maxHeight * Float(users[index].pageCount) / Float(max(maxPageCount, 1)) * (1 + pageOffset) * 0.7)
            let x = (barWidth + barMargin) * index
            
            bars[index].frame = CGRect(x: x, y: Int(maxHeight - Float(height) - 70), width: barWidth, height: height)
        }
    }
    
    func didTapNameButton(sender:AnyObject){
        userName = sender.currentTitle as String!
        performSegue(withIdentifier: "goIndividualView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let secondViewController = segue.destination as! IndividualPageViewController
        
        secondViewController.userName = userName
        secondViewController.userID = self.userIDDic[userName]!
    }
}

