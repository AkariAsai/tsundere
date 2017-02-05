import UIKit
import Dollar
import Cent

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
//                bar.layer.insertSublayer(makeGradientLayer(frame: bar.frame), at: 0)
                
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
    
    func removeAllBars() {
        for view in self.graphScroll.subviews {
            view.removeFromSuperview()
        }
        
        self.bars = []
        self.labels = []
    }
    
    func makeGradientLayer(frame : CGRect) -> CALayer {
        return $.tap(CAGradientLayer()) {
            $0.frame = frame
            $0.colors = [
                UIColor.rgb(r: 255, g: random(from: 0..<255), b: random(from: 0..<255), alpha: 1.0),
                UIColor.rgb(r: 255, g: random(from: 0..<255), b: random(from: 0..<255), alpha: 1.0)
            ]
        }
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

