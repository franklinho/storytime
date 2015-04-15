//
//  CommentsViewController.swift
//  Storytime
//
//  Created by Franklin Ho on 4/14/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PBJVisionDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, StoryVideoTableViewCellDelegate {

    @IBOutlet weak var progressView: UIView!
    
    
    @IBOutlet weak var progressViewTrailingConstraint: NSLayoutConstraint!
    var currentOffset = 0
    var comments = []
    var story : PFObject?
    var createViewExpanded = false
    var createViews = []
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var profileTabBarItem : UITabBarItem?
//    var votedStories : NSMutableDictionary = [:]
    var vision : PBJVision = PBJVision.sharedInstance()
    var capturedImage : UIImage?
    var maxReached = false
    var refreshControl : UIRefreshControl!
    var requestingObjects = false
    var playingVideoCell : StoryVideoTableViewCell?
    var documentPath : NSString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    
    @IBOutlet weak var createViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var createViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var storyImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userButton: UILabel!

    @IBOutlet weak var storyTitleLabel: UILabel!
    @IBOutlet weak var commentsTableView: UITableView!
    
    
    @IBOutlet weak var createView: UIView!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var videoContainer: UIView!
    @IBOutlet weak var textContainer: UIView!
    @IBOutlet weak var cameraContainer: UIView!
    @IBOutlet weak var cameraSendButton: UIButton!
    @IBOutlet weak var cameraFlashButton: UIButton!
    @IBOutlet weak var cameraSwitchButton: UIButton!
    @IBOutlet weak var holdToRecordLabel: UILabel!
    
    
    @IBOutlet var videoLongPressGestureRecognizer: UILongPressGestureRecognizer!

    
    @IBOutlet weak var newCommentButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        
        createView.hidden = true
        profileTabBarItem = self.tabBarController?.tabBar.items?[1] as UITabBarItem
        
        self.commentsTableView.tableHeaderView = UIView(frame: CGRectMake(0.0, 0.0, self.commentsTableView.bounds.size.width, 0.01))
        self.commentsTableView.rowHeight = screenSize.width
        
        profileImageView.layer.cornerRadius = 31
        profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
        profileImageView.layer.borderWidth = 2
        profileImageView.clipsToBounds = true
        
        cameraSendButton.layer.borderWidth = 3.0
        cameraSendButton.layer.borderColor = UIColor.whiteColor().CGColor
        cameraSendButton.layer.cornerRadius = 40
        cameraSendButton.clipsToBounds = true

        holdToRecordLabel.layer.borderColor = UIColor.whiteColor().CGColor
        holdToRecordLabel.layer.borderWidth = 3.0;
        holdToRecordLabel.layer.cornerRadius = 17
        holdToRecordLabel.clipsToBounds = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyBoardWillChange:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        createViews = [cameraContainer, textContainer, videoContainer]
        profileTabBarItem = self.tabBarController?.tabBar.items?[1] as UITabBarItem
        createViewHeightConstraint.constant = self.view.bounds.width + 46
        
        self.view.updateConstraints()
        self.view.layoutIfNeeded()
