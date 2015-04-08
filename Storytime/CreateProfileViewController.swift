//
//  CreateProfileViewController.swift
//  Storytime
//
//  Created by Franklin Ho on 4/7/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

class CreateProfileViewController: UIViewController, PBJVisionDelegate, UITextFieldDelegate {

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
        
        profilePreviewView.layer.cornerRadius = 125
        profilePreviewView.layer.borderColor = UIColor.whiteColor().CGColor
        profilePreviewView.layer.borderWidth = 10
        profilePreviewView.clipsToBounds = true
        
        submitButton.layer.cornerRadius = 10
        submitButton.clipsToBounds = true

        
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
        println("Profile Image View State : \(profileImageView.hidden)")
        println("Is capturing state: \(isCapturing)")
        if isCapturing == false {
            profileImageView.hidden = true
            

            profilePreviewView.layer.addSublayer(previewLayer)
            vision.startPreview()
            previewLayerAdded = true

            
            self.profilePreviewView.bringSubviewToFront(tapToCaptureLabel)
            self.profilePhotoLabel.hidden = true
            self.tapToCaptureLabel.hidden = false
            
            isCapturing = true
        } else {
            println("Capturing Photo")
            self.vision.capturePhoto()
            tapToCaptureLabel.hidden = true
            self.profilePhotoLabel.hidden = false
            profileImageView.hidden = false
            isCapturing = false
            
        }
    }


    func vision(vision: PBJVision!, capturedPhoto photoDict: [NSObject : AnyObject]!, error: NSError!) {
        var capturedImage = photoDict[PBJVisionPhotoImageKey] as UIImage
        var squareImage = squareImageWithImage(capturedImage)
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
        return true
    }
    

    @IBAction func submitButtonWasTapped(sender: AnyObject) {
        self.view.endEditing(true)
        usernameRequiredLabel.hidden = true
        usernameTakenLabel.hidden = true
        if userNameTextField.text == "" {
            usernameRequiredLabel.hidden = false
        } else {
            var query = PFQuery(className:"User")
            query.whereKey("profileName", equalTo:userNameTextField.text)
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    // The find succeeded.
                    println("Successfully retrieved \(objects.count) usernames.")
                    // Do something with the found objects
                    if objects.count > 0 {
                        self.usernameTakenLabel.hidden = false
                    } else {
                        var user = PFUser.currentUser()
                        user["profileName"] = self.userNameTextField.text
                        
                        if self.profileImage != nil {
                            var profileImageData = UIImageJPEGRepresentation(self.profileImage, 1.0)
                            var imageFile : PFFile = PFFile(name: "image.png", data: profileImageData)
                            user["profileImage"] = imageFile
                        }
                        
                        user.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError!) -> Void in
                            if (success) {
                                // The object has been saved.
                                self.dismissViewControllerAnimated(true, completion: nil)
                            } else {
                                // There was a problem, check error.description
                            }
                        }
                    }
                } else {
                    // Log details of the failure
                    println("Error: \(error) \(error.userInfo!)")
                }
            }
        }
    }
    
    
}