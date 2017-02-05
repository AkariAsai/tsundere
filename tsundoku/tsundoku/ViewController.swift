import UIKit

extension UIColor {
    class func rgb(r: Int, g: Int, b: Int, alpha: CGFloat) -> UIColor {
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    class func MainColor() -> UIColor {
        return UIColor.rgb(r: 0, g: 188, b: 188, alpha: 1.0)
    }
}

class ViewController: UIViewController, UIScrollViewDelegate  {
    typealias UsersInfoOverview = [ Int : (String, Int, Int) ]
    
    var usersByRead : [ (name : String, pageCount : Int) ] = []
    var usersByUnread : [ (name : String, pageCount : Int) ] = []
    
    var barMargin = 50
    var barWidth = 50
    
    var graphBaseHeight:CGFloat = 0.0
    
    var userInfoOverview = UsersInfoOverview()
    var bars : [ UIView ] = []
    var labels : [ (name : UIButton, pageCount : UILabel) ] = []
    
    @IBOutlet weak var readSegmentation: UISegmentedControl!
    @IBOutlet weak var graphScroll: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchFirstView(callback: { overview in
            for user in overview {
                self.usersByRead.append((user.1.0, user.1.1))
                self.usersByUnread.append((user.1.0, user.1.2))
            }
        })
        
        usersByRead.sort() { $0.pageCount > $1.pageCount }
        usersByUnread.sort() { $0.pageCount > $1.pageCount }
        
        graphScroll.minimumZoomScale = 0.5
        graphScroll.maximumZoomScale = 5
        
        graphScroll.contentSize = CGSize(width: CGFloat(usersByRead.count * (barWidth + barMargin)), height: graphScroll.frame.height)
        graphScroll.delegate = self
        graphScroll.showsHorizontalScrollIndicator = false
        
        self.showPageBar(index: 0)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchView(sender:)))  //Swift3
        
        self.view.addGestureRecognizer(pinchGesture)
        print(pinchGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func segementedControllerChanged(_ sender: Any) {
        let selectedIndex = readSegmentation.selectedSegmentIndex
        
        showPageBar(index: selectedIndex)
    }
    
    func showPageBar(index : Int){
        removeAllBars()
        
        self.graphScroll.setContentOffset(.zero, animated: false)
        
        let users = (index == 0 ? usersByRead : usersByUnread)
        let maxHeight = Float(self.graphScroll.frame.height)
        
        if let maxCount = users.first?.pageCount {
            for index in 0 ..< users.count {
                let height = Int(maxHeight * Float(users[index].pageCount) / Float(maxCount) * 0.7)
                let bar = UIView(frame: CGRect(x: (barWidth + barMargin) * index, y: Int(maxHeight - 70), width: barWidth, height: 0))
                
                bar.backgroundColor = UIColor.MainColor()
                graphScroll.addSubview(bar)
                bars.append(bar)
                
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: { () -> Void in
                     bar.frame = CGRect(x: (self.barWidth + self.barMargin) * index, y: Int(maxHeight - Float(height) - 70), width: self.barWidth, height: height)
                }, completion: nil)
                
                let nameButton = UIButton()
                nameButton.setTitle(users[index].name, for: .normal)
                nameButton.sizeToFit()
                nameButton.frame = CGRect(x: 0, y: 0, width: barWidth + barMargin, height: 15)
                nameButton.center = CGPoint(x: CGFloat((barWidth + barMargin) * index + barWidth / 2), y: graphScroll.frame.height - 20)
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
        for view in graphScroll.subviews {
            view.removeFromSuperview()
        }
        
        self.bars = []
        self.labels = []
    }
    
    func pinchView(sender: UIPinchGestureRecognizer) {
        print("hello")
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
        
        let pageOffset = Float(maxPageCount - users[min(maxPageIndex + 1, users.count - 1)].pageCount) / Float(users[min(maxPageIndex + 1, users.count - 1)].pageCount) * Float(Int(offset) % barSpace) / Float(barSpace)

        print(offset, maxPageIndex, maxPageCount, users[min(maxPageIndex + 1, users.count - 1)].pageCount, maxHeight, pageOffset)
        
        for index in 0 ..< users.count {
            let height = Int(maxHeight * Float(users[index].pageCount) / Float(maxPageCount) * (1 + pageOffset) * 0.7)
            let x = (barWidth + barMargin) * index
            
            bars[index].frame = CGRect(x: x, y: Int(maxHeight - Float(height) - 70), width: barWidth, height: height)
        }
    }
}