//        updateVotingLabels()
        var previewLayer = PBJVision.sharedInstance().previewLayer
        previewLayer.frame = cameraContainer.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        cameraContainer.layer.insertSublayer(previewLayer, atIndex: 0)
        configureDevice()
        
        // Add pull to refresh to the tableview
        self.refreshControl = UIRefreshControl()
        var pullToRefreshString = "Pull to refresh"
        var pullToRefreshAttributedString : NSMutableAttributedString = NSMutableAttributedString(string: pullToRefreshString)
        pullToRefreshAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, countElements(pullToRefreshString)))
        self.refreshControl.attributedTitle = pullToRefreshAttributedString
        self.refreshControl.addTarget(self, action: "refreshCommentsForStory", forControlEvents: UIControlEvents.ValueChanged)
        self.commentsTableView.addSubview(refreshControl)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Table returning \(self.comments.count) cells")
        if maxReached == true {
            return self.comments.count
        } else {
            return self.comments.count + 1
        }
        
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var comment : PFObject?
        if indexPath.row == commentsTableView.numberOfRowsInSection(0)-1 && maxReached == false {
            var cell = tableView.dequeueReusableCellWithIdentifier("SpinnerCell") as UITableViewCell
            return cell
        } else {
            if comments.count > 0 {
                comment = comments[indexPath.row] as PFObject
                if comment!["type"] as NSString == "text" {
                    var cell = commentsTableView.dequeueReusableCellWithIdentifier("StoryTextTableViewCell") as StoryTextTableViewCell
                    cell.eventTextLabel.text = comment!["text"] as? String
                    cell.timestampLabel.text = timeSinceTimeStamp(comment!.createdAt)
                    return cell
                } else if comment!["type"] as String == "photo" {
                    var cell = commentsTableView.dequeueReusableCellWithIdentifier("StoryImageTableViewCell") as StoryImageTableViewCell
                    cell.timestampLabel.text = timeSinceTimeStamp(comment!.createdAt)
                    let userImageFile = comment!["image"] as PFFile
                    userImageFile.getDataInBackgroundWithBlock {
                        (imageData: NSData!, error: NSError!) -> Void in
                        if error == nil {
                            let image = UIImage(data:imageData)
                            cell.eventImageView.image = image
                        }
                    }
                    
                    return cell
                } else {
                    var cell = commentsTableView.dequeueReusableCellWithIdentifier("StoryVideoTableViewCell") as StoryVideoTableViewCell
                    
                    cell.delegate = self
                    
                    if cell.playerLayer != nil {
                        cell.playerLayer!.removeFromSuperlayer()
                    }
                    
                    cell.timestampLabel.text = timeSinceTimeStamp(comment!.createdAt)
                    
                    let videoFile = comment!["video"] as PFFile
                    videoFile.getDataInBackgroundWithBlock {
                        (videoData: NSData!, error: NSError!) -> Void in
                        if error == nil {
                            var path = "\(self.documentPath)/\(indexPath.row).mp4"
                            if (NSFileManager.defaultManager().fileExistsAtPath(path)) {
                                NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
                            }
                            
                            videoData.writeToFile(path, atomically: true)
                            println("File now at \(path)")
                            var movieURL = NSURL(fileURLWithPath: path)
                            cell.player = AVPlayer(URL: movieURL)
                            
                            
                            cell.playerLayer = AVPlayerLayer(player: cell.player!)
                            cell.playerLayer!.frame = CGRectMake(0, 0, self.screenSize.width, self.screenSize.width)
                            cell.playerLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                            cell.playerLayer!.needsDisplayOnBoundsChange = true
                            
                            cell.contentView.layer.insertSublayer(cell.playerLayer!, atIndex: 0)
                            cell.contentView.layer.needsDisplayOnBoundsChange = true
                            
                            if self.cellCompletelyOnScreen(indexPath){
                                self.playingVideoCell = cell
                                self.playingVideoCell?.playButtonIconImageView.hidden = true
                                self.playingVideoCell!.player!.play()
                                self.playingVideoCell!.player!.actionAtItemEnd = .None
                                
                                
                                NSNotificationCenter.defaultCenter().addObserver(self, selector: "restartVideoFromBeginning", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.playingVideoCell!.player!.currentItem)
                            }
                            
                            
                        }
                    }
                    
                    
                    return cell
                    
                }
                
            } else {
                return UITableViewCell()
            }
            
        }
        
    }
    
    func configureDevice() {
        vision.delegate = self
        vision.cameraOrientation = PBJCameraOrientation.Portrait
        vision.focusMode = PBJFocusMode.ContinuousAutoFocus
        vision.outputFormat = PBJOutputFormat.Square
        vision.maximumCaptureDuration = CMTimeMakeWithSeconds(10, 600)
        vision.flashMode = PBJFlashMode.Auto
    }

    func keyBoardWillChange(notification: NSNotification) {
        // Adjusts size of text view to scroll when keyboard is up
        var keyBoardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        self.view.convertRect(keyBoardRect, fromView: nil)
        
        var createViewRect : CGRect = self.createView.frame
        
        self.view.layoutIfNeeded()
        
        if CGFloat(createViewRect.origin.y) + CGFloat(createViewRect.height) > CGFloat(keyBoardRect.origin.y) {
            println("Keyboard Rect: \(keyBoardRect)")
            println("CreateView Rect: \(createViewRect)")
            self.createViewHeightConstraint.constant = CGFloat(keyBoardRect.origin.y) - CGFloat(createViewRect.origin.y)
            println("New Createview Height: \(self.createViewHeightConstraint.constant)")
        } else {
            self.createViewHeightConstraint.constant = self.view.bounds.width + 46
        }
        
        UIView.animateWithDuration(0.1, animations: {
            self.view.layoutIfNeeded()
            println("Post transform createview Rect: \(createViewRect)")
        })
        
    }
    
    func minimizeCreateView() {
        newCommentButton.enabled = true
        
        self.view.layoutIfNeeded()
        
        self.createViewTopConstraint.constant = -(screenSize.width + 46)
        //        createViewLeadingConstraint.constant = screenSize.width/4
        //        createViewTrailingConstraint.constant = screenSize.width/4
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
            }, completion: {
                (value: Bool) in
                self.createView.hidden = true
                self.createViewExpanded = false
                self.newCommentButton!.title = "+ Comment"
        })
        videoLongPressGestureRecognizer.enabled = false
        for view in createViews {
            (view as UIView).hidden = true
            cameraContainer.hidden = false
        }
        
        
    }
    
    
    
    
    @IBAction func newCommentButtonWasTapped(sender: AnyObject) {
        if (PFUser.currentUser() == nil){
            presentLoginViewController()
        } else if (PFUser.currentUser() != nil && PFUser.currentUser()["profileName"] == nil) {
            presentCreateProfileViewController()
        } else {
            if createViewExpanded == false {
                expandCreateView()
            } else {
                minimizeCreateView()
            }
        }
    }
    
    func expandCreateView() {
        self.view.endEditing(true)
        self.view.layoutIfNeeded()
        self.createView.hidden = false
        self.createViewHeightConstraint.constant = self.view.bounds.width + 46
        self.createViewTopConstraint.constant = 0
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
            
            }, completion: {
                (value: Bool) in
                self.createView.hidden = false
                self.newCommentButton!.title = "Cancel"
                self.createViewExpanded = true            })
        
