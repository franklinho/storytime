//
//  ProfileImageViewController.swift
//  Storytime
//
//  Created by Franklin Ho on 5/7/15.
//  Copyright (c) 2015 Franklin Ho. All rights reserved.
//

import UIKit

protocol ProfileImageViewControllerDelegate{
    func profileImageWasChanged(profileImage: UIImage, profileImageFile : PFFile)
}


class ProfileImageViewController: UIViewController, PBJVisionDelegate {
    var profileImage : UIImage?
    var user : PFUser?
    var delegate : ProfileImageViewControllerDelegate?
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tapToCaptureLabel: UILabel!
    var previewLayer : AVCaptureVideoPreviewLayer?
    var vision : PBJVision = PBJVision.sharedInstance()
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var changeProfilePhotoButton: UIButton!
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var isCapturing = false
    var previewLayerAdded = false

    @IBOutlet weak var profileImageViewHeightConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        changeProfilePhotoButton.layer.cornerRadius = 10
        changeProfilePhotoButton.clipsToBounds = true

        // Do any additional setup after loading the view.
        profileImageViewHeightConstraint.constant = self.screenSize.width
        
        self.view.layoutIfNeeded()
        
        previewLayer = vision.previewLayer
        previewLayer!.frame = previewView.bounds
        previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        vision.delegate = self
        vision.cameraMode = PBJCameraMode.Photo
        vision.cameraOrientation = PBJCameraOrientation.Portrait
        vision.focusMode = PBJFocusMode.ContinuousAutoFocus
        vision.outputFormat = PBJOutputFormat.Square
        vision.cameraDevice = PBJCameraDevice.Front
        
        self.profileImageView.image = self.profileImage
        
        if PFUser.currentUser() != nil {
            if PFUser.currentUser()!.objectId == user?.objectId {
                changeProfilePhotoButton.hidden = false
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

    @IBAction func closeButtonWasTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    @IBAction func previewViewWasTapped(sender: AnyObject) {
        self.vision.capturePhoto()
        
    }
    
    func vision(vision: PBJVision, capturedPhoto photoDict: [NSObject : AnyObject]?, error: NSError?) {
        if error == nil {
            var capturedImage = photoDict![PBJVisionPhotoImageKey] as? UIImage
            var squareImage = squareImageWithImage(capturedImage!)
            profileImage = squareImage
            self.profileImageView.image = squareImage
            

            var profileImageData = UIImageJPEGRepresentation(squareImage, 1.0)
            var imageFile : PFFile = PFFile(name: "image.png", data: profileImageData)
            self.delegate?.profileImageWasChanged(squareImage, profileImageFile: imageFile)
            PFUser.currentUser()!["profileImage"] = imageFile
            PFUser.currentUser()!.saveInBackground()
            
        }
        isCapturing = false
        changeProfilePhotoButton.setTitle("Change Profile Photo", forState: UIControlState.Normal)
        changeProfilePhotoButton.backgroundColor = UIColor.darkGrayColor()
        self.profileImageView.hidden = false
        UIView.animateWithDuration(0.3, animations: {
            self.profileImageView.alpha = 1
            
            }, completion: {
                (value: Bool) in
                
                
        })
        vision.stopPreview()
    }
    
    @IBAction func changeProfileButtonWasTapped(sender: AnyObject) {
        if isCapturing == false {
            changeProfilePhotoButton.setTitle("Cancel", forState: UIControlState.Normal)
            changeProfilePhotoButton.backgroundColor = UIColor.redColor()
            
            profileImageView.alpha = 1
            UIView.animateWithDuration(0.3, animations: {
                self.profileImageView.alpha = 0
                
                }, completion: {
                    (value: Bool) in
                    self.profileImageView.hidden = true

            })
            
            if previewLayer?.superlayer != previewView.layer {
                previewView.layer.insertSublayer(previewLayer, atIndex: UInt32(previewView.layer.sublayers.count))
            }
            
            
            
            
            vision.startPreview()
            previewLayerAdded = true
            
            
            self.previewView.bringSubviewToFront(tapToCaptureLabel)
            self.tapToCaptureLabel.hidden = false
            
            isCapturing = true
            self.vision.startPreview()
            
        
        
        } else {
            isCapturing = false
            changeProfilePhotoButton.setTitle("Change Profile Photo", forState: UIControlState.Normal)
            changeProfilePhotoButton.backgroundColor = UIColor.darkGrayColor()
            self.profileImageView.hidden = false
            UIView.animateWithDuration(0.3, animations: {
                self.profileImageView.alpha = 1
                
                }, completion: {
                    (value: Bool) in
                    
                    
            })
            vision.stopPreview()
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
}

