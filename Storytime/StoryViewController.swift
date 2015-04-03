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


class StoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVCaptureFileOutputRecordingDelegate, PBJVisionDelegate {
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var newStory : Bool = false
    var storyCreated : Bool = false
    var story : PFObject?
    var events : NSArray?
    let captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var audioCaptureDevice : AVCaptureDevice?
    var stillImageOutput : AVCaptureStillImageOutput?
    var videoOutput : AVCaptureMovieFileOutput?
    var capturedImage : UIImage?
    var documentPath : NSString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
    var videoPath : String?
    var croppedVideoPath : String?
    var vision : PBJVision = PBJVision.sharedInstance()
    var playingVideoCell : StoryVideoTableViewCell?


    @IBOutlet weak var holdToRecordLabel: UILabel!
    
    @IBOutlet var videoLongPressGestureRecognizer: UILongPressGestureRecognizer!

    @IBOutlet weak var storyPointsLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var cameraSendButton: UIButton!
    @IBOutlet weak var storyTitleLabel: UILabel!
         @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var createTextView: UITextView!
    @IBOutlet weak var createView: UIView!
    @IBOutlet weak var createTitleView: UIView!

    @IBOutlet weak var titleTextField: UITextField!


    @IBOutlet weak var createViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var createViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var createViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var createViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var storyTableView: UITableView!
    
    @IBOutlet weak var cameraContainer: UIView!
    @IBOutlet weak var textContainer: UIView!
    @IBOutlet weak var videoContainer: UIView!
    var createViews = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        storyTableView.rowHeight = screenSize.width
        // Do any additional setup after loading the view.
        videoLongPressGestureRecognizer.enabled = false
        storyTableView.delegate = self
        storyTableView.dataSource = self
        
        holdToRecordLabel.layer.borderColor = UIColor.whiteColor().CGColor
        holdToRecordLabel.layer.borderWidth = 3.0;
        holdToRecordLabel.layer.cornerRadius = 17
        holdToRecordLabel.clipsToBounds = true

        createViewHeightConstraint.constant = self.view.bounds.width + 46
        
