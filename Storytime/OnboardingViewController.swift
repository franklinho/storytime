import UIKit
class OnboardingController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var skipButton: UIButton!
	let backgroundColor = UIColor(red: 155.0/255.0, green: 89.0/255.0, blue: 182.0/255.0, alpha: 1.0)
	let slides = [
		[ "image": "OnboardingImage1phone.png", "text": "Welcome to Storyweave! Tap the arrows to vote for your favorite stories."],
		[ "image": "OnboardingImage2phone.png", "text": "You can add new stories by tapping the plus button in the corner."],
		[ "image": "OnboardingImage3phone.png", "text": "Tapping the plus button in a story lets you post new photos, videos, and text."],
		[ "image": "OnboardingImage4phone.png", "text": "Your friends can post to your story too! Just add them using the settings button."],
	]
	let screen: CGRect = UIScreen.mainScreen().bounds
	var scroll: UIScrollView?
	var dots: UIPageControl?
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = backgroundColor
		scroll = UIScrollView(frame: CGRect(x: 0.0, y: 0.0, width: screen.width, height: screen.height * 0.9))
		scroll?.showsHorizontalScrollIndicator = false
		scroll?.showsVerticalScrollIndicator = false
		scroll?.pagingEnabled = true
		view.addSubview(scroll!)
		if (slides.count > 1) {
			dots = UIPageControl(frame: CGRect(x: 0.0, y: screen.height * 0.9, width: screen.width, height: screen.height * 0.05))
			dots?.numberOfPages = slides.count
			view.addSubview(dots!)
		}
		for var i = 0; i < slides.count; ++i {
			if let image = UIImage(named: slides[i]["image"]!) {
				var imageView: UIImageView = UIImageView(frame: getFrame(image.size.width, iH: image.size.height, slide: i, offset: screen.height * 0.15))
				imageView.image = image
				scroll?.addSubview(imageView)
			}
			if let text = slides[i]["text"] {
				var textView = UITextView(frame: CGRect(x: screen.width * 0.1 + CGFloat(i) * screen.width, y: screen.height * 0.75, width: screen.width * 0.8, height: 100.0))
				textView.text = text
				textView.editable = false
				textView.selectable = false
				textView.textAlignment = NSTextAlignment.Center
				textView.font = UIFont.systemFontOfSize(UIFont.labelFontSize(), weight: 0)
				textView.textColor = UIColor.whiteColor()
				textView.backgroundColor = UIColor.clearColor()
				scroll?.addSubview(textView)
			}
		}
		scroll?.contentSize = CGSizeMake(CGFloat(Int(screen.width) *  slides.count), screen.height * 0.5)
		scroll?.delegate = self
		dots?.addTarget(self, action: Selector("swipe:"), forControlEvents: UIControlEvents.ValueChanged)
        self.view.bringSubviewToFront(skipButton)
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	func getFrame (iW: CGFloat, iH: CGFloat, slide: Int, offset: CGFloat) -> CGRect {
		var mH: CGFloat = screen.height * 0.50
		var mW: CGFloat = screen.width
		var h: CGFloat
		var w: CGFloat
		var r = iW / iH
		if (r <= 1) {
			h = min(mH, iH)
			w = h * r
		} else {
			w = min(mW, iW)
			h = w / r
		}
		return CGRectMake(
			max(0, (mW - w) / 2) + CGFloat(slide) * screen.width,
			max(0, (mH - h) / 2) + offset,
			w,
			h
		)
	}
	func swipe(sender: AnyObject) -> () {
		if let scrollView = scroll {
			let x = CGFloat(dots!.currentPage) * scrollView.frame.size.width
			scroll?.setContentOffset(CGPointMake(x, 0), animated: true)
		}
	}
	func scrollViewDidEndDecelerating(scrollView: UIScrollView) -> () {
		let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
		dots!.currentPage = Int(pageNumber)
        if Int(pageNumber) == 3 {
            skipButton.setTitle("Next", forState: UIControlState.Normal)
        }
	}
	override func prefersStatusBarHidden() -> Bool {
		return true
	}
    @IBAction func skipButtonWasTapped(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey: "onboardingCompleted")
        
        var vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("HamburgerViewController") as! UIViewController
        self.presentViewController(vc, animated: true) { () -> Void in
            
        }
    }
}