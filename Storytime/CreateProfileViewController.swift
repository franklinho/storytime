//
//  CreateProfileViewController.swift
//  Storytime
//
//  Created by Franklin Ho on 4/7/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

protocol CreateProfileViewControllerDelegate{
    func didCreateProfile()
}

class CreateProfileViewController: UIViewController, PBJVisionDelegate, UITextFieldDelegate {
    var delegate : CreateProfileViewControllerDelegate?
    @IBOutlet weak var submitActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var profilePhotoLabel: UILabel!
    @IBOutlet weak var profilePreviewView: UIView!
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var usernameTakenLabel: UILabel!
    @IBOutlet weak var usernameRequiredLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var tapToCaptureLabel: UILabel!
    var vision : PBJVision = PBJVision.sharedInstance()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var isCapturing = false
    var previewLayerAdded = false
    var profileImage : UIImage?
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        profilePreviewView.layer.cornerRadius = 100
        profilePreviewView.layer.borderColor = UIColor.whiteColor().CGColor
        profilePreviewView.layer.borderWidth = 8
        profilePreviewView.clipsToBounds = true
        
        submitButton.layer.cornerRadius = 10
        submitButton.clipsToBounds = true
        
        closeButton.layer.cornerRadius = 23
        closeButton.layer.borderWidth = 3
        closeButton.layer.borderColor = UIColor.whiteColor().CGColor
        closeButton.clipsToBounds = true
        
        previewLayer = vision.previewLayer
        previewLayer!.frame = profilePreviewView.bounds
        previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        
        vision.delegate = self
        vision.cameraMode = PBJCameraMode.Photo
        vision.cameraOrientation = PBJCameraOrientation.Portrait
        vision.focusMode = PBJFocusMode.ContinuousAutoFocus
        vision.outputFormat = PBJOutputFormat.Square
        vision.cameraDevice = PBJCameraDevice.Front
        
        userNameTextField.delegate = self
        userNameTextField.autocorrectionType = UITextAutocorrectionType.No
        userNameTextField.autocapitalizationType = UITextAutocapitalizationType.None
        