        var createButton :UIBarButtonItem = UIBarButtonItem(title: "+", style: .Plain, target: self, action: "createEvent")
        self.navigationItem.rightBarButtonItem = createButton
        if newStory == false {
            self.storyTitleLabel.text = self.story!["title"] as? String
            var upvotes = story!["upvotes"] as? Int
            var downvotes = story!["downvotes"] as? Int
            self.storyPointsLabel.text = "\(upvotes!-downvotes!)"

            self.userLabel.text = self.story!["user"] as? String
            createViewTopConstraint.constant = -(screenSize.width + 46)
            self.createView.hidden = true
            createTitleView.hidden = true
            titleView.hidden = false
        } else {

            createViewTopConstraint.constant = 0
            self.createView.hidden = false
            titleView.hidden = true
            createTitleView.hidden = false
            titleView.hidden = true
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
        
        var previewLayer = PBJVision.sharedInstance().previewLayer
        previewLayer.frame = cameraContainer.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        cameraContainer.layer.insertSublayer(previewLayer, atIndex: 0)
        
//        if captureDevice != nil {
//            
//            beginSession()
        configureDevice()
//
//        }
        
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
        vision.focusMode = PBJFocusMode.ContinuousAutoFocus
        vision.outputFormat = PBJOutputFormat.Square
        vision.maximumCaptureDuration = CMTimeMakeWithSeconds(10, 600)
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
        if events != nil {
            return self.events!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var event : PFObject?
        if (events != nil) {
            event = events![indexPath.row] as PFObject
            if event!["type"] as NSString == "text" {
                var cell = storyTableView.dequeueReusableCellWithIdentifier("StoryTextTableViewCell") as StoryTextTableViewCell
                cell.eventTextLabel.text = event!["text"] as? String
                cell.timestampLabel.text = "\(event!.createdAt)"
                return cell
            } else if event!["type"] as String == "photo" {
                var cell = storyTableView.dequeueReusableCellWithIdentifier("StoryImageTableViewCell") as StoryImageTableViewCell
                cell.timestampLabel.text = "\(event!.createdAt)"
                let userImageFile = event!["image"] as PFFile
                userImageFile.getDataInBackgroundWithBlock {
                    (imageData: NSData!, error: NSError!) -> Void in
                    if error == nil {
                        let image = UIImage(data:imageData)
                        cell.eventImageView.image = image
                    }
                }
                
                return cell
            } else {
                var cell = storyTableView.dequeueReusableCellWithIdentifier("StoryVideoTableViewCell") as StoryVideoTableViewCell
                
                if cell.playerLayer != nil {
                    cell.playerLayer!.removeFromSuperlayer()
                }
                
                cell.timestampLabel.text = "\(event!.createdAt)"
                
                var path = "\(documentPath)/\(indexPath.row).mp4"

                let videoFile = event!["video"] as PFFile
                videoFile.getDataInBackgroundWithBlock {
                    (videoData: NSData!, error: NSError!) -> Void in
                    if error == nil {
                        videoData.writeToFile(path, atomically: true)
                        println("File now at \(path)")
                    }
                }
                var movieURL = NSURL(fileURLWithPath: path)
                cell.player = AVPlayer(URL: movieURL)
                
                cell.playerLayer = AVPlayerLayer(player: cell.player!)
                cell.playerLayer!.frame = CGRectMake(0, 0, screenSize.width, screenSize.width)
                cell.playerLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                cell.playerLayer!.needsDisplayOnBoundsChange = true
                
                cell.contentView.layer.addSublayer(cell.playerLayer)
                cell.contentView.layer.needsDisplayOnBoundsChange = true
                
                return cell
                
            }
            
        } else {
            return UITableViewCell()
        }

    }
    
    func createEvent() {
        self.view.layoutIfNeeded()
        self.createView.hidden = false
        self.createViewTopConstraint.constant = 0
//        createViewLeadingConstraint.constant = 0
//        createViewTrailingConstraint.constant = 0
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
            
            })
        
    }

    @IBAction func closeCompose(sender: AnyObject) {
        minimizeCreateView()
    }
    
    func minimizeCreateView() {
        self.view.layoutIfNeeded()
        
        self.createViewTopConstraint.constant = -(screenSize.width + 46)
        //        createViewLeadingConstraint.constant = screenSize.width/4
        //        createViewTrailingConstraint.constant = screenSize.width/4
        UIView.animateWithDuration(0.3, animations: {
            self.view.layoutIfNeeded()
            }, completion: {
                (value: Bool) in
                self.createView.hidden = true
        })

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func textSubmitButtonWasTapped(sender: AnyObject) {
        if (story != nil) {
            var event: PFObject = PFObject(className: "Event")
            event["type"] = "text"
            event["storyObject"] = self.story!
            event["text"] = self.createTextView.text
            event.saveInBackgroundWithBlock({
                (success: Bool, error: NSError!) -> Void in
                if (success) {
                    // The object has been saved.
                    println("Event successfully saved")
                    self.minimizeCreateView()
                    self.createTextView.text = ""
                    self.requestEventsForStory()
                    self.view.endEditing(true)
                } else {
                    // There was a problem, check error.description
                    println("There was an error saving the event: \(error.description)")
                }
            })
        } else {
            
            story = PFObject(className: "Story")
            story!["title"] = titleTextField.text
            story!["user"] = PFUser.currentUser().username
            story!["upvotes"] = 1
            story!["downvotes"] = 0
            story!.saveInBackgroundWithBlock({
                (success: Bool, error: NSError!) -> Void in
                if (success) {
                    // The object has been saved.
                    var event: PFObject = PFObject(className: "Event")
                    event["type"] = "text"
                    event["storyObject"] = self.story!
                    event["text"] = self.createTextView.text
                    event.saveInBackgroundWithBlock({
                        (success: Bool, error: NSError!) -> Void in
                        if (success) {
                            // The object has been saved.
                            println("Story and event successfully saved")
                            self.storyTitleLabel.text = self.story!["title"] as? String
                            self.userLabel.text = PFUser.currentUser().username
                            var upvotes = self.story!["upvotes"] as? Int
                            var downvotes = self.story!["downvotes"] as? Int
                            self.storyPointsLabel.text = "\(upvotes!-downvotes!)"
                            self.createTitleView.hidden = true
                            self.titleView.hidden = false
                            self.minimizeCreateView()
                            self.createTextView.text = ""
                            self.requestEventsForStory()
                            self.view.endEditing(true)
                        } else {
                            // There was a problem, check error.description
                            println("There was an error saving the event: \(error.description)")
                        }
                    })
                } else {
                    // There was a problem, check error.description
                    println("There was an error saving the story: \(error.description)")
                }
            })
        
        }

    }

    @IBAction func videoSelectorWasTapped(sender: AnyObject) {
        vision.cameraMode = PBJCameraMode.Video
        cameraSendButton.hidden = true
        cameraSendButton.enabled = false
        holdToRecordLabel.hidden = false
        videoLongPressGestureRecognizer.enabled = true
        for view in createViews {
            (view as UIView).hidden = true
            cameraContainer.hidden = false
        }
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
        vision.startPreview()

    }

    
    @IBAction func cameraSelectorWasTapped(sender: AnyObject) {
        vision.cameraMode = PBJCameraMode.Photo
        cameraSendButton.hidden = false
        cameraSendButton.enabled = true
        holdToRecordLabel.hidden = true
        videoLongPressGestureRecognizer.enabled = false
        for view in createViews {
            (view as UIView).hidden = true
            cameraContainer.hidden = false
        }
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

       vision.startPreview()
        
    }


    @IBAction func textSelectorWasTapped(sender: AnyObject) {
        println("Text button was tapped")
        videoLongPressGestureRecognizer.enabled = false
        for view in createViews {
            (view as UIView).hidden = true
            textContainer.hidden = false
        }
    }
    
    func requestEventsForStory() {
        dispatch_async(dispatch_get_main_queue(),{
            var query = PFQuery(className:"Event")
            query.whereKey("storyObject", equalTo:self.story)
            query.orderByDescending("createdAt")
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    // The find succeeded.
                    println("Successfully retrieved \(objects.count) events.")
                    self.events = objects
                    self.storyTableView.reloadData()
                    self.scrollViewDidEndDecelerating(self.storyTableView)
                    // Do something with the found objects
                    if let objects = objects as? [PFObject] {
                        for object in objects {
                            var text = object["text"]
                            println("Object ID: \(object.objectId!), Timestamp: \(object.createdAt!), Text: \(text)")
                        }
                    }
                } else {
                    // Log details of the failure
                    println("Error: \(error) \(error.userInfo!)")
                }
            }
        })
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if storyCreated == true {
            requestEventsForStory()
        }
    }
    
    @IBAction func storyTableViewWasTapped(sender: AnyObject) {
        minimizeCreateView()
        self.view.endEditing(true)
    }
    
    @IBAction func videoLongPressGestureRecognizerWasTapped(sender: AnyObject) {
        if sender.state == UIGestureRecognizerState.Began {
            holdToRecordLabel.hidden = true
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
            vision.endVideoCapture()
        }
    }
    
    func vision(vision: PBJVision!, capturedVideo videoDict: [NSObject : AnyObject]!, error: NSError!) {
        self.videoPath = videoDict[PBJVisionVideoPathKey] as String
        self.saveVideoEvent()
        
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
    
    func saveVideoEvent() {
        var videoFile = PFFile(name: "video.mp4", contentsAtPath: "\(self.videoPath!)")
        
        if (self.story != nil) {
            var event: PFObject = PFObject(className: "Event")
            event["type"] = "video"
            event["storyObject"] = self.story!
            event["video"] = videoFile
            event.saveInBackgroundWithBlock({
                (success: Bool, error: NSError!) -> Void in
                if (success) {
                    // The object has been saved.
                    println("Event successfully saved")
                    self.minimizeCreateView()
                    self.requestEventsForStory()
                    self.view.endEditing(true)
                } else {
                    // There was a problem, check error.description
                    println("There was an error saving the event: \(error.description)")
                }
            })
        } else {
            
            self.story = PFObject(className: "Story")
            self.story!["title"] = self.titleTextField.text
            self.story!["user"] = PFUser.currentUser().username
            self.story!["upvotes"] = 1
            self.story!["downvotes"] = 0
            self.story!.saveInBackgroundWithBlock({
                (success: Bool, error: NSError!) -> Void in
                if (success) {
                    // The object has been saved.
                    var event: PFObject = PFObject(className: "Event")
                    event["type"] = "video"
                    event["storyObject"] = self.story!
                    event["video"] = videoFile
                    event.saveInBackgroundWithBlock({
                        (success: Bool, error: NSError!) -> Void in
                        if (success) {
                            // The object has been saved.
                            println("Story and event successfully saved")
                            self.storyTitleLabel.text = self.story!["title"] as? String
                            self.userLabel.text = PFUser.currentUser().username
                            var upvotes = self.story!["upvotes"] as? Int
                            var downvotes = self.story!["downvotes"] as? Int
                            self.storyPointsLabel.text = "\(upvotes!-downvotes!)"
                            self.createTitleView.hidden = true
                            self.titleView.hidden = false
                            self.minimizeCreateView()
                            self.requestEventsForStory()
                            self.view.endEditing(true)
                        } else {
                            // There was a problem, check error.description
                            println("There was an error saving the event: \(error.description)")
                        }
                    })
                } else {
                    // There was a problem, check error.description
                    println("There was an error saving the story: \(error.description)")
                }
            })
            
        }
    }
    
    func vision(vision: PBJVision!, capturedPhoto photoDict: [NSObject : AnyObject]!, error: NSError!) {
        capturedImage = photoDict[PBJVisionPhotoImageKey] as UIImage
        sendPhoto()
    }

    @IBAction func photoSendButtonWasTapped(sender: AnyObject) {
        vision.capturePhoto()
//        println("\(stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo))")
//        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo){
//            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
//                (sampleBuffer,error) in
//                
//            })
//        }
    }
    
    func sendPhoto() {
        
        var squareImage = squareImageWithImage(capturedImage!)
        var squareImageData = UIImageJPEGRepresentation(squareImage, 1.0)
        var imageFile : PFFile = PFFile(name: "image.png", data: squareImageData)
        imageFile.save()

        
        if (self.story != nil) {
            var event: PFObject = PFObject(className: "Event")
            event["type"] = "photo"
            event["storyObject"] = self.story!
            event["image"] = imageFile
            event.saveInBackgroundWithBlock({
                (success: Bool, error: NSError!) -> Void in
                if (success) {
                    // The object has been saved.
                    println("Event successfully saved")
                    self.minimizeCreateView()
                    self.requestEventsForStory()
                    self.view.endEditing(true)
                } else {
                    // There was a problem, check error.description
                    println("There was an error saving the event: \(error.description)")
                }
            })
        } else {
            
            self.story = PFObject(className: "Story")
            self.story!["title"] = self.titleTextField.text
            self.story!["user"] = PFUser.currentUser().username
            self.story!["upvotes"] = 1
            self.story!["downvotes"] = 0
            self.story!.saveInBackgroundWithBlock({
                (success: Bool, error: NSError!) -> Void in
                if (success) {
                    // The object has been saved.
                    var event: PFObject = PFObject(className: "Event")
                    event["type"] = "photo"
                    event["storyObject"] = self.story!
                    event["image"] = imageFile
                    event.saveInBackgroundWithBlock({
                        (success: Bool, error: NSError!) -> Void in
                        if (success) {
                            // The object has been saved.
                            println("Story and event successfully saved")
                            self.storyTitleLabel.text = self.story!["title"] as? String
                            self.userLabel.text = PFUser.currentUser().username
                            var upvotes = self.story!["upvotes"] as? Int
                            var downvotes = self.story!["downvotes"] as? Int
                            self.storyPointsLabel.text = "\(upvotes!-downvotes!)"
                            self.createTitleView.hidden = true
                            self.titleView.hidden = false
                            self.minimizeCreateView()
                            self.requestEventsForStory()
                            self.view.endEditing(true)
                        } else {
                            // There was a problem, check error.description
                            println("There was an error saving the event: \(error.description)")
                        }
                    })
                } else {
                    // There was a problem, check error.description
                    println("There was an error saving the story: \(error.description)")
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
        if (playingVideoCell != nil && playingVideoCell!.player != nil) {
            if playingVideoCell!.player!.rate == 1.0 {
                playingVideoCell!.player?.pause()
                println("Pausing video")
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
                if cellCompletelyOnScreen(indexPaths![i] as NSIndexPath) {
                    playableCells.addObject(cells[i])
                    println("Cell at index \(i) is fully on screen")
                } else {
                    println("Cell at index \(i) is not fully on screen")
                }
                
            }

        }
        
        if playableCells.lastObject?.player != nil {
            playingVideoCell = playableCells[0] as StoryVideoTableViewCell
            playingVideoCell!.player!.play()
            println("Playing cell")
        }
        
        
    }
    

    
    func cellCompletelyOnScreen(indexPath : NSIndexPath) -> Bool {
        var cellRect : CGRect = storyTableView.rectForRowAtIndexPath(indexPath)
        cellRect = storyTableView.convertRect(cellRect, toView: storyTableView.superview)
        println("Cell Rect: \(cellRect)")
        println("StoryTableview Frame : \(storyTableView.frame)")
        var completelyVisible : Bool = CGRectContainsRect(storyTableView.frame, cellRect)
        return completelyVisible
    }
    
}
