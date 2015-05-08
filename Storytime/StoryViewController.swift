//
//  StoryViewController.swift
//  Storytime
//
//  Created by Franklin Ho on 3/26/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer


class StoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVCaptureFileOutputRecordingDelegate, PBJVisionDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, StoryVideoTableViewCellDelegate, StoryImageTableViewCellDelegate, StoryTextTableViewCellDelegate, UIActionSheetDelegate, UIAlertViewDelegate, CreateProfileViewControllerDelegate, PostersViewControllerDelegate {
    @IBOutlet weak var morePostersButton: UIButton!
    @IBOutlet weak var secondProfileImageView: UIImageView!
    @IBOutlet weak var titleViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var createButtonLongPressGestureRecognizer: UILongPressGestureRecognizer!
    var buttonActivityIndicator : UIActivityIndicatorView = UIActivityIndicatorView()
    var lastContentOffset : CGFloat = 0
    @IBOutlet weak var expandedCameraButton: UIButton!
    @IBOutlet weak var thirdProfileImageView: UIImageView!
    @IBOutlet weak var expandedVideoButton: UIButton!
    @IBOutlet weak var expandedTextButton: UIButton!
    @IBOutlet weak var expandedVideoYAlignmentConstraint: NSLayoutConstraint!
    @IBOutlet weak var expandedVideoXAlignmentConstraint: NSLayoutConstraint!
    @IBOutlet weak var expandedTextYAlignmentConstraint: NSLayoutConstraint!
    @IBOutlet weak var expandedCameraXAlignmentConstraint: NSLayoutConstraint!
    @IBOutlet weak var expandedButtonViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var expandedButtonViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var expandedButtonView: UIView!
    @IBOutlet weak var recordingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var createButton: UIButton!
    var hamburgerVC : HamburgerViewController?
    let installation = PFInstallation.currentInstallation()
    @IBOutlet weak var noEventsLabel: UILabel!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet var userTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var createTitleViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var cameraFlashButton: UIButton!
    
    var firstUser : PFUser?
    var secondUser : PFUser?
    var thirdUser : PFUser?
//    var profileTabBarItem : UITabBarItem?
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var newStory : Bool = false
    var storyCreated : Bool = false
    var story : PFObject?
    var events = []
    @IBOutlet weak var userProfileImage: UIImageView!
    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var audioCaptureDevice : AVCaptureDevice?
    var stillImageOutput : AVCaptureStillImageOutput?
    var videoOutput : AVCaptureMovieFileOutput?
    var capturedImage : UIImage?
    var documentPath : NSString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
    var videoPath : String?
    var croppedVideoPath : String?
    var vision : PBJVision = PBJVision.sharedInstance()
    var playingVideoCell : StoryVideoTableViewCell?
    var storyUpVoted = false
    var storyDownVoted = false
    var creatingEvent = false
    var createViewExpanded = false
//    var createButton :UIBarButtonItem?
    var settingsButton :UIBarButtonItem?
    var refreshControl : UIRefreshControl!
    var settingsActionSheet : UIActionSheet = UIActionSheet()
    
    var currentOffset = 0
    var maxReached = false
    var requestingObjects = false
    var previewLayer = PBJVision.sharedInstance().previewLayer
    var photoJustCreated = false
    var videoJustCreated = false

    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    var votedStories : NSMutableDictionary = [:]

    @IBOutlet weak var holdToRecordLabel: UILabel!
    
    @IBOutlet var videoLongPressGestureRecognizer: UILongPressGestureRecognizer!

    @IBOutlet weak var storyPointsLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var cameraSendButton: UIButton!
//    @IBOutlet weak var storyTitleLabel: UILabel!
         @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var createTextView: UITextView!
    @IBOutlet weak var createView: UIView!
    @IBOutlet weak var createTitleView: UIView!

    @IBOutlet weak var titleTextField: UITextField!


    @IBOutlet weak var createViewBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var createViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var createViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var createViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var storyTableView: UITableView!
    
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var cameraContainer: UIView!
    @IBOutlet weak var textContainer: UIView!
    @IBOutlet weak var videoContainer: UIView!
    var createViews = []
    
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressViewTrailingConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        morePostersButton.layer.cornerRadius = 22
        morePostersButton.layer.borderColor = UIColor.whiteColor().CGColor
        morePostersButton.layer.borderWidth = 2
        morePostersButton.clipsToBounds = true
        morePostersButton.hidden = true
        
        expandedButtonView.layer.cornerRadius = 40
        expandedButtonView.clipsToBounds = true
        
        createButton.layer.cornerRadius = 40
        createButton.clipsToBounds = true
        
        
        createButton.addSubview(buttonActivityIndicator)
        buttonActivityIndicator.frame = createButton.bounds
        buttonActivityIndicator.hidden = true

        commentsButton.layer.cornerRadius = 45
        commentsButton.layer.borderWidth = 6
        commentsButton.layer.borderColor = UIColor.whiteColor().CGColor
        commentsButton.clipsToBounds = true


        
        hamburgerVC = self.parentViewController!.parentViewController as! HamburgerViewController
        
        settingsActionSheet.delegate = self
        settingsActionSheet.addButtonWithTitle("Add Users")
        settingsActionSheet.addButtonWithTitle("Delete Story")
        settingsActionSheet.addButtonWithTitle("Cancel")
        settingsActionSheet.destructiveButtonIndex = 1
        settingsActionSheet.cancelButtonIndex = 2
        settingsActionSheet.actionSheetStyle = UIActionSheetStyle.Automatic
        
        if newStory == true {
            self.title = "New Story"
            self.storyTableView.hidden = true
            self.titleTextField.becomeFirstResponder()
            
        } else {
            if self.story != nil {
                self.title = story!["title"] as! String
            }
        }
        
        createView.hidden = true
        createTitleViewTopConstraint.constant = CGFloat(screenSize.height)/2 - CGFloat(createTitleView.bounds.height)*2
//        profileTabBarItem = (self.tabBarController?.tabBar.items?[1] as! UITabBarItem)
        
        self.storyTableView.tableHeaderView = UIView(frame: CGRectMake(0.0, 0.0, self.storyTableView.bounds.size.width, 0.01))
        
        userProfileImage.layer.cornerRadius = 22
        userProfileImage.layer.borderColor = UIColor.whiteColor().CGColor
        userProfileImage.layer.borderWidth = 2
        userProfileImage.clipsToBounds = true
        
        secondProfileImageView.layer.cornerRadius = 22
        secondProfileImageView.layer.borderColor = UIColor.whiteColor().CGColor
        secondProfileImageView.layer.borderWidth = 2
        secondProfileImageView.clipsToBounds = true
        
        thirdProfileImageView.layer.cornerRadius = 22
        thirdProfileImageView.layer.borderColor = UIColor.whiteColor().CGColor
        thirdProfileImageView.layer.borderWidth = 2
        thirdProfileImageView.clipsToBounds = true
        
        
        
        updateVotingLabels()
        
        
        
