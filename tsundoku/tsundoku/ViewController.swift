import UIKit

extension UIColor {
    class func rgb(r: Int, g: Int, b: Int, alpha: CGFloat) -> UIColor{
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
    
    var graphBaseHeight:CGFloat = 0.0
    
    var userInfoOverview = UsersInfoOverview()
    private var graphScroll: UIScrollView!
    var unreadBars : [ UIView ] = []
    var readBars : [ UIView ] = []
    
    @IBOutlet weak var readSegmentation: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        graphScroll = UIScrollView()
        graphScroll.minimumZoomScale = 0.5
        graphScroll.maximumZoomScale = 5
        
        graphScroll.frame = CGRect(x:10, y: 150, width:self.view.frame.maxX, height:self.view.frame.maxY - 200)
        graphBaseHeight = graphScroll.frame.height - CGFloat(100.0)
        
        graphScroll.contentSize = CGSize(width:1000, height:graphScroll.frame.height)
        graphScroll.delegate = self
        
        
        fetchFirstView( callback: {overview in
            for user in overview {
                usersByRead.append((user.1.0, user.1.1))
                usersByUnread.append((user.1.0, user.1.2))
            }
        })
        
        usersByRead.sort() { $0.pageCount > $1.pageCount }
        usersByUnread.sort() { $0.pageCount > $1.pageCount }
        
        self.view.addSubview(graphScroll)
        showReadPage()
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchView(sender:)))  //Swift3
        
        self.view.addGestureRecognizer(pinchGesture)
        print(pinchGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func segementedControllerChanged(_ sender: Any) {
        let selectedIndex = readSegmentation.selectedSegmentIndex
        
        if selectedIndex == 1{
            showUnreadPage()
        } else{
            showReadPage()
        }
    }
    
    func showReadPage(){
        removeAllBarsFromGraphScroll()
        
        let maxPageCount = sortedArray[0].1.1
        
        var index = 0
        for (k, v) in sortedArray{
            let height = Int(Float(self.graphScroll.frame.height) * Float(v.1)/Float(maxPageCount))
            let rect = CGRect(x: 80 * index,y: Int(graphBaseHeight) - height, width: 40, height: height)
            let bar = UIView.init(frame: rect)
            bar.backgroundColor = UIColor.MainColor()
            graphScroll.addSubview(bar)
            readBars.append(bar)
            index += 1
        }
    }
    
    func showUnreadPage(){
        removeAllBarsFromGraphScroll()
        let sortedArray = Array(userInfoOverview).sorted{$0.1.2 > $1.1.2}
        let maxPageCount = sortedArray[0].1.2
        
        var index = 0
        for (k, v) in sortedArray{
            let height = Int(Float(self.graphScroll.frame.height) * Float(v.2)/Float(maxPageCount))
            let rect = CGRect(x: 80 * index,y: Int(graphBaseHeight) - height, width: 40, height: height)
            let bar = UIView.init(frame: rect)
            bar.backgroundColor = UIColor.gray
            graphScroll.addSubview(bar)
            unreadBars.append(bar)
            
            index += 1
        }
    }
    
    func removeAllBarsFromGraphScroll(){
        for view in graphScroll.subviews{
            view.removeFromSuperview()
        }
    }
    
    func pinchView(sender: UIPinchGestureRecognizer) {
        print("hello")
        print("scale: \(sender.scale)")
        print("velocity: \(sender.velocity)")
        
        let anchor = sender.location(in: graphScroll)
        transform(center: anchor, scale: Float(sender.scale))
    }
    
    func transform(center: CGPoint, scale:Float) -> Void{
        print(center, scale)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        //let sortedArray = Array(userInfoOverview).sorted{$0.1.1 > $1.1.1}
        print(graphScroll.contentOffset.x / 80)
        if graphScroll.contentOffset.x > 0{
            fitReadPageMaxHeight(scale:Float(graphScroll.contentOffset.x / 80))        }
        
    }
    
    func fitReadPageMaxHeight(scale:Float){
        //removeAllBarsFromGraphScroll()
        //let sortedArray = Array(userInfoOverview).sorted{$0.1.1 > $1.1.1}
        //let maxPageCount = sortedArray[Int(scale)].1.1
        //print(maxPageCount)
        let selectedIndex = readSegmentation.selectedSegmentIndex
        let maxHeight = self.graphScroll.frame.height
        let maxPageCount = (selectedIndex == 0 ? userInfoOverview[Int(scale)]!.1 : userInfoOverview[Int(scale)]!.2)
        
        var index = 0
        let proportion = scale - Float(Int(scale))
        for (k, v) in userInfoOverview {
            let height = Float(maxHeight) * Float(v.1) / Float(maxPageCount) * (1 + proportion)
            
            if (selectedIndex == 1){
                unreadBars[index].frame = CGRect(x: 0 ,y: 0, width: 40, height: Int(height))
            } else {
                readBars[index].frame = CGRect(x: 0 ,y: 0, width: 40, height: Int(height))
            }
                
            index += 1
        }
        
    }
    
}