        if PFTwitterUtils.isLinkedWithUser(PFUser.currentUser()) {
            var twitterScreenName = PFTwitterUtils.twitter()!.screenName
            self.userNameTextField.text = twitterScreenName
            var profileImageURL = NSURL(string: "https://api.twitter.com/1.1/users/show.json?screen_name=\(twitterScreenName!)")!
            var request = NSMutableURLRequest(URL: profileImageURL)
            PFTwitterUtils.twitter()!.signRequest(request)
            var data: Void = NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
//                println(NSString(data: data, encoding: NSUTF8StringEncoding))
                if data != nil {
                    var userJSON = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
//                    println("\(userJSON)")
                    var profileImageURLString = userJSON["profile_image_url"] as! String
                    var fullSizeProfileImageURLString = profileImageURLString.substringToIndex(advance(profileImageURLString.startIndex, count(profileImageURLString) - 11))+".png"
                    println("\(fullSizeProfileImageURLString)")
                    if fullSizeProfileImageURLString != "http://abs.twimg.com/sticky/default_profile_images/default_profile_1.png" {
                        self.profileImageView.setImageWithURL(NSURL(string: fullSizeProfileImageURLString))
                        self.profileImage = self.profileImageView.image
                        self.profilePhotoLabel.hidden = true
                        self.profileImageView.alpha = 0
                        self.profileImageView.hidden = false
                        UIView.animateWithDuration(0.3, animations: {
                            self.profileImageView.alpha = 1
                            }, completion: {
                                (value: Bool) in
                        })
                    }
                    
                    
                }
            }
        } else if PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()!) {
            var request : FBRequest = FBRequest.requestForMe()
            request.startWithCompletionHandler{
                (connection: FBRequestConnection!, result:AnyObject!, error: NSError!) in
                if error == nil {
                    println("Successfully grabbed FB user data")
                    var userData : NSDictionary = result as! NSDictionary
                    var username = userData["name"] as! String
//                    println("\(userData)")
                    println("\(username)")
                    self.userNameTextField.text = (userData["first_name"] as! String) + (userData["last_name"] as! String)
                    var userID : String = userData["id"] as! String
                    var profileImageURL = "https://graph.facebook.com/\(userID)/picture?width=300&height=300"
                    println("\(profileImageURL)")
                    self.profileImageView.setImageWithURL(NSURL(string: profileImageURL))
                    self.profileImage = self.profileImageView.image
                    self.profilePhotoLabel.hidden = true
                    self.profileImageView.alpha = 0
                    self.profileImageView.hidden = false
                    UIView.animateWithDuration(0.3, animations: {
                        self.profileImageView.alpha = 1
                        }, completion: {
                            (value: Bool) in
                    })

                } else {
                    println("There was an error getting fb data. \(error.description)")
                }
            }
 
        }
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

    @IBAction func profilePhotoViewWasTapped(sender: AnyObject) {
        vision.stopPreview()
        println("Profile Image View State : \(profileImageView.hidden)")
        println("Is capturing state: \(isCapturing)")
        if isCapturing == false {
            profileImageView.hidden = true
            
            if previewLayer?.superlayer != profilePreviewView.layer {
                profilePreviewView.layer.insertSublayer(previewLayer, atIndex: UInt32(profilePreviewView.layer.sublayers.count))
            } else {
                previewLayer?.removeFromSuperlayer()
                profilePreviewView.layer.insertSublayer(previewLayer, atIndex: UInt32(profilePreviewView.layer.sublayers.count))
            }
            
            
            
            
            vision.startPreview()
            previewLayerAdded = true


            self.profilePreviewView.bringSubviewToFront(tapToCaptureLabel)
            self.profilePhotoLabel.hidden = true
            self.tapToCaptureLabel.hidden = false
            
            isCapturing = true
            println("Profile Preview View sublayers: \(profilePreviewView.layer.sublayers)")
        } else {
            println("Capturing Photo")
            self.vision.capturePhoto()
            tapToCaptureLabel.hidden = true
            self.profilePhotoLabel.hidden = false
            profileImageView.hidden = false
            isCapturing = false
            
        }
    }
    


    func vision(vision: PBJVision, capturedPhoto photoDict: [NSObject : AnyObject]?, error: NSError?) {
        var capturedImage = photoDict![PBJVisionPhotoImageKey] as? UIImage
        var squareImage = squareImageWithImage(capturedImage!)
        profileImage = squareImage
        profileImageView.image = squareImage
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
    
    @IBAction func viewWasTapped(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.submitButtonWasTapped(self)
        return true
    }
    

    @IBAction func closeButtonWasTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func submitButtonWasTapped(sender: AnyObject) {
        submitButton.hidden = true
        submitActivityIndicator.hidden = false
        self.view.endEditing(true)
        usernameRequiredLabel.hidden = true
        usernameTakenLabel.hidden = true
        if userNameTextField.text == "" {
            usernameRequiredLabel.hidden = false
            submitActivityIndicator.hidden = true
            submitButton.hidden = false
        } else {
            var query = PFUser.query()
            query!.whereKey("violation", notEqualTo: true)
            query!.whereKey("canonicalProfileName", equalTo:userNameTextField.text.lowercaseString)
            query!.findObjectsInBackgroundWithBlock {
                (objects, error) -> Void in
                if error == nil {
                    // The find succeeded.
                    println("Successfully retrieved \(objects!.count) usernames.")
                    // Do something with the found objects
                    if objects!.count > 0 {
                        self.usernameTakenLabel.hidden = false
                        self.submitActivityIndicator.hidden = true
                        self.submitButton.hidden = false
                    } else {
//                        var user = PFUser.currentUser()!
                        PFUser.currentUser()!["profileName"] = self.userNameTextField.text
                        PFUser.currentUser()!["canonicalProfileName"] = self.userNameTextField.text.lowercaseString
                        
                        if self.profileImageView.image != nil {
                            var profileImageData = UIImageJPEGRepresentation(self.profileImageView.image, 1.0)
                            var imageFile : PFFile = PFFile(name: "image.png", data: profileImageData)
                            PFUser.currentUser()!["profileImage"] = imageFile
                        }
                        
                        PFUser.currentUser()!.saveInBackgroundWithBlock {
                            (success, error) -> Void in
                            if (success) {
                                // The object has been saved.
                                self.delegate?.didCreateProfile()
                                self.dismissViewControllerAnimated(true, completion: nil)
                                
                            } else {
                                // There was a problem, check error.description
                            }
                        }
                    }
                } else {
                    // Log details of the failure
                    println("Error: \(error) \(error!.userInfo!)")
                    self.submitActivityIndicator.hidden = true
                    self.submitButton.hidden = false
                }
            }
        }
    }
    

    
    
}