//        if playingVideoCell != nil && playingVideoCell?.player?.rate == 1.0 {
//            playingVideoCell?.player?.pause()
//            playingVideoCell?.playButtonIconImageView.hidden = false
//        }
        
        vision.cameraMode = PBJCameraMode.Photo
        vision.captureSessionPreset = AVCaptureSessionPresetPhoto
        cameraSendButton.hidden = false
        cameraSendButton.enabled = true
        holdToRecordLabel.hidden = true
        videoLongPressGestureRecognizer.enabled = false
        for view in createViews {
            (view as UIView).hidden = true
            cameraContainer.hidden = false
        }
        
        
        vision.startPreview()
        
        
    }
    
    func presentLoginViewController() {
        var loginViewController : CustomLoginViewController = CustomLoginViewController()
        loginViewController.delegate = self
        loginViewController.facebookPermissions = NSArray(array: ["friends_about_me"])
        loginViewController.fields = PFLogInFields.Twitter | PFLogInFields.Facebook | PFLogInFields.DismissButton
        
        
        var signUpViewController : CustomSignUpViewController = CustomSignUpViewController()
        signUpViewController.delegate = self
        
        loginViewController.signUpController = signUpViewController
        
        self.presentViewController(loginViewController, animated: true, completion: nil)
    }
    
    func presentCreateProfileViewController() {
        var createProfileVC : CreateProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CreateProfileViewController") as CreateProfileViewController
        self.presentViewController(createProfileVC, animated: true, completion: nil)
        
    }

    func logInViewController(logInController: PFLogInViewController!, shouldBeginLogInWithUsername username: String!, password: String!) -> Bool {
        if ((username != nil && password != nil && countElements(username) != 0 && countElements(password) != 0) ) {
            return true
        }
        
        UIAlertView(title: "Missing Information", message: "Make sure you fill out all of the information", delegate: nil, cancelButtonTitle: "OK").show()
        
        return false
    }
    
    func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) {
        self.dismissViewControllerAnimated(true, completion: nil)
//        updateVotingLabels()
        profileTabBarItem!.enabled = true
        
        if PFUser.currentUser()["profileName"] == nil {
            var createProfileVC : CreateProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CreateProfileViewController") as CreateProfileViewController
            self.presentViewController(createProfileVC, animated: true, completion: nil)
        } else {
            //            if self.creatingNewStory == true {
            //                var storyVC : StoryViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("StoryViewController") as StoryViewController
            //                storyVC.newStory = true
            //                navigationController?.pushViewController(storyVC, animated: true)
            //            }
        }
        
    }
    
    func logInViewController(logInController: PFLogInViewController!, didFailToLogInWithError error: NSError!) {
        println("Failed to log in")
    }
    
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController!) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController!, shouldBeginSignUp info: [NSObject : AnyObject]!) -> Bool {
        var informationComplete : Bool = true
        
        for (key,value) in info {
            var field : NSString = info["key"] as NSString
            if (field.length == 0) {
                informationComplete = false
                break
            }
        }
        
        if (!informationComplete) {
            UIAlertView(title: "Missing Information", message: "Make sure you fill out all of the information", delegate: nil, cancelButtonTitle: "OK").show()
            
        }
        return informationComplete
        
    }
    
    func signUpViewController(signUpController: PFSignUpViewController!, didSignUpUser user: PFUser!) {
        self.dismissViewControllerAnimated(true, completion: nil)
//        updateVotingLabels()
        profileTabBarItem!.enabled = true
        
        if PFUser.currentUser()["profileName"] == nil {
            var createProfileVC : CreateProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CreateProfileViewController") as CreateProfileViewController
            self.presentViewController(createProfileVC, animated: true, completion: nil)
        } else {
            //            if self.creatingNewStory == true {
            //                var storyVC : StoryViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("StoryViewController") as StoryViewController
            //                storyVC.newStory = true
            //                navigationController?.pushViewController(storyVC, animated: true)
            //            }
        }
    }
    
    func signUpViewController(signUpController: PFSignUpViewController!, didFailToSignUpWithError error: NSError!) {
        println("Failed to sign up")
    }
    
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController!) {
        println("User dismissed the signupviewcontroller")
    }
    