        if self.story != nil {
            if story!["points"] != nil {
                var points = story!["points"] as? Int
                pointsLabel.text = "\(points!)"
            }
            
            
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyBoardWillChange:", name: UIKeyboardWillChangeFrameNotification, object: nil)

//        NSFileManager.defaultManager().createDirectoryAtPath("\(documentPath)/videos/", withIntermediateDirectories: false, attributes: nil, error: nil)
        
        storyTableView.rowHeight = screenSize.width
        // Do any additional setup after loading the view.
        videoLongPressGestureRecognizer.enabled = false
        storyTableView.delegate = self
        storyTableView.dataSource = self
        
        if (self.storyTableView.respondsToSelector(Selector("layoutMargins"))) {
            self.storyTableView.layoutMargins = UIEdgeInsetsZero;
        }
        
        holdToRecordLabel.layer.borderColor = UIColor.whiteColor().CGColor
        holdToRecordLabel.layer.borderWidth = 3.0;
        holdToRecordLabel.layer.cornerRadius = 17
        holdToRecordLabel.clipsToBounds = true

        createViewHeightConstraint.constant = self.view.bounds.width + 46
        
        
//        createButton = UIBarButtonItem(title: "+ Event", style: .Plain, target: self, action: "createButtonWasTapped")
        settingsButton = UIBarButtonItem(image: UIImage(named: "gearIcon"), style: .Plain, target: self, action: "settingsButtonWasTapped")
        self.navigationItem.rightBarButtonItem = settingsButton!
        
        if newStory == false {
//            self.storyTitleLabel.text = self.story!["title"] as? String
            if story!["points"] != nil {
                var points = story!["points"] as? Int
                self.storyPointsLabel.text = "\(points!)"
            }
            
            var storyUser : PFUser = self.story!["user"] as! PFUser
            storyUser.fetchIfNeededInBackgroundWithBlock {
                (user, error) -> Void in
                
                
                if self.story!["posters"] == nil {
                    var profileName = storyUser["profileName"]
                    self.firstUser = storyUser
                    self.userLabel.text = profileName as? String
                    self.userLabel.hidden = false
                    if self.firstUser!["profileImage"] != nil {
                        var profileImageFile = self.firstUser!["profileImage"] as! PFFile
                        profileImageFile.getDataInBackgroundWithBlock {
                            (imageData, error) -> Void in
                            if error == nil {
                                let image = UIImage(data:imageData!)
                                self.userProfileImage.image = image
                            }
                        }
                    }
                } else {
                    var posters = self.story!["posters"] as! NSArray
                    if posters.count <= 1{
                        var profileName = storyUser["profileName"]
                        self.firstUser = storyUser
                        self.userLabel.text = profileName as? String
                        self.userLabel.hidden = false
                        if self.firstUser!["profileImage"] != nil {
                            var profileImageFile = self.firstUser!["profileImage"] as! PFFile
                            profileImageFile.getDataInBackgroundWithBlock {
                                (imageData, error) -> Void in
                                if error == nil {
                                    let image = UIImage(data:imageData!)
                                    self.userProfileImage.image = image
                                }
                            }
                        }
                    } else if posters.count == 2 || posters.count == 3 {
                        self.firstUser = posters.firstObject as! PFUser
                        self.firstUser!.fetchIfNeededInBackgroundWithBlock {
                            (user, error) -> Void in
                            if self.firstUser!["profileImage"] != nil {
                                var profileImageFile = self.firstUser!["profileImage"] as! PFFile
                                profileImageFile.getDataInBackgroundWithBlock {
                                    (imageData, error) -> Void in
                                    if error == nil {
                                        let image = UIImage(data:imageData!)
                                        self.userProfileImage.image = image
                                    }
                                }
                            }
                        }
                        self.secondUser = posters[1] as! PFUser
                        self.secondUser!.fetchIfNeededInBackgroundWithBlock {
                            (user, error) -> Void in
                            if self.secondUser!["profileImage"] != nil {
                                var profileImageFile = self.secondUser!["profileImage"] as! PFFile
                                profileImageFile.getDataInBackgroundWithBlock {
                                    (imageData, error) -> Void in
                                    if error == nil {
                                        let image = UIImage(data:imageData!)
                                        self.secondProfileImageView.image = image
                                    }
                                }
                            }
                        }
                        self.secondProfileImageView.hidden = false
                        if posters.count == 3 {
                            self.thirdUser = posters[2] as! PFUser
                            self.thirdUser!.fetchIfNeededInBackgroundWithBlock {
                                (user, error) -> Void in
                                if self.thirdUser!["profileImage"] != nil {
                                    var profileImageFile = self.thirdUser!["profileImage"] as! PFFile
                                    profileImageFile.getDataInBackgroundWithBlock {
                                        (imageData, error) -> Void in
                                        if error == nil {
                                            let image = UIImage(data:imageData!)
                                            self.thirdProfileImageView.image = image
                                            
                                        }
                                    }
                                }
                            }
                            self.thirdProfileImageView.hidden = false
                        }
                        
                    } else {
                        self.firstUser = posters.firstObject as! PFUser
                        self.firstUser!.fetchIfNeededInBackgroundWithBlock {
                            (user, error) -> Void in
                            if self.firstUser!["profileImage"] != nil {
                                var profileImageFile = self.firstUser!["profileImage"] as! PFFile
                                profileImageFile.getDataInBackgroundWithBlock {
                                    (imageData, error) -> Void in
                                    if error == nil {
                                        let image = UIImage(data:imageData!)
                                        self.userProfileImage.image = image
                                    }
                                }
                            }
                        }
                        var secondUser = posters[1] as! PFUser
                        secondUser.fetchIfNeededInBackgroundWithBlock {
                            (user, error) -> Void in
                            if secondUser["profileImage"] != nil {
                                var profileImageFile = secondUser["profileImage"] as! PFFile
                                profileImageFile.getDataInBackgroundWithBlock {
                                    (imageData, error) -> Void in
                                    if error == nil {
                                        let image = UIImage(data:imageData!)
                                        self.secondProfileImageView.image = image
                                    }
                                }
                            }
                        }
                        self.secondProfileImageView.hidden = false
                        self.morePostersButton.hidden = false
                    }
                    
                }
                
                if self.story!["commentsCount"] != nil {
                    var commentsCount = self.story!["commentsCount"]
                    self.commentsLabel.text = "\(commentsCount!) Comments"
                }
                
                
                self.createViewBottomConstraint.constant = -(self.screenSize.width + 46)
                self.createView.hidden = true
                self.createTitleView.hidden = true
                self.titleView.hidden = false
                if PFUser.currentUser() != nil {
                    var currentUser = PFUser.currentUser()
                    println("Story user is \(storyUser.username) and current user is \(currentUser!.username)")
                    if  storyUser.username == currentUser!.username {
                        self.createButton!.hidden = false
                        self.expandedButtonView.hidden = false
                        self.settingsButton!.enabled = true
                    } else if self.story!["authors"] != nil {
                        var matchCount = 0
                        for author in self.story!["authors"] as! [PFObject] {
                            if author.objectId == currentUser!.objectId {
                                matchCount += 1
                            }
                        }
                        if matchCount > 0 {
                            self.createButton!.hidden = false
                            self.expandedButtonView.hidden = false
                            self.settingsButton!.enabled = true
                        } else {
                            self.createButton!.hidden = true
                            self.expandedButtonView.hidden = true
                            self.settingsButton!.enabled = false
                            
                        }
                    } else {
                        self.createButton!.hidden = true
                        self.expandedButtonView.hidden = true
                        self.settingsButton!.enabled = false
                    }
                }
            }

            
            
            
        } else {
            createViewBottomConstraint.constant = -(screenSize.width + 46)
//            createViewTopConstraint.constant = 0
//            self.createView.hidden = false
            titleView.hidden = true
            createTitleView.hidden = false
            createButton!.hidden = true
            self.expandedButtonView.hidden = true
            settingsButton!.enabled = false
//            createButton!.title = "X"
//            createViewExpanded = true
        }
        
        cameraSendButton.layer.borderWidth = 3.0
        cameraSendButton.layer.borderColor = UIColor.whiteColor().CGColor
        cameraSendButton.layer.cornerRadius = 40
        cameraSendButton.clipsToBounds = true

//        createViewLeadingConstraint.constant = screenSize.width/4
//        createViewTrailingConstraint.constant = screenSize.width/4

        createViews = [cameraContainer, textContainer, videoContainer]
//        captureSession.sessionPreset = AVCaptureSessionPresetLow
//        let devices = AVCaptureDevice.devices()
//        println(devices)
        
        // Loop through all the capture devices on this phone
//        for device in devices {
//            // Make sure this particular device supports video
//            if (device.hasMediaType(AVMediaTypeVideo)) {
//                // Finally check the position and confirm we've got the back camera
//                if(device.position == AVCaptureDevicePosition.Back) {
//                    captureDevice = device as? AVCaptureDevice
//                }
//            } else if (device.hasMediaType(AVMediaTypeAudio)){
//                audioCaptureDevice = device as? AVCaptureDevice
//            }
//        }
//        
        
        
        self.view.updateConstraints()
        self.view.layoutIfNeeded()
        
        
        previewLayer.frame = cameraContainer.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        cameraContainer.layer.insertSublayer(previewLayer, atIndex: 0)
        
        
//        if captureDevice != nil {
//            
//            beginSession()
        configureDevice()
//
//        }
        
        if storyCreated == true {
            refreshEventsForStory()
//            GSProgressHUD.show()
        }
        
        
        // Add pull to refresh to the tableview
        self.refreshControl = UIRefreshControl()
        var pullToRefreshString = "Pull to refresh"
        var pullToRefreshAttributedString : NSMutableAttributedString = NSMutableAttributedString(string: pullToRefreshString)
        pullToRefreshAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, count(pullToRefreshString)))
        self.refreshControl.attributedTitle = pullToRefreshAttributedString
        self.refreshControl.addTarget(self, action: "refreshEventsForStory", forControlEvents: UIControlEvents.ValueChanged)
        self.storyTableView.addSubview(refreshControl)
        
    }
    
    func updateVotingLabels() {
        if PFUser.currentUser() != nil{
            if PFUser.currentUser()!["votedStories"] != nil {
                self.votedStories = PFUser.currentUser()!["votedStories"] as! NSMutableDictionary
                if self.story != nil {
                    if votedStories[self.story!.objectId!] != nil {
                        if self.story != nil{
                            if votedStories[self.story!.objectId!] as! Int == 1 {
                                storyUpVoted = true
                                storyDownVoted = false
                                upVoteButton.setImage(UIImage(named: "up_icon_green.png"), forState: UIControlState.Normal)
                                pointsLabel.textColor = UIColor(red: 15/255, green: 207/255, blue: 0/255, alpha: 1)
                            } else if votedStories[self.story!.objectId!] as! Int == -1 {
                                storyDownVoted = true
                                storyUpVoted = false
                                downVoteButton.setImage(UIImage(named: "down_icon_red.png"), forState: UIControlState.Normal)
                                pointsLabel.textColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
                            } else {
                                storyDownVoted = false
                                storyUpVoted = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func configureDevice() {
//        if let device = captureDevice {
//            device.lockForConfiguration(nil)
//            if captureDevice!.isFocusModeSupported(AVCaptureFocusMode.ContinuousAutoFocus){
//                
//                device.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
//            }
//            if (captureDevice?.focusPointOfInterestSupported != false) {
//                captureDevice?.focusPointOfInterest = CGPointMake(0.5, 0.5)
//            }
//            device.unlockForConfiguration()
//        }

        vision.delegate = self

        
        vision.cameraOrientation = PBJCameraOrientation.Portrait
        vision.cameraMode = PBJCameraMode.Photo
        vision.captureSessionPreset = AVCaptureSessionPreset1920x1080
        vision.focusMode = PBJFocusMode.ContinuousAutoFocus
        vision.outputFormat = PBJOutputFormat.Square
        vision.maximumCaptureDuration = CMTimeMakeWithSeconds(10, 600)
        vision.flashMode = PBJFlashMode.Auto
        vision.startPreview()
    }
    
//    func beginSession() {
//        var err : NSError? = nil
//        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
//        captureSession.addInput(AVCaptureDeviceInput(device: audioCaptureDevice, error: &err))
//        
//        if err != nil {
//            println("error: \(err?.localizedDescription)")
//        }
//        
//
//
//        
//        
//        var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//        self.cameraContainer.layer.insertSublayer(previewLayer, atIndex: 0)
//        previewLayer?.frame = CGRectMake(0, 0, cameraContainer.layer.frame.width, cameraContainer.layer.frame.height)
//        captureSession.startRunning()
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Table returning \(self.events.count) cells")
        if maxReached == true {
            return self.events.count
        } else {
            return self.events.count + 1
        }

        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var event : PFObject?
        if indexPath.row == storyTableView.numberOfRowsInSection(0)-1 && maxReached == false {
            var cell = tableView.dequeueReusableCellWithIdentifier("SpinnerCell") as! UITableViewCell
            if (cell.respondsToSelector(Selector("layoutMargins"))) {
                cell.layoutMargins = UIEdgeInsetsZero;
            }
            return cell
        } else {
            if events.count > 0 {
                event = events[indexPath.row] as! PFObject
                if event!["type"] as! NSString == "text" {
                    var cell = storyTableView.dequeueReusableCellWithIdentifier("StoryTextTableViewCell") as! StoryTextTableViewCell
                    if (cell.respondsToSelector(Selector("layoutMargins"))) {
                        cell.layoutMargins = UIEdgeInsetsZero;
                    }
                    cell.prepareForReuse()
                    cell.event = event
                    cell.delegate = self
                    cell.populateCellWithEvent(event!)
                    
                    return cell
                } else if event!["type"] as! String == "photo" {
                    var cell = storyTableView.dequeueReusableCellWithIdentifier("StoryImageTableViewCell") as! StoryImageTableViewCell
                    if (cell.respondsToSelector(Selector("layoutMargins"))) {
                        cell.layoutMargins = UIEdgeInsetsZero;
                    }
                    cell.prepareForReuse()
                    cell.event = event
                    cell.delegate = self
                    cell.populateCellWithEvent(event!)
                    if indexPath.row == 0 {
                        if photoJustCreated == true {
                            cell.eventImageView.image = squareImageWithImage(capturedImage!)
                        }
                    }
                    return cell
                } else {
                    var cell = storyTableView.dequeueReusableCellWithIdentifier("StoryVideoTableViewCell") as! StoryVideoTableViewCell
                    if (cell.respondsToSelector(Selector("layoutMargins"))) {
                        cell.layoutMargins = UIEdgeInsetsZero;
                    }
                    cell.prepareForReuse()
                    cell.event = event
                    cell.delegate = self
                    
                    
                    
                    if event!.createdAt == nil {
                        cell.timestampLabel.text = "0s ago"
                    } else {
                        cell.timestampLabel.text = timeSinceTimeStamp(event!.createdAt!)
                    }
                    
                    if indexPath.row == 0  && videoJustCreated == true {
                        var movieURL = NSURL(fileURLWithPath: self.videoPath!)
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
                    } else {
                        let videoFile = event!["video"] as! PFFile
                        videoFile.getDataInBackgroundWithBlock {
                            (videoData, error) -> Void in
                            if error == nil {
                                var path = "\(self.documentPath)/\(indexPath.row).mp4"
                                if (NSFileManager.defaultManager().fileExistsAtPath(path)) {
                                    NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
                                }
                                
                                videoData!.writeToFile(path, atomically: true)
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
                    }
                    
                    if event!["user"] != nil {
                        var eventUser = event!["user"] as! PFUser
                        eventUser.fetchIfNeededInBackgroundWithBlock {
                            (post, error) -> Void in
                            if eventUser["profileName"] != nil {
                                var profileName : String = eventUser["profileName"] as! String
                                cell.userNameButton.setTitle("  \(profileName)  ", forState: UIControlState.Normal)
                                cell.userNameButton.hidden = false
                            }
                            if eventUser["profileImage"] != nil {
                                var profileImageFile = eventUser["profileImage"] as! PFFile
                                profileImageFile.getDataInBackgroundWithBlock {
                                    (imageData, error) -> Void in
                                    if error == nil {
                                        let image = UIImage(data:imageData!)
                                        cell.profileImageView.image = image
                                        cell.profileImageView.alpha = 0
                                        cell.profileImageView.hidden = false
                                        UIView.animateWithDuration(0.3, animations: {
                                            cell.profileImageView.alpha = 1
                                            }, completion: {
                                                (value: Bool) in
                                                
                                        })
                                    }
                                }
                            }
                            if PFUser.currentUser() != nil {
                                var currentUser = PFUser.currentUser()!
                                currentUser.fetchIfNeededInBackgroundWithBlock {
                                    (post, error) -> Void in
                                    println("Event user is \(eventUser.username) and current user is \(currentUser.username)")
                                    if  eventUser.username == currentUser.username {
                                        cell.deleteButton!.hidden = false
                                    } else {
                                        cell.deleteButton!.hidden = true
                                    }
                                }
                            } else {
                                cell.deleteButton!.hidden = true
                            }
                            
                        }
                    } else {
                        cell.deleteButton!.hidden = true
                    }
                    
                    return cell
                    
                }
                
            } else {
                return UITableViewCell()
            }

        }
        
    }
    
    @IBAction func createButtonWasTapped(sender: AnyObject) {
        createButtonWasTapped()
    }
    
    func createButtonWasTapped() {
        pauseVideoIfPlaying()
        self.view.endEditing(true)
        if PFUser.currentUser() != nil {
            if PFUser.currentUser()!["profileName"] != nil {
                if self.createViewExpanded == true {
                    self.minimizeCreateView()
                } else {
                    self.expandCreateView(true)
                }
            } else {
                presentCreateProfileViewController()
            }
            
        } else {
            presentLoginViewController()
        }
    }
    
    func expandCreateView(defaultBehavior : Bool) {
        self.view.endEditing(true)
        self.view.layoutIfNeeded()
        self.createView.hidden = false
        self.createViewHeightConstraint.constant = self.view.bounds.width + 46
        self.createViewBottomConstraint.constant = 0
        
        cameraContainer.layer.insertSublayer(previewLayer, atIndex: 0)
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
            
            }, completion: {
                (value: Bool) in
                self.createView.hidden = false
                if self.newStory != true {
                    self.createButton!.hidden = false
                    self.expandedButtonView.hidden = false
                    self.settingsButton!.enabled = true

                } else {
                    self.createButton!.hidden = true
                    self.expandedButtonView.hidden = true
                    self.settingsButton!.enabled = false
                }
//                self.createButton!.title = "Cancel"
                self.createButton.setImage(UIImage(named: "cancelIcon"), forState: UIControlState.Normal)

                self.createViewExpanded = true
            })
        
        pauseVideoIfPlaying()
        
        if defaultBehavior == true {
            vision.cameraMode = PBJCameraMode.Photo
            vision.captureSessionPreset = AVCaptureSessionPreset1920x1080
            
            cameraSendButton.hidden = false
            cameraSendButton.enabled = true
            holdToRecordLabel.hidden = true
            recordingActivityIndicator.hidden = true
            videoLongPressGestureRecognizer.enabled = false
            for view in createViews {
                (view as! UIView).hidden = true
                cameraContainer.hidden = false
            }
            
            
            vision.startPreview()
        }
        
        
    }
    


    @IBAction func closeCompose(sender: AnyObject) {
        minimizeCreateView()
    }
    
    func minimizeCreateView() {
        if PFUser.currentUser() != nil {
            if self.story != nil {
                var storyUser = self.story!["user"] as! PFUser
                storyUser.fetchIfNeededInBackgroundWithBlock {
                    (post, error) -> Void in
                    var currentUser = PFUser.currentUser()
                    println("Story user is \(storyUser.username) and current user is \(currentUser!.username)")
                    
                    if  storyUser.username == currentUser!.username {
                        self.createButton!.hidden = false
                        self.expandedButtonView.hidden = false
                        self.settingsButton!.enabled = true
                    } else if self.story!["authors"] != nil {
                        var matchCount = 0
                        for author in self.story!["authors"] as! [PFObject] {
                            if author.objectId == currentUser!.objectId {
                                matchCount += 1
                            }
                        }
                        if matchCount > 0 {
                            self.createButton!.hidden = false
                            self.expandedButtonView.hidden = false
                            self.settingsButton!.enabled = true
                        } else {
                            self.createButton!.hidden = true
                            self.expandedButtonView.hidden = true
                            self.settingsButton!.enabled = false

                        }
                    } else {
                        self.createButton!.hidden = true
                        self.expandedButtonView.hidden = true
                        self.settingsButton!.enabled = false
                    }
                }
            }
            
        }
        
        self.view.layoutIfNeeded()
        
        self.createViewBottomConstraint.constant = -(screenSize.width + 46)
        //        createViewLeadingConstraint.constant = screenSize.width/4
        //        createViewTrailingConstraint.constant = screenSize.width/4
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
            }, completion: {
                (value: Bool) in
                self.createView.hidden = true
                self.createViewExpanded = false
//                self.createButton!.title = "+ Event"
                self.createButton.setImage(UIImage(named: "plusIcon"), forState: UIControlState.Normal)
                self.vision.stopPreview()
//                self.vision.endVideoCapture()
        })
        videoLongPressGestureRecognizer.enabled = false
        for view in createViews {
            (view as! UIView).hidden = true
            cameraContainer.hidden = false
        }
        
        self.storyTableView.hidden = false
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func createTextEvent() {
        self.upVoteButton.enabled = true
        self.downVoteButton.enabled = true
        self.userTapGestureRecognizer.enabled = true
        self.commentsButton.enabled = true
        self.profileImageButton.enabled = true
        self.createButton!.hidden = false
        self.expandedButtonView.hidden = false
        self.settingsButton!.enabled = true
        var event: PFObject = PFObject(className: "Event")
        event["type"] = "text"
        event["storyObject"] = self.story!
        if PFUser.currentUser() != nil {
            event["user"] = PFUser.currentUser()
        }
        event["text"] = self.createTextView.text
        var temporaryEventsArray = NSMutableArray(array: self.events)
        temporaryEventsArray.insertObject(event, atIndex: 0)
        self.events = temporaryEventsArray
        self.photoJustCreated = false
        self.videoJustCreated = false
        self.storyTableView.reloadData()
        event.saveInBackgroundWithBlock({
            (success, error) -> Void in
            if (success) {
                // The object has been saved.
                println("Event successfully saved")
                
                
                
                println("Adding storychannel: \(self.story!.objectId!)")
                self.installation.addUniqueObject("\(self.story!.objectId!)", forKey: "channels")
                self.story!.addUniqueObject(PFUser.currentUser()!, forKey: "posters")
//                PFUser.currentUser()!.addUniqueObject(self.story!, forKey: "postedStories")
                PFUser.currentUser()!.saveInBackground()
                self.story!.saveInBackground()
                var currentChannels = self.installation["channels"]
                println("Story ID: \(self.story!.objectId!), Current Channels: \(currentChannels!)")
                self.installation.saveInBackground()
                
                self.minimizeCreateView()
                if self.story!["thumbnailText"] == nil {
                    self.story!["thumbnailText"] = self.createTextView.text
                    self.story!.saveInBackground()
                }
                self.createTextView.text = ""
                self.buttonActivityIndicator.hidden = true
                self.createButton.setImage(UIImage(named: "plusIcon"), forState: UIControlState.Disabled)
                self.createButton.enabled = true
                self.createButtonLongPressGestureRecognizer.enabled = true
                self.buttonActivityIndicator.stopAnimating()
                
                
                if self.newStory == false {
                    let pushQuery = PFInstallation.query()!
                    pushQuery.whereKey("channels", equalTo: "\(self.story!.objectId!)") // Set channel
                    pushQuery.whereKey("objectId", notEqualTo: self.installation.objectId!)
                    pushQuery.whereKey("storyNotificationsOn", notEqualTo: false)
                    
                    var currentUserProfileName = PFUser.currentUser()!["profileName"]
                    var storyTitle = self.story!["title"]
                    let data = [
                        "alert" : "\(currentUserProfileName!) has added a post to the story: \(storyTitle!)",
                        "storyID" : self.story!.objectId!
                    ]
                    let push = PFPush()
                    push.setQuery(pushQuery)
                    push.setData(data)
                    push.sendPushInBackgroundWithBlock({
                        (success, error) -> Void in
                        if success == true {
                            println("Push query successful")
                        } else {
                            println("Push encountered error: \(error!.description)")
                        }
                    })
                }
            } else {
                // There was a problem, check error.description
                println("There was an error saving the event: \(error!.description)")
                self.buttonActivityIndicator.hidden = true
                self.createButton.setImage(UIImage(named: "plusIcon"), forState: UIControlState.Disabled)
                self.createButton.enabled = true
                self.createButtonLongPressGestureRecognizer.enabled = true
                self.buttonActivityIndicator.stopAnimating()
            }
        })
        self.noEventsLabel.hidden = true
        self.newStory = false
    }

    @IBAction func textSubmitButtonWasTapped(sender: AnyObject) {
        self.buttonActivityIndicator.startAnimating()
        self.createButton.setImage(UIImage(), forState: UIControlState.Disabled)
        self.buttonActivityIndicator.hidden = false
        self.createButton.enabled = false
        self.createButtonLongPressGestureRecognizer.enabled = false
        self.view.endEditing(true)
        
        self.minimizeCreateView()
        self.view.layoutIfNeeded()
        
       
        self.createViewHeightConstraint.constant = self.view.bounds.width + 46
        
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
            
        })

        
        if (self.story != nil) {
            self.createTextEvent()
        } else {
            
            self.story = PFObject(className: "Story")
            self.story!["title"] = titleTextField.text
            self.story!["user"] = PFUser.currentUser()
            var upvotes = 1
            var downvotes = 0
            self.story!["upvotes"] = upvotes
            self.story!["downvotes"] = downvotes
            var points = upvotes - downvotes
            self.story!["points"] = points
            self.story!["rankingValue"] = rankingAlgo(1, downvotes: 0, time: NSDate())
            self.story!.saveInBackgroundWithBlock({
                (success, error) -> Void in
                if (success) {
                    // The object has been saved.
                    println("Story and event successfully saved")
//                    self.storyTitleLabel.text = self.story!["title"] as? String
                    if  PFUser.currentUser()!["profileName"] != nil {
                        self.userLabel.text = PFUser.currentUser()!["profileName"] as! String
                    }
                                        var upvotes = self.story!["upvotes"] as? Int
                    var downvotes = self.story!["downvotes"] as? Int
                    self.storyUpVoted = true
                    self.storyDownVoted = false
                    self.votedStories[self.story!.objectId!] = 1
                    PFUser.currentUser()!["votedStories"] = self.votedStories
                    PFUser.currentUser()!.saveInBackground()
                    self.upVoteButton.setImage(UIImage(named: "up_icon_green.png"), forState: UIControlState.Normal)
                    self.pointsLabel.textColor = UIColor(red: 15/255, green: 207/255, blue: 0/255, alpha: 1)
                    self.storyPointsLabel.text = "\(points)"
                    self.createTitleView.hidden = true
                    self.titleView.hidden = false
                    self.createTextEvent()
                    
                } else {
                    // There was a problem, check error.description
                    println("There was an error saving the story: \(error!.description)")
                    self.buttonActivityIndicator.hidden = true
                    self.createButton.setImage(UIImage(named: "plusIcon"), forState: UIControlState.Disabled)
                    self.createButton.enabled = true
                    self.createButtonLongPressGestureRecognizer.enabled = true
                    self.buttonActivityIndicator.stopAnimating()
                }
            })
        
        }
        self.newStory = false
    }

    @IBAction func videoSelectorWasTapped(sender: AnyObject) {
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
        recordingActivityIndicator.hidden = true
        videoLongPressGestureRecognizer.enabled = true
        for view in createViews {
            (view as! UIView).hidden = true
            cameraContainer.hidden = false
        }
        vision.startPreview()
//        if captureSession.canSetSessionPreset(AVCaptureSessionPresetHigh){
//            captureSession.sessionPreset = AVCaptureSessionPresetHigh
//        }
//        if captureSession.outputs.count > 0 {
//            for output in captureSession.outputs {
//                captureSession.removeOutput(output as AVCaptureOutput)
//            }
//        }
//        
//
//        
//        videoOutput = AVCaptureMovieFileOutput()
//        
//        videoOutput?.minFreeDiskSpaceLimit = 1024 * 1024;						//<<SET MIN FREE SPACE IN BYTES FOR RECORDING TO CONTINUE ON A VOLUME
//        
//
//        if captureSession.canAddOutput(videoOutput) {
//            captureSession.addOutput(videoOutput)
//            println("video output added")
//        }
        

    }

    
    @IBAction func cameraSelectorWasTapped(sender: AnyObject) {
        self.view.endEditing(true)
        self.view.layoutIfNeeded()
        var createViewRect : CGRect = self.createView.bounds
        self.createViewHeightConstraint.constant = self.view.bounds.width + 46
        
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
            
        })
        
        vision.cameraMode = PBJCameraMode.Photo
        vision.captureSessionPreset = AVCaptureSessionPreset1920x1080
        cameraSendButton.hidden = false
        cameraSendButton.enabled = true
        holdToRecordLabel.hidden = true
        recordingActivityIndicator.hidden = true
        videoLongPressGestureRecognizer.enabled = false
        for view in createViews {
            (view as! UIView).hidden = true
            cameraContainer.hidden = false
        }


       vision.startPreview()
        
        //        if captureSession.canSetSessionPreset(AVCaptureSessionPresetHigh){
        //                captureSession.sessionPreset = AVCaptureSessionPresetHigh
        //        }
        //
        //        if captureSession.outputs.count > 0 {
        //            for output in captureSession.outputs {
        //                captureSession.removeOutput(output as AVCaptureOutput)
        //            }
        //        }
        //
        //        stillImageOutput = AVCaptureStillImageOutput()
        //        stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        //        if captureSession.canAddOutput(stillImageOutput) {
        //            captureSession.addOutput(stillImageOutput)
        //            println("still image output added")
        //        }
        
    }


    @IBAction func textSelectorWasTapped(sender: AnyObject) {
        println("Text button was tapped")
        videoLongPressGestureRecognizer.enabled = false
        for view in createViews {
            (view as! UIView).hidden = true
            textContainer.hidden = false
        }
        self.createTextView.becomeFirstResponder()

    }
    
    func deleteVideoFiles() {
        var documentFiles = NSFileManager.defaultManager().contentsOfDirectoryAtPath(documentPath as String, error: nil)
        for file in documentFiles! {
            NSFileManager.defaultManager().removeItemAtPath("\(documentPath)/file", error: nil)
        }
    }
    
    func refreshEventsForStory() {
        self.events = []
        requestEventsForStory(self, offset: 0)
    }
    
    func requestEventsForStory(sender:AnyObject, offset: Int) {
        maxReached = false
        
        dispatch_async(dispatch_get_main_queue(),{
            var query = PFQuery(className:"Event")
            query.whereKey("storyObject", equalTo:self.story!)
            query.orderByDescending("createdAt")
            query.limit = 5
            if offset == 0 {
                self.events = []
                self.currentOffset = 0
            }
            print("Query skipping \(self.currentOffset) stories")
            query.skip = self.currentOffset
            query.findObjectsInBackgroundWithBlock {
                (objects, error) -> Void in
                if error == nil {
                    // The find succeeded.
                    println("Successfully retrieved \(objects!.count) events.")
//                    for object in objects {
//                        var objectTitle = object["title"]
//                        println("This is the object's title: \(objectTitle!))")
//                    }
                    if objects!.count == 0 || objects!.count < 5 {
                        self.maxReached = true
                    }
                    
                    
                    
                    var temporaryArray : NSMutableArray = NSMutableArray(array: self.events)
                    temporaryArray.addObjectsFromArray(objects!)
                    self.events = temporaryArray
                    
                    if self.events.count == 0 {
                        self.noEventsLabel.hidden = false
                    } else {
                        self.noEventsLabel.hidden = true
                    }
                    self.currentOffset = self.events.count
                    
                    self.storyTableView.reloadData()
//                    print("This is a list of all the events \(self.events)")
                    self.refreshControl.endRefreshing()
                    //                    if(GSProgressHUD.isVisible()) {
                    //                        GSProgressHUD.dismiss()
                    //                    }
                    self.requestingObjects = false
                } else {
                    // Log details of the failure
                    println("Error: \(error!) \(error!.userInfo!)")
                    self.refreshControl.endRefreshing()
                    //                    if(GSProgressHUD.isVisible()) {
                    //                        GSProgressHUD.dismiss()
                    //                    }
                }
            }
        })
        
    }

    override func viewWillAppear(animated: Bool) {
        self.createViewBottomConstraint.constant = -(screenSize.width + 46)
        self.createViewHeightConstraint.constant = self.view.bounds.width + 46
        self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(animated: Bool) {
        if self.story != nil {
            if self.story!["commentsCount"] != nil {
                var commentsCount = self.story!["commentsCount"]
                self.commentsLabel.text = "\(commentsCount!) Comments"
            }
        }
        self.vision.delegate = self
        
    }
    
    @IBAction func storyTableViewWasTapped(sender: AnyObject) {
        minimizeCreateView()
        self.view.endEditing(true)
    }
    
    @IBAction func videoLongPressGestureRecognizerWasTapped(sender: AnyObject) {
        if sender.state == UIGestureRecognizerState.Began {
            holdToRecordLabel.hidden = true
            recordingActivityIndicator.hidden = false
//            var filename = "Video1"
//            videoPath =  "\(documentPath)/\(filename).mp4"
//
//            self.videoOutput?.startRecordingToOutputFileURL(NSURL(fileURLWithPath: self.videoPath!), recordingDelegate: self)
            vision.startVideoCapture()
        }
        
        if sender.state == UIGestureRecognizerState.Cancelled {
//            self.videoOutput?.stopRecording()
//            holdToRecordLabel.hidden = false
            vision.endVideoCapture()
        }
        
        if sender.state == UIGestureRecognizerState.Ended {
//            self.videoOutput?.stopRecording()
            holdToRecordLabel.hidden = false
            recordingActivityIndicator.hidden = true
            vision.endVideoCapture()
        }
    }
    
    func vision(vision: PBJVision!, capturedVideo videoDict: [NSObject : AnyObject]!, error: NSError!) {
        
        
        dispatch_async(dispatch_get_main_queue(),{
            self.videoPath = videoDict[PBJVisionVideoPathKey] as! String
            if self.videoPath != nil {
                UISaveVideoAtPathToSavedPhotosAlbum(self.videoPath, nil, nil, nil)
            }
            self.saveVideoEvent()
        })
        self.minimizeCreateView()
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        println("Video recording started")
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        
        
        
//        var data = NSData(contentsOfURL: outputFileURL)
        println("Successfully saved video at \(outputFileURL)")
        
        
//        var filename = "CroppedVideo1"
//        croppedVideoPath =  "\(documentPath)/\(filename).mp4"
//
//        var asset : AVAsset = AVAsset.assetWithURL(outputFileURL) as AVAsset
//
//        var composition : AVMutableComposition = AVMutableComposition()
//        composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
//
//        var clipVideoTrack : AVAssetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack
//
//        var videoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
//        videoComposition.frameDuration = CMTimeMake(1, 60)
//        videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.height)
//
//        var instruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
//        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30))
//
//
//        var transformer: AVMutableVideoCompositionLayerInstruction =
//        AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
//
//
//        var t1: CGAffineTransform = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, -(clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height)/2 )
//        var t2: CGAffineTransform = CGAffineTransformRotate(t1, CGFloat(M_PI_2))
//
//        var finalTransform: CGAffineTransform = t2
//
//        transformer.setTransform(finalTransform, atTime: kCMTimeZero)
//
//        instruction.layerInstructions = NSArray(object: transformer)
//        videoComposition.instructions = NSArray(object: instruction)
//
//
//        var exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
//        exporter.videoComposition = videoComposition
//        exporter.outputFileType = AVFileTypeQuickTimeMovie
//        exporter.outputURL = NSURL(fileURLWithPath: croppedVideoPath!)
//
//        exporter.exportAsynchronouslyWithCompletionHandler({
//            
//            //display video after export is complete, for example...
//            let outputURL:NSURL = exporter.outputURL;
//            println("Cropped video saved at \(outputURL)")
//            self.saveVideoEvent()
//            
//        })        

        self.saveVideoEvent()
        
    }
    
    func createVideoEvent(videoFile : PFFile) {
        self.upVoteButton.enabled = true
        self.downVoteButton.enabled = true
        self.userTapGestureRecognizer.enabled = true
        self.commentsButton.enabled = true
        self.profileImageButton.enabled = true
        self.createButton!.hidden = false
        self.expandedButtonView.hidden = false
        self.settingsButton!.enabled = true
        var event: PFObject = PFObject(className: "Event")
        event["type"] = "video"
        event["storyObject"] = self.story!
        if PFUser.currentUser() != nil {
            event["user"] = PFUser.currentUser()
        }
        event["video"] = videoFile
        var temporaryEventsArray = NSMutableArray(array: self.events)
        temporaryEventsArray.insertObject(event, atIndex: 0)
        self.events = temporaryEventsArray
        self.photoJustCreated = false
        self.videoJustCreated = true
        self.storyTableView.reloadData()
        event.saveInBackgroundWithBlock({
            (success, error) -> Void in
            if (success) {
                // The object has been saved.
                println("Event successfully saved")
                
                
                
                println("Adding storychannel: \(self.story!.objectId!)")
                self.story!.addUniqueObject(PFUser.currentUser()!, forKey: "posters")
//                PFUser.currentUser()!.addUniqueObject(self.story!, forKey: "postedStories")
                PFUser.currentUser()!.saveInBackground()
                self.story!.saveInBackground()
                self.installation.addUniqueObject("\(self.story!.objectId!)", forKey: "channels")
                self.installation.saveInBackground()
                self.vision.stopPreview()
                if self.story!["thumbnailVideoScreenCap"] == nil {
                    if self.story!["thumbnailImage"] == nil {
                        var asset : AVURLAsset = AVURLAsset(URL: NSURL(fileURLWithPath: self.videoPath!), options: nil)
                        var generate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
                        var time : CMTime = CMTimeMake(1, 60)
                        var imgRef : CGImageRef = generate.copyCGImageAtTime(time, actualTime: nil, error: nil)
                        var screenCapImage = UIImage(CGImage: imgRef)
                        
                        
                        var screenCapImageData = UIImageJPEGRepresentation(screenCapImage, 1.0)
                        var imageFile : PFFile = PFFile(name: "image.png", data: screenCapImageData)
                        self.story!["thumbnailVideoScreenCap"] = imageFile
                        self.story!.saveInBackground()
                        
                    }
                }
                self.buttonActivityIndicator.hidden = true
                self.createButton.setImage(UIImage(named: "plusIcon"), forState: UIControlState.Disabled)
                self.createButton.enabled = true
                self.createButtonLongPressGestureRecognizer.enabled = true
                self.buttonActivityIndicator.stopAnimating()
                if self.newStory == false {
                    let pushQuery = PFInstallation.query()!
                    pushQuery.whereKey("channels", equalTo: "\(self.story!.objectId!)") // Set channel
                    pushQuery.whereKey("objectId", notEqualTo: self.installation.objectId!)
                    pushQuery.whereKey("storyNotificationsOn", notEqualTo: false)
                    
                    
                    var currentUserProfileName = PFUser.currentUser()!["profileName"]
                    var storyTitle = self.story!["title"]
                    let data = [
                        "alert" : "\(currentUserProfileName!) has added a video to the story: \(storyTitle!)",
                        "storyID" : self.story!.objectId!
                    ]
                    let push = PFPush()
                    push.setQuery(pushQuery)
                    push.setData(data)
                    push.sendPushInBackgroundWithBlock({
                        (success, error) -> Void in
                        if success == true {
                            println("Push query successful")
                        } else {
                            println("Push encountered error: \(error!.description)")
                        }
                    })
                }
            } else {
                // There was a problem, check error.description
                println("There was an error saving the event: \(error!.description)")
                self.buttonActivityIndicator.hidden = true
                self.createButton.setImage(UIImage(named: "plusIcon"), forState: UIControlState.Disabled)
                self.createButton.enabled = true
                self.createButtonLongPressGestureRecognizer.enabled = true
                self.buttonActivityIndicator.stopAnimating()
            }
        })
        self.noEventsLabel.hidden = true
        self.newStory = false
    }
    
    func saveVideoEvent() {
        self.buttonActivityIndicator.startAnimating()
        self.createButton.setImage(UIImage(), forState: UIControlState.Disabled)
        self.buttonActivityIndicator.hidden = false
        self.createButton.enabled = false
        self.createButtonLongPressGestureRecognizer.enabled = false
//        self.progressViewTrailingConstraint.constant = self.screenSize.width
        self.view.layoutIfNeeded()
//        self.progressView.hidden = false
        var videoFile = PFFile(name: "video.mp4", contentsAtPath: "\(self.videoPath!)")
        
        videoFile.saveInBackgroundWithBlock({
            (success, error) -> Void in
                if (success) {
                    println("Video successfully uploaded")
                } else {
                    println("There was an error saving the video file: \(error!.description)")
//                    self.progressView.hidden = true
                }
        
            }, progressBlock: {
                (percentDone: CInt) -> Void in
                if percentDone == 100 {
//                    self.progressView.hidden = true
                } else if percentDone != 0 {
                    self.view.layoutIfNeeded()
                    
//                    self.progressViewTrailingConstraint.constant = CGFloat(self.screenSize.width)*CGFloat(percentDone/100) as CGFloat
                    
                    
                    UIView.animateWithDuration(0.3, animations: {
                        self.view.layoutIfNeeded()
                        
                    })
                    
                    
                }
        
        })
        
        if (self.story != nil) {
            createVideoEvent(videoFile)
        } else {
            
            self.story = PFObject(className: "Story")
            self.story!["title"] = self.titleTextField.text
            self.story!["user"] = PFUser.currentUser()
            var upvotes = 1
            var downvotes = 0
            self.story!["upvotes"] = upvotes
            self.story!["downvotes"] = downvotes
            var points = upvotes - downvotes
            self.story!["points"] = points
            self.story!["rankingValue"] = rankingAlgo(1, downvotes: 0, time: NSDate())
            self.story!.saveInBackgroundWithBlock({
                (success, error) -> Void in
                if (success) {
                    // The object has been saved.
//                    self.storyTitleLabel.text = self.story!["title"] as? String
                    if  PFUser.currentUser()!["profileName"] != nil {
                        self.userLabel.text = PFUser.currentUser()!["profileName"] as! String
                    }
                    var upvotes = self.story!["upvotes"] as? Int
                    var downvotes = self.story!["downvotes"] as? Int
                    self.storyPointsLabel.text = "\(points)"
                    self.storyUpVoted = true
                    self.storyDownVoted = false
                    self.votedStories[self.story!.objectId!] = 1
                    PFUser.currentUser()!["votedStories"] = self.votedStories
                    PFUser.currentUser()!.saveInBackground()
                    self.upVoteButton.setImage(UIImage(named: "up_icon_green.png"), forState: UIControlState.Normal)
                    self.pointsLabel.textColor = UIColor(red: 15/255, green: 207/255, blue: 0/255, alpha: 1)
                    self.createTitleView.hidden = true
                    self.titleView.hidden = false
                    self.createVideoEvent(videoFile)
                    
                    
                } else {
                    // There was a problem, check error.description
                    println("There was an error saving the story: \(error!.description)")
                    self.buttonActivityIndicator.hidden = true
                    self.createButton.setImage(UIImage(named: "plusIcon"), forState: UIControlState.Disabled)
                    self.createButton.enabled = true
                    self.createButtonLongPressGestureRecognizer.enabled = true
                    self.buttonActivityIndicator.stopAnimating()
                }
            })
            
        }
    }
    
    func vision(vision: PBJVision!, capturedPhoto photoDict: [NSObject : AnyObject]!, error: NSError!) {
        capturedImage = photoDict[PBJVisionPhotoImageKey] as! UIImage
        dispatch_async(dispatch_get_main_queue(),{
            if self.capturedImage != nil {
                UIImageWriteToSavedPhotosAlbum(self.squareImageWithImage(self.capturedImage!), nil, nil, nil)
            }
            self.savePhotoEvent()
        })
    }

    @IBAction func photoSendButtonWasTapped(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue(),{
            self.vision.capturePhoto()
        })
        
        self.minimizeCreateView()
    }
    
    func createPhotoEvent(imageFile : PFFile) {
        self.upVoteButton.enabled = true
        self.downVoteButton.enabled = true
        self.userTapGestureRecognizer.enabled = true
        self.commentsButton.enabled = true
        self.profileImageButton.enabled = true
        self.createButton!.hidden = false
        self.expandedButtonView.hidden = false
        self.settingsButton!.enabled = true
        var event: PFObject = PFObject(className: "Event")
        event["type"] = "photo"
        event["storyObject"] = self.story!
        if PFUser.currentUser() != nil {
            event["user"] = PFUser.currentUser()
        }
        event["image"] = imageFile
        var temporaryEventsArray = NSMutableArray(array: self.events)
        temporaryEventsArray.insertObject(event, atIndex: 0)
        self.events = temporaryEventsArray
        self.photoJustCreated = true
        self.videoJustCreated = false
        self.storyTableView.reloadData()
        event.saveInBackgroundWithBlock({
            (success, error) -> Void in
            if (success) {
                // The object has been saved.
                println("Event successfully saved")
                
                
                
                
                
                println("Adding storychannel: \(self.story!.objectId!)")
                self.story!.addUniqueObject(PFUser.currentUser()!, forKey: "posters")
//                PFUser.currentUser()!.addUniqueObject(self.story!, forKey: "postedStories")
                PFUser.currentUser()!.saveInBackground()
                self.story!.saveInBackground()
                self.installation.addUniqueObject("\(self.story!.objectId!)", forKey: "channels")
                self.installation.saveInBackground()
                self.vision.stopPreview()
                if self.story!["thumbnailImage"] == nil {
                    self.story!["thumbnailImage"] = imageFile
                    self.story!.saveInBackground()
                }
                self.buttonActivityIndicator.hidden = true
                self.createButton.setImage(UIImage(named: "plusIcon"), forState: UIControlState.Disabled)
                self.createButton.enabled = true
                self.createButtonLongPressGestureRecognizer.enabled = true
                self.buttonActivityIndicator.stopAnimating()
                if self.newStory == false {
                    let pushQuery = PFInstallation.query()!
                    pushQuery.whereKey("channels", equalTo: "\(self.story!.objectId!)") // Set channel
                    pushQuery.whereKey("objectId", notEqualTo: self.installation.objectId!)
                    pushQuery.whereKey("storyNotificationsOn", notEqualTo: false)
                    
                    var currentUserProfileName = PFUser.currentUser()!["profileName"]
                    var storyTitle = self.story!["title"]
                    let data = [
                        "alert" : "\(currentUserProfileName!) has added a photo to the story: \(storyTitle!)",
                        "storyID" : self.story!.objectId!
                    ]
                    let push = PFPush()
                    push.setQuery(pushQuery)
                    push.setData(data)
                    push.sendPushInBackgroundWithBlock({
                        (success, error) -> Void in
                        if success == true {
                            println("Push query successful")
                        } else {
                            println("Push encountered error: \(error!.description)")
                        }
                    })
                }
            } else {
                // There was a problem, check error.description
                println("There was an error saving the event: \(error!.description)")
                self.buttonActivityIndicator.hidden = true
                self.createButton.setImage(UIImage(named: "plusIcon"), forState: UIControlState.Disabled)
                self.createButton.enabled = true
                self.createButtonLongPressGestureRecognizer.enabled = true
                self.buttonActivityIndicator.stopAnimating()
            }
        })
        self.newStory = false
        self.noEventsLabel.hidden = true
    }
    
    
    func savePhotoEvent() {
        self.buttonActivityIndicator.startAnimating()
        self.createButton.setImage(UIImage(), forState: UIControlState.Disabled)
        self.buttonActivityIndicator.hidden = false
        self.createButton.enabled = false
        self.createButtonLongPressGestureRecognizer.enabled = false

        
//        self.progressViewTrailingConstraint.constant = self.screenSize.width
        self.view.layoutIfNeeded()
//        self.progressView.hidden = false
        
        var squareImage = squareImageWithImage(capturedImage!)
        var squareImageData = UIImageJPEGRepresentation(squareImage, 1.0)
        var imageFile : PFFile = PFFile(name: "image.png", data: squareImageData)
        
        imageFile.saveInBackgroundWithBlock({
            (success, error) -> Void in
            if (success) {
                println("Image successfully uploaded")

            } else {
                println("There was an error saving the image file: \(error!.description)")
//                self.progressView.hidden = true
            }
            
            }, progressBlock: {
                (percentDone: CInt) -> Void in
                if percentDone == 100 {
//                    self.progressView.hidden = true
                } else if percentDone != 0 {
                    self.view.layoutIfNeeded()
                    
//                    self.progressViewTrailingConstraint.constant = CGFloat(self.screenSize.width)*CGFloat(percentDone/100) as CGFloat
                    
                    
                    UIView.animateWithDuration(0.3, animations: {
                        self.view.layoutIfNeeded()
                        
                    })
                    
                    
                }
                
        })

        
        if (self.story != nil) {
            self.createPhotoEvent(imageFile)
        } else {
            
            self.story = PFObject(className: "Story")
            self.story!["title"] = self.titleTextField.text
            self.story!["user"] = PFUser.currentUser()
            var upvotes = 1
            var downvotes = 0
            self.story!["upvotes"] = upvotes
            self.story!["downvotes"] = downvotes
            var points = upvotes - downvotes
            self.story!["points"] = points
            self.story!["rankingValue"] = rankingAlgo(1, downvotes: 0, time: NSDate())
            self.story!.saveInBackgroundWithBlock({
                (success, error) -> Void in
                if (success) {
                    // The object has been saved.
//                    self.storyTitleLabel.text = self.story!["title"] as? String
                    var storyUser : PFUser = PFUser.currentUser()! as PFUser
                    var profileName : String = storyUser["profileName"] as! String
                    self.userLabel.text = profileName as String
                    var upvotes = self.story!["upvotes"] as? Int
                    var downvotes = self.story!["downvotes"] as? Int
                    self.storyPointsLabel.text = "\(points)"
                    self.storyUpVoted = true
                    self.storyDownVoted = false
                    self.votedStories[self.story!.objectId!] = 1
                    PFUser.currentUser()!["votedStories"] = self.votedStories
                    PFUser.currentUser()!.saveInBackground()
                    self.upVoteButton.setImage(UIImage(named: "up_icon_green.png"), forState: UIControlState.Normal)
                    self.pointsLabel.textColor = UIColor(red: 15/255, green: 207/255, blue: 0/255, alpha: 1)
                    self.createTitleView.hidden = true
                    self.titleView.hidden = false
                    self.createPhotoEvent(imageFile)
                    
                    
                } else {
                    // There was a problem, check error.description
                    println("There was an error saving the story: \(error!.description)")
                    self.buttonActivityIndicator.hidden = true
                    self.createButton.setImage(UIImage(named: "plusIcon"), forState: UIControlState.Disabled)
                    self.createButton.enabled = true
                    self.createButtonLongPressGestureRecognizer.enabled = true
                    self.buttonActivityIndicator.stopAnimating()
                }
            })
            
        }
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
    
//    func cropVideoAtPath(video: NSURL) -> String {
//        
//        var filename = "CroppedVideo1"
//        croppedVideoPath =  "\(documentPath)/\(filename).mp4"
//        
//        var asset : AVAsset = AVAsset.assetWithURL(video) as AVAsset
//        
//        var composition : AVMutableComposition = AVMutableComposition()
//        composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
//        
//        var clipVideoTrack : AVAssetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack
//        
//        var videoComposition = AVMutableVideoComposition()
//        videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.height)
//        videoComposition.frameDuration = CMTimeMake(1, 30)
//        
//        var instruction : AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
//        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30))
//        
//        var transformer : AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
//        var t1 : CGAffineTransform = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, -(clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height) / 2)
//        var t2 : CGAffineTransform = CGAffineTransformRotate(t1, CGFloat(M_PI_2))
//        
//        
//        var finalTransform : CGAffineTransform = t2
//        transformer.setTransform(finalTransform, atTime: kCMTimeZero)
//        instruction.layerInstructions = [transformer]
//        videoComposition.instructions = [instruction]
//        
//        var exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
//        exporter.videoComposition = videoComposition
//        exporter.outputURL = NSURL(fileURLWithPath: croppedVideoPath!)
//        exporter.outputFileType = AVFileTypeQuickTimeMovie
//        
//        exporter.exportAsynchronouslyWithCompletionHandler({
//            finished in
//            
//        })
//        
//
//    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y <= 0 {
            self.titleViewTopConstraint.constant = 0
        } else {
            if (self.lastContentOffset > scrollView.contentOffset.y) {
                self.titleViewTopConstraint.constant = 0
            } else if (self.lastContentOffset < scrollView.contentOffset.y) {
                self.titleViewTopConstraint.constant = -90
            }
        }
        
        
        UIView.animateWithDuration(0.2, animations: {
            self.view.layoutIfNeeded()
            }, completion: {
                (value: Bool) in
                
        })

//        self.lastContentOffset = scrollView.contentOffset.y
        
        if (playingVideoCell != nil && playingVideoCell!.player != nil) {
            if playingVideoCell!.player!.rate == 1.0 {
                playingVideoCell!.player?.pause()
                playingVideoCell?.playButtonIconImageView.hidden = false
                
                println("Pausing video")
            }
        }
        
        var actualPosition :CGFloat = scrollView.contentOffset.y
        var contentHeight : CGFloat = scrollView.contentSize.height - 750
        
        //        println("Actual Position: \(actualPosition), Content Height: \(contentHeight)")
        if (actualPosition >= contentHeight && events.count > 0) {
            
            if self.maxReached == false && self.requestingObjects == false {
                requestingObjects = true
                requestEventsForStory(self, offset: currentOffset)
                self.storyTableView.reloadData()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var cells = storyTableView.visibleCells()
        var indexPaths = storyTableView.indexPathsForVisibleRows()
        
        
        
        var playableCells : NSMutableArray = []
        
        if indexPaths != nil {
            var cellCount = indexPaths!.count
            for (var i = 0; i < indexPaths!.count; i++) {
                if cellCompletelyOnScreen(indexPaths![i] as! NSIndexPath) {
                    playableCells.addObject(cells[i])
                    println("Cell at index \(i) is fully on screen")
                } else {
                    println("Cell at index \(i) is not fully on screen")
                }
                
            }

        }
        
        if playableCells.count > 0 && playableCells[0].player != nil {
            playingVideoCell = playableCells[0] as! StoryVideoTableViewCell
            
            if playingVideoCell!.player != nil {
                playingVideoCell!.playButtonIconImageView.hidden = true
                playingVideoCell!.player!.play()
                playingVideoCell!.player!.actionAtItemEnd = .None
                
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "restartVideoFromBeginning", name: AVPlayerItemDidPlayToEndTimeNotification, object: playingVideoCell!.player!.currentItem)
            }
            
            
            println("Playing cell")
        }
        
        
    }
    

    
    func cellCompletelyOnScreen(indexPath : NSIndexPath) -> Bool {
        var cellRect : CGRect = storyTableView.rectForRowAtIndexPath(indexPath)
        cellRect = storyTableView.convertRect(cellRect, toView: storyTableView.superview)
        var adjustedCellRect = CGRectMake(cellRect.origin.x, cellRect.origin.y + 5, cellRect.width, cellRect.height - 10)
        println("Cell Rect: \(cellRect)")
        println("StoryTableview Frame : \(storyTableView.frame)")
        var completelyVisible : Bool = CGRectContainsRect(storyTableView.frame, adjustedCellRect)
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
    
    func keyBoardWillChange(notification: NSNotification) {
        // Adjusts size of text view to scroll when keyboard is up
        var keyBoardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.view.convertRect(keyBoardRect, fromView: nil)
        
        var createViewRect : CGRect = self.createView.frame
        
        self.view.layoutIfNeeded()
        
        if CGFloat(createViewRect.origin.y) + CGFloat(createViewRect.height) > CGFloat(keyBoardRect.origin.y) {
            println("Keyboard Rect: \(keyBoardRect)")
            println("CreateView Rect: \(createViewRect)")
            self.createViewBottomConstraint.constant = keyBoardRect.height
            
            if CGFloat(keyBoardRect.origin.y) - CGFloat(createViewRect.origin.y) < 140 {
                self.createViewHeightConstraint.constant = 140
            } else {
                self.createViewHeightConstraint.constant = CGFloat(keyBoardRect.origin.y) - CGFloat(createViewRect.origin.y)
            }
            
            println("New Createview Height: \(self.createViewHeightConstraint.constant)")
        } else {
            self.createViewBottomConstraint.constant = 0
            self.createViewHeightConstraint.constant = self.view.bounds.width + 46
        }
        
        UIView.animateWithDuration(0.1, animations: {
            self.view.layoutIfNeeded()
            println("Post transform createview Rect: \(createViewRect)")
        })
        
    }

    @IBAction func upVoteButtonWasTapped(sender: AnyObject) {
        if (PFUser.currentUser() == nil){
            presentLoginViewController()
        } else {
            upvoteStory()
        }
    }
    
    
    
    @IBAction func downVoteButtonWasTapped(sender: AnyObject) {
        if (PFUser.currentUser() == nil){
            presentLoginViewController()
        } else {
            downvoteStory()
        }
    }
    
    func upvoteStory() {
        if storyUpVoted == true {
            self.votedStories[self.story!.objectId!] = 0
            storyUpVoted = false
            storyDownVoted = false
            upVoteButton.setImage(UIImage(named: "up_icon_white.png"), forState: UIControlState.Normal)
            pointsLabel.textColor = UIColor.whiteColor()
            self.story!["upvotes"] = self.story!["upvotes"] as! Int - 1
            var upvotes = story!["upvotes"] as! Int
            var downvotes = story!["downvotes"] as! Int
            self.story!["points"] = upvotes - downvotes
        } else if storyDownVoted == true {
            self.votedStories[self.story!.objectId!] = 1
            storyUpVoted = true
            storyDownVoted = false
            upVoteButton.setImage(UIImage(named: "up_icon_green.png"), forState: UIControlState.Normal)
            downVoteButton.setImage(UIImage(named: "down_icon_white.png"), forState: UIControlState.Normal)
            pointsLabel.textColor = UIColor(red: 15/255, green: 207/255, blue: 0/255, alpha: 1)
            self.story!["upvotes"] = self.story!["upvotes"] as! Int + 1
            self.story!["downvotes"] = self.story!["downvotes"] as! Int - 1
            var upvotes = story!["upvotes"] as! Int
            var downvotes = story!["downvotes"] as! Int
            self.story!["points"] = upvotes - downvotes
        }else {
            self.votedStories[self.story!.objectId!] = 1
            storyUpVoted = true
            storyDownVoted = false
            upVoteButton.setImage(UIImage(named: "up_icon_green.png"), forState: UIControlState.Normal)
            pointsLabel.textColor = UIColor(red: 15/255, green: 207/255, blue: 0/255, alpha: 1)
            self.story!["upvotes"] = self.story!["upvotes"] as! Int + 1
            var upvotes = story!["upvotes"] as! Int
            var downvotes = story!["downvotes"] as! Int
            self.story!["points"] = upvotes - downvotes
        }
        
        if self.story != nil {
            self.story!.saveInBackground()
            var points = story!["points"] as? Int
            pointsLabel.text = "\(points!)"
        }
        
        PFUser.currentUser()!["votedStories"] = self.votedStories
        PFUser.currentUser()!.saveInBackground()
    }

    
    func downvoteStory() {
        if storyDownVoted == true {
            self.votedStories[self.story!.objectId!] = 0
            storyDownVoted = false
            storyUpVoted = false
            downVoteButton.setImage(UIImage(named: "down_icon_white.png"), forState: UIControlState.Normal)
            pointsLabel.textColor = UIColor.whiteColor()
            self.story!["downvotes"] = self.story!["downvotes"] as! Int - 1
            var upvotes = story!["upvotes"] as! Int
            var downvotes = story!["downvotes"] as! Int
            self.story!["points"] = upvotes - downvotes
            
        } else if storyUpVoted == true {
            self.votedStories[self.story!.objectId!] = -1
            storyDownVoted = true
            storyUpVoted = false
            downVoteButton.setImage(UIImage(named: "down_icon_red.png"), forState: UIControlState.Normal)
            upVoteButton.setImage(UIImage(named: "up_icon_white.png"), forState: UIControlState.Normal)
            pointsLabel.textColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
            self.story!["downvotes"] = self.story!["downvotes"] as! Int + 1
            self.story!["upvotes"] = self.story!["upvotes"] as! Int - 1
            var upvotes = story!["upvotes"] as! Int
            var downvotes = story!["downvotes"] as! Int
            self.story!["points"] = upvotes - downvotes
            
        }else {
            self.votedStories[self.story!.objectId!] = -1
            storyDownVoted = true
            storyUpVoted = false
            downVoteButton.setImage(UIImage(named: "down_icon_red.png"), forState: UIControlState.Normal)
            pointsLabel.textColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
            self.story!["downvotes"] = self.story!["downvotes"] as! Int + 1
            var upvotes = story!["upvotes"] as! Int
            var downvotes = story!["downvotes"] as! Int
            self.story!["points"] = upvotes - downvotes
            
        }
        
        if self.story != nil {
            self.story!.saveInBackground()
            var points = story!["points"] as? Int
            pointsLabel.text = "\(points!)"
        }
        
        PFUser.currentUser()!["votedStories"] = self.votedStories
        PFUser.currentUser()!.saveInBackground()
    }

    
    @IBAction func cameraSwitchButtonWasTapped(sender: AnyObject) {
        if vision.cameraDevice == PBJCameraDevice.Back {
            vision.cameraDevice = PBJCameraDevice.Front
        } else {
            vision.cameraDevice = PBJCameraDevice.Back
        }
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
        
        return timeSinceEvent!

    }
    
    func presentLoginViewController() {
        var loginViewController : CustomLoginViewController = CustomLoginViewController()
        loginViewController.delegate = self
        loginViewController.facebookPermissions = NSArray(array: ["public_profile","user_friends"]) as [AnyObject]
        loginViewController.fields = PFLogInFields.Twitter | PFLogInFields.Facebook | PFLogInFields.DismissButton
//        loginViewController.fields = PFLogInFields.Twitter | PFLogInFields.DismissButton
        
        
        var signUpViewController : CustomSignUpViewController = CustomSignUpViewController()
        signUpViewController.delegate = self
        
        loginViewController.signUpController = signUpViewController
        
        self.presentViewController(loginViewController, animated: true, completion: nil)
    }
    
    func presentCreateProfileViewController() {
        var createProfileVC : CreateProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CreateProfileViewController") as! CreateProfileViewController
        createProfileVC.delegate = self
        self.presentViewController(createProfileVC, animated: true, completion: nil)
        
    }
    
    func didCreateProfile() {
        var navVC = self.parentViewController as! UINavigationController
        var hamburgerVC = navVC.parentViewController as! HamburgerViewController
        hamburgerVC.refreshLoginLabels()
    }
    
    func logInViewController(logInController: PFLogInViewController!, shouldBeginLogInWithUsername username: String!, password: String!) -> Bool {
        if ((username != nil && password != nil && count(username) != 0 && count(password) != 0) ) {
            return true
        }
        
        UIAlertView(title: "Missing Information", message: "Make sure you fill out all of the information", delegate: nil, cancelButtonTitle: "OK").show()
        
        return false
    }
    
    func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        updateVotingLabels()
//        hamburgerVC!.profileButton.enabled = true
        hamburgerVC!.refreshLoginLabels()
        installation["user"] = user
        installation.saveInBackground()
        
        if PFUser.currentUser()!["profileName"] == nil {
            var createProfileVC : CreateProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CreateProfileViewController") as! CreateProfileViewController
            createProfileVC.delegate = self
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
            var field : NSString = info["key"] as! NSString
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
        updateVotingLabels()
//        hamburgerVC!.profileButton.enabled = true
        hamburgerVC!.refreshLoginLabels()
        installation["user"] = user
        installation.saveInBackground()
        if PFUser.currentUser()!["profileName"] == nil {
            var createProfileVC : CreateProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CreateProfileViewController") as! CreateProfileViewController
            createProfileVC.delegate = self
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
    
    func presentProfileControllerWithUser(user: PFUser) {
        var profileVC : ProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
//        if self.firstUser != nil {
//            profileVC.user = self.firstUser!
//        }
        profileVC.user = user
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    
    @IBAction func userLabelWasTapped(sender: AnyObject) {
        
        presentProfileControllerWithUser(self.story!["user"] as! PFUser)

        
    }
    
    override func viewWillDisappear(animated: Bool) {
//        GSProgressHUD.dismiss()
        pauseVideoIfPlaying()
        self.view.endEditing(true)
        self.minimizeCreateView()
    }
    
    func pauseVideoIfPlaying() {
        if playingVideoCell != nil && playingVideoCell?.player?.rate == 1.0 {
            playingVideoCell?.player?.pause()
            playingVideoCell?.playButtonIconImageView.hidden = false
        }
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
    
    
    
    @IBAction func titleCreateButtonWasTapped(sender: AnyObject) {
        self.view.endEditing(true)
        self.view.layoutIfNeeded()
        self.upVoteButton.setImage(UIImage(named: "up_icon_green.png"), forState: UIControlState.Normal)
        self.pointsLabel.textColor = UIColor(red: 15/255, green: 207/255, blue: 0/255, alpha: 1)
//        self.storyTitleLabel.text = self.titleTextField.text
        self.title = self.titleTextField.text
        self.storyPointsLabel.text = "1"
        
        if  PFUser.currentUser() != nil {
            var storyUser = PFUser.currentUser()!
            self.userLabel.text = storyUser["profileName"] as! String
            self.userLabel.hidden = false
            if storyUser["profileImage"] != nil {
                var profileImageFile = storyUser["profileImage"] as! PFFile
                profileImageFile.getDataInBackgroundWithBlock {
                    (imageData, error) -> Void in
                    if error == nil {
                        let image = UIImage(data:imageData!)
                        self.userProfileImage.image = image
                    }
                }
            }
        }
        
        self.createTitleViewTopConstraint.constant = 0
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
            
            }, completion: {
                (value: Bool) in
                self.createTitleView.hidden = true
                self.titleView.hidden = false
                
                self.upVoteButton.enabled = false
                self.downVoteButton.enabled = false
                self.userTapGestureRecognizer.enabled = false
                self.commentsButton.enabled = false
                self.profileImageButton.enabled = false
                
                
                self.createButton!.hidden = true
                self.expandedButtonView.hidden = true
                self.settingsButton!.enabled = false
                self.expandCreateView(true)
        })
        
        
        
        
    }
    
    
    @IBAction func flashButtonWasTapped(sender: AnyObject) {
        if vision.flashMode == PBJFlashMode.Auto {
            vision.flashMode = PBJFlashMode.On
            cameraFlashButton.setImage(UIImage(named: "flash_icon_on.png"), forState: UIControlState.Normal)
        } else if vision.flashMode == PBJFlashMode.On {
            vision.flashMode = PBJFlashMode.Off
            cameraFlashButton.setImage(UIImage(named: "flash_icon_off.png"), forState: UIControlState.Normal)
        } else {
            vision.flashMode = PBJFlashMode.Auto
            cameraFlashButton.setImage(UIImage(named: "flash_icon_auto.png"), forState: UIControlState.Normal)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "StoryViewToCommentsViewSegue") {
            
            var commentsVC : CommentsViewController = segue.destinationViewController as! CommentsViewController
            if self.story != nil {
                commentsVC.story = self.story!
            }
        }
    }
    

    
    func displayStoryComments() {
        var commentsVC : CommentsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CommentsViewController") as! CommentsViewController
        if self.story != nil {
            commentsVC.story = self.story!
            navigationController?.pushViewController(commentsVC, animated: true)
        }
    }
    
    func displayUserProfileView(user: PFUser) {
        presentProfileControllerWithUser(self.firstUser!)
    }

    
    func deleteCell(cell: UITableViewCell) {
        if playingVideoCell != nil && playingVideoCell?.player?.rate == 1.0 {
            playingVideoCell?.player?.pause()
            playingVideoCell?.playButtonIconImageView.hidden = false
        }
        var deleteCellIndexPath : NSIndexPath = self.storyTableView.indexPathForCell(cell)!
        var temporaryCommentsArray = NSMutableArray(array: events)
        temporaryCommentsArray.removeObjectAtIndex(deleteCellIndexPath.row)
        var deletingEvent : PFObject = events[deleteCellIndexPath.row] as! PFObject
        self.events = temporaryCommentsArray
        
        storyTableView.beginUpdates()
        storyTableView.deleteRowsAtIndexPaths([deleteCellIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        storyTableView.endUpdates()
        deletingEvent.deleteInBackground()
        
        if events.count == 0 {
            noEventsLabel.hidden = false
        }
    }
    
    func settingsButtonWasTapped() {
        settingsActionSheet.showInView(self.view)
        
        
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex == 0) {
            var addAuthorVC : AddAuthorViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AddAuthorViewController") as! AddAuthorViewController
            if self.story != nil {
                addAuthorVC.story = self.story!
            }
            self.presentViewController(addAuthorVC, animated: true, completion: nil)

        } else if (buttonIndex == 1) {
            println("Delete story button tapped")
            
            var deleteAlertView = UIAlertView(title: "Delete Story", message: "Are you sure you want to delete this story?", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Delete")
            deleteAlertView.show()
        } else {
            println("Cancel button tapped")
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex == 0) {
            println("Cancel button tapped")
        } else {
            println("Delete button tapped")
            if self.story != nil {
                
                var channels = installation["channels"] as! Array<String>
                if contains(channels, "\(self.story!.objectId!)") {
                    installation.removeObject("\(self.story!.objectId!)", forKey: "channels")
                    var currentChannels = installation["channels"]
                    println("Current Channels : \(currentChannels!)")
                    installation.saveInBackground()
                }
                
                self.story!.deleteInBackgroundWithBlock({
                    (success, error) -> Void in
                    if (success) {
                        self.navigationController?.popToRootViewControllerAnimated(true)
                        var rankingViewController = self.navigationController?.viewControllers[0] as? RankingViewController
                        if rankingViewController != nil {
                            rankingViewController!.refreshStories()
                        }
                    } else {
                        println("There was an error deleting the story: \(error!.description)")
                    }
                    
                })
            }
        }
    }
    
    func rankingAlgo(upvotes: Int, downvotes: Int, time: NSDate) -> Double {
        var nowEpochSeconds = time.timeIntervalSince1970
        var seconds_since_founding = Double(abs(nowEpochSeconds - 1134028003))
        var s = Double(upvotes - downvotes)
        var order = log10(Double(max(abs(s),1)))
        
        var sign = 0
        if (s > 0) {
            sign = 1
        } else if (s < 0) {
            sign = -1
        }
        var signOrder = Double(sign) * order
        var degradedSeconds = seconds_since_founding/45000
        var finalRankingValue = signOrder + Double(degradedSeconds)
        return finalRankingValue
    }
    func expandButtonView(){
        var anim1 = CABasicAnimation(keyPath: "cornerRadius")
        anim1.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        anim1.fromValue = 40
        self.expandedButtonView.layer.cornerRadius = 220
        anim1.toValue = 220
        anim1.duration = 0.3
        self.expandedButtonViewHeightConstraint.constant = 440
        self.expandedButtonViewWidthConstraint.constant = 440
        self.expandedButtonView.layer.addAnimation(anim1, forKey: "cornerRadius")
        
        
        
        self.expandedCameraXAlignmentConstraint.constant = 150
        self.expandedTextYAlignmentConstraint.constant = 150
        self.expandedVideoXAlignmentConstraint.constant = 110
        self.expandedVideoYAlignmentConstraint.constant = 110
        UIView.animateWithDuration(0.3, animations: {
            
            self.view.layoutIfNeeded()
            //            self.expandedButtonView.transform = CGAffineTransformMakeScale(3,3)
            }, completion: {
                (value: Bool) in
                
                
        })
        
//        
//        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: nil, animations: {
//            self.view.layoutIfNeeded()
//            }, completion: {
//                (value: Bool) in
//                
//        })
        
    }
    
    func minimizeButtonView() {
        var anim1 = CABasicAnimation(keyPath: "cornerRadius")
        anim1.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        anim1.fromValue = 220
        self.expandedButtonView.layer.cornerRadius = 40
        anim1.toValue = 40
        anim1.duration = 0.3
        
        self.expandedButtonViewHeightConstraint.constant = 80
        self.expandedButtonViewWidthConstraint.constant = 80
        self.expandedCameraXAlignmentConstraint.constant = 0
        self.expandedTextYAlignmentConstraint.constant = 0
        self.expandedVideoXAlignmentConstraint.constant = 0
        self.expandedVideoYAlignmentConstraint.constant = 0
        
        self.expandedButtonView.layer.addAnimation(anim1, forKey: "cornerRadius")
        UIView.animateWithDuration(0.3, animations: {
            
            self.view.layoutIfNeeded()
//            self.expandedButtonView.transform = CGAffineTransformMakeScale(1,1)
            }, completion: {
                (value: Bool) in
                
                
        })
    }
    
    @IBAction func createButtonWasHeld(sender: AnyObject) {
        pauseVideoIfPlaying()
        if sender.state == UIGestureRecognizerState.Began {
            println("CreateButton was held")
            expandButtonView()
        }
        
        if sender.state == UIGestureRecognizerState.Cancelled {
            
        }
        
        if sender.state == UIGestureRecognizerState.Ended {
            var touch = (((sender as! UILongPressGestureRecognizer).valueForKey("_touches") as! NSArray)[0] as! UITouch).locationInView(self.view) as! CGPoint
            println("Touch: \(touch), CreateButton: \(self.createButton.frame), Camera Button: \(self.expandedCameraButton.convertRect(expandedCameraButton.frame, toView: nil)), Video Button: \(self.expandedVideoButton.convertRect(expandedVideoButton.frame, toView: nil)), Text: \(self.expandedTextButton.convertRect(expandedTextButton.frame, toView: nil))")
            
            
            
            
            if CGRectContainsPoint(self.createButton.frame, touch) || CGRectContainsPoint(self.expandedCameraButton.convertRect(self.expandedCameraButton.bounds, toView: nil), touch) {
                self.expandCreateView(true)
            }
            
            if CGRectContainsPoint(self.expandedVideoButton.convertRect(self.expandedVideoButton.bounds, toView: nil), touch) {
                self.expandCreateView(false)
                self.videoSelectorWasTapped(self)
            }
            
            
            if CGRectContainsPoint(self.expandedTextButton.convertRect(self.expandedTextButton.bounds, toView: nil), touch) {
                self.expandCreateView(false)
                self.textSelectorWasTapped(self)
            }

            minimizeButtonView()
            
        }
    }
   
    @IBAction func secondProfileImageViewWasTapped(sender: AnyObject) {
        if self.secondUser != nil {
            self.presentProfileControllerWithUser(self.secondUser!)
        }
        
    }
    @IBAction func thirdProfileImageViewWasTapped(sender: AnyObject) {
        if self.thirdUser != nil {
            self.presentProfileControllerWithUser(self.thirdUser!)
        }

    }

    @IBAction func morePostersButtonWasTapped(sender: AnyObject) {
        if self.story!["posters"] != nil {
            var postersVC : PostersViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PostersViewController") as! PostersViewController
            postersVC.posters = self.story!["posters"]! as! NSArray
            postersVC.delegate = self
            self.presentViewController(postersVC, animated: true, completion: nil)
            
        }
        
    }
    
    func posterWasSelected(user: PFUser) {
        presentProfileControllerWithUser(user)
    }

    
    
}