//    func updateVotingLabels() {
//        if PFUser.currentUser() != nil{
//            if PFUser.currentUser()["votedStories"] != nil {
//                self.votedStories = PFUser.currentUser()["votedStories"] as NSMutableDictionary
//                if self.story != nil {
//                    if votedStories[self.story!.objectId] != nil {
//                        if self.story != nil{
//                            if votedStories[self.story!.objectId] as Int == 1 {
//                                storyUpVoted = true
//                                upVoteButton.setImage(UIImage(named: "up_icon_green.png"), forState: UIControlState.Normal)
//                                pointsLabel.textColor = UIColor(red: 15/255, green: 207/255, blue: 0/255, alpha: 1)
//                            } else if votedStories[self.story!.objectId] as Int == -1 {
//                                storyDownVoted = true
//                                downVoteButton.setImage(UIImage(named: "down_icon_red.png"), forState: UIControlState.Normal)
//                                pointsLabel.textColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    
    
    @IBAction func textButtonWasTapped(sender: AnyObject) {
        println("Text button was tapped")
        videoLongPressGestureRecognizer.enabled = false
        for view in createViews {
            (view as UIView).hidden = true
            textContainer.hidden = false
        }
    }
    
    @IBAction func cameraButtonWasTapped(sender: AnyObject) {
        self.view.endEditing(true)
        self.view.layoutIfNeeded()
        var createViewRect : CGRect = self.createView.bounds
        self.createViewHeightConstraint.constant = self.view.bounds.width + 46
        
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
            
        })
        
        vision.cameraMode = PBJCameraMode.Photo
        vision.captureSessionPreset = AVCaptureSessionPresetPhoto
        cameraSendButton.hidden = false
        cameraSendButton.enabled = true
        holdToRecordLabel.hidden = true
        videoLongPressGestureRecognizer.enabled = false
        for view in createViews {
            (view as UIView).hidden = true
            cameraContainer.hidden = false
        }
        
        
        vision.startPreview()

    }
    
    
    @IBAction func videoButtonWasTapped(sender: AnyObject) {
        self.view.endEditing(true)
        self.view.endEditing(true)
        self.view.layoutIfNeeded()
        var createViewRect : CGRect = self.createView.bounds
        self.createViewHeightConstraint.constant = self.view.bounds.width + 46
        
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
            
        })
        
        vision.cameraMode = PBJCameraMode.Video
        vision.captureSessionPreset = AVCaptureSessionPresetMedium
        cameraSendButton.hidden = true
        cameraSendButton.enabled = false
        holdToRecordLabel.hidden = false
        videoLongPressGestureRecognizer.enabled = true
        for view in createViews {
            (view as UIView).hidden = true
            cameraContainer.hidden = false
        }
        vision.startPreview()

    }
    
    
    
    @IBAction func cameraSendButtonWasTapped(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(),{
            self.vision.capturePhoto()
        })
        
        self.minimizeCreateView()
    }
    
    func vision(vision: PBJVision!, capturedPhoto photoDict: [NSObject : AnyObject]!, error: NSError!) {
        capturedImage = photoDict[PBJVisionPhotoImageKey] as UIImage
        dispatch_async(dispatch_get_main_queue(),{
            self.savePhotoComment()
        })
    }
    
    

    @IBAction func cameraFlashButtonWasTapped(sender: AnyObject) {
    }
    
    @IBAction func cameraSwitchButtonWasTapped(sender: AnyObject) {
    }
    
    
    @IBAction func videoLongPressGestureRecognizerWasPressed(sender: AnyObject) {
    }
    
    func squareImageWithImage(image : UIImage) -> UIImage {
        
        var refWidth : CGFloat = CGFloat(CGImageGetWidth(image.CGImage))
        var refHeight : CGFloat = CGFloat(CGImageGetHeight(image.CGImage))
        
        var x = (refWidth - CGFloat(image.size.width)) / 2.0
        var y = (refHeight - CGFloat(image.size.width)) / 2.0
        
        var cropRect : CGRect = CGRectMake(x, y, image.size.width, image.size.width)
        var imageRef : CGImageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect)
        var cropped = UIImage(CGImage: imageRef, scale: 0, orientation: image.imageOrientation)
        
        return cropped!
        
    }
    
    func savePhotoComment() {
        
        
        self.progressViewTrailingConstraint.constant = self.screenSize.width
        self.view.layoutIfNeeded()
        self.progressView.hidden = false
        
        var squareImage = squareImageWithImage(capturedImage!)
        var squareImageData = UIImageJPEGRepresentation(squareImage, 1.0)
        var imageFile : PFFile = PFFile(name: "image.png", data: squareImageData)
        
        imageFile.saveInBackgroundWithBlock({
            (success: Bool, error: NSError!) -> Void in
            if (success) {
                println("Image successfully uploaded")
            } else {
                println("There was an error saving the image file: \(error.description)")
                self.progressView.hidden = true
            }
            
            }, progressBlock: {
                (percentDone: CInt) -> Void in
                if percentDone == 100 {
                    self.progressView.hidden = true
                } else if percentDone != 0 {
                    self.view.layoutIfNeeded()
                    
                    self.progressViewTrailingConstraint.constant = CGFloat(self.screenSize.width)*CGFloat(percentDone/100) as CGFloat
                    
                    
                    UIView.animateWithDuration(0.3, animations: {
                        self.view.layoutIfNeeded()
                        
                    })
                    
                    
                }
                
        })
        
        
        if (self.story != nil) {
            self.createPhotoComment(imageFile)
        }
    }
    
    func createPhotoComment(imageFile : PFFile) {

        var comment: PFObject = PFObject(className: "Comment")
        comment["type"] = "photo"
        comment["storyObject"] = self.story!
        if PFUser.currentUser() != nil {
            comment["user"] = PFUser.currentUser()
        }
        comment["image"] = imageFile
        comment.saveInBackgroundWithBlock({
            (success: Bool, error: NSError!) -> Void in
            if (success) {
                // The object has been saved.
                println("Event successfully saved")
                self.vision.stopPreview()
                self.refreshCommentsForStory()
            } else {
                // There was a problem, check error.description
                println("There was an error saving the event: \(error.description)")
            }
        })
    }
    
    func refreshCommentsForStory() {
        requestCommentsForStory(self, offset: 0)
    }
    
    func requestCommentsForStory(sender:AnyObject, offset: Int) {
        maxReached = false
        
        dispatch_async(dispatch_get_main_queue(),{
            var query = PFQuery(className:"Comment")
            query.whereKey("storyObject", equalTo:self.story)
            query.orderByDescending("createdAt")
            
            query.limit = 10
            if offset == 0 {
                self.comments = []
                self.currentOffset = 0
            }
            print("Query skipping \(self.currentOffset) comments")
            query.skip = self.currentOffset
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    // The find succeeded.
                    println("Successfully retrieved \(objects.count) events.")
                    for object in objects {
                        var objectTitle = object["title"]
                        println("This is the object's title: \(objectTitle!))")
                    }
                    if objects.count == 0 || objects.count < 10 {
                        self.maxReached = true
                    }
                    
                    var temporaryArray : NSMutableArray = NSMutableArray(array: self.comments)
                    temporaryArray.addObjectsFromArray(objects)
                    self.comments = temporaryArray
                    self.currentOffset = self.comments.count
                    
                    self.commentsTableView.reloadData()
                    print("This is a list of all the comments \(self.comments)")
                    self.refreshControl.endRefreshing()
                    //                    if(GSProgressHUD.isVisible()) {
                    //                        GSProgressHUD.dismiss()
                    //                    }
                    self.requestingObjects = false
                } else {
                    // Log details of the failure
                    println("Error: \(error) \(error.userInfo!)")
                    self.refreshControl.endRefreshing()
                    //                    if(GSProgressHUD.isVisible()) {
                    //                        GSProgressHUD.dismiss()
                    //                    }
                }
            }
        })
        
    }
    
    func cellCompletelyOnScreen(indexPath : NSIndexPath) -> Bool {
        var cellRect : CGRect = commentsTableView.rectForRowAtIndexPath(indexPath)
        cellRect = commentsTableView.convertRect(cellRect, toView: commentsTableView.superview)
        var adjustedCellRect = CGRectMake(cellRect.origin.x, cellRect.origin.y + 5, cellRect.width, cellRect.height - 10)
        println("Cell Rect: \(cellRect)")
        println("CommentsTableView Frame : \(commentsTableView.frame)")
        var completelyVisible : Bool = CGRectContainsRect(commentsTableView.frame, adjustedCellRect)
        return completelyVisible
    }
    
    func restartVideoFromBeginning() {
        //create a CMTime for zero seconds so we can go back to the beginning
        let seconds : Int64 = 0
        let preferredTimeScale : Int32 = 1
        let seekTime : CMTime = CMTimeMake(seconds, preferredTimeScale)
        
        playingVideoCell!.player!.seekToTime(seekTime)
        
        playingVideoCell?.playButtonIconImageView.hidden = true
        playingVideoCell!.player!.play()
        
    }
    
    func timeSinceTimeStamp(timeStamp : NSDate) -> String {
        // Calculate time since tweet creation
        var secondsBetween : NSTimeInterval = NSDate().timeIntervalSinceDate(timeStamp)
        var numberOfMinutesDouble = secondsBetween/60 as Double
        var numberOfMinutes : Int = Int(numberOfMinutesDouble)
        
        //        println("\(numberOfMinutes)")
        
        var timeSinceEvent : String?
        
        if numberOfMinutes < 60 {
            timeSinceEvent = "\(numberOfMinutes)m ago"
        } else if numberOfMinutes < 1440 && numberOfMinutes >= 60 {
            var hours = Int(numberOfMinutes/60)
            timeSinceEvent = "\(hours)h ago"
        } else {
            let oldDateFormatter = NSDateFormatter()
            oldDateFormatter.dateFormat = "MM/dd/yy"
            timeSinceEvent = oldDateFormatter.stringFromDate(timeStamp)
        }
        
        //        let timeStampDateFormatter = NSDateFormatter()
        //        timeStampDateFormatter.dateFormat = "MM/dd/yy, HH:mm aa"
        //        self.timeStamp = timeStampDateFormatter.stringFromDate(createdTimeStamp)
        return timeSinceEvent!
        
    }
    
    func playOrPauseVideoCell(videoCell: StoryVideoTableViewCell) {
        if playingVideoCell != nil && playingVideoCell?.player?.rate == 1.0 && playingVideoCell != videoCell {
            playingVideoCell?.player?.pause()
            playingVideoCell?.playButtonIconImageView.hidden = false
        }
        
        self.playingVideoCell = videoCell
        if self.playingVideoCell?.player?.rate == 0 {
            self.playingVideoCell?.playButtonIconImageView.hidden = true
            self.playingVideoCell!.player!.play()
            self.playingVideoCell!.player!.actionAtItemEnd = .None
            
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "restartVideoFromBeginning", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.playingVideoCell!.player!.currentItem)
        } else {
            self.playingVideoCell?.player?.pause()
            self.playingVideoCell?.playButtonIconImageView.hidden = false
        }
        
        
        
        
    }
    
    
    
}
