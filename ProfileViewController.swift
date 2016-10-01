//
//  ProfileViewController.swift
//  Instagram
//
//  Created by Tyler Italiano on 6/19/16.
//  Copyright © 2016 Paul Lefebvre. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import Kingfisher

class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var editProfileButton: UIButton!
    @IBOutlet weak var postsCounterLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCounterLabel: UILabel!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileDescriptionLabel: UITextView!
    @IBOutlet weak var profileCollectionView: UICollectionView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    
    var profileURLString: String?
    
    let rootRefDB = FIRDatabase.database().reference()
    let rootRefStorage = FIRStorage.storage().reference()
    
    var orientation: UIImageOrientation = .Up //1
    var imagePicker: UIImagePickerController!
    
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    var otherProfile: Bool?
    var otherUser: String?
    
    var following: Bool?
    
    let user = FIRAuth.auth()?.currentUser?.uid
    let userNoID = FIRAuth.auth()?.currentUser
    var currentUsername: String?
    var otherUserID: String?
    var otherUserDescription: String?
    
    var newArray = [NSURL?]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
        profilePicture.clipsToBounds = true
        
        screenSize = UIScreen.mainScreen().bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        navigationItem.setRightBarButtonItems(nil, animated: false)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(ProfileViewController.imageTapped(_:)))
        profilePicture.userInteractionEnabled = true
        profilePicture.addGestureRecognizer(tapGestureRecognizer)
        
        if otherProfile == true {

            rootRefDB.observeSingleEventOfType(.Value) { (snap: FIRDataSnapshot) in
                let totalSnap = (snap.value as? NSDictionary)!
                if let users = totalSnap["users"] as? NSDictionary {
                    for (key, value) in (users.valueForKey(self.user!))! as! NSDictionary {
                        if key as! String == "following" {
                            for (_, value2) in value as! NSDictionary {
                                for (key2, _) in value2 as! NSDictionary {
                                    if key2 as! String == "\(self.otherUser!)" { // Check to see if you are following this user
                                        self.following = true
                                        
                                        let cornerRadius : CGFloat = 3.0
                                        
                                        self.editProfileButton.backgroundColor = UIColor(red:0.44, green:0.75, blue:0.31, alpha:1.00)
                                        self.editProfileButton.setTitle("FOLLOWING", forState: UIControlState.Normal)
                                        self.editProfileButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                                        self.editProfileButton.layer.cornerRadius = cornerRadius
                                        self.editProfileButton.layer.borderWidth = 0.8
                                        self.editProfileButton.layer.borderColor = UIColor.clearColor().CGColor
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // modifying the "Follow" button when viewing another user's profile
        if otherProfile == true {
            if following == true {
                let cornerRadius : CGFloat = 3.0
                
                editProfileButton.backgroundColor = UIColor(red:0.44, green:0.75, blue:0.31, alpha:1.00)
                editProfileButton.setTitle("FOLLOWING", forState: UIControlState.Normal)
                editProfileButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                editProfileButton.layer.cornerRadius = cornerRadius
                
            } else {
                
                // let borderAlpha : CGFloat = 0.7
                let cornerRadius : CGFloat = 3.0
                
                editProfileButton.backgroundColor = UIColor.clearColor()
                editProfileButton.setTitle("+ FOLLOW", forState: UIControlState.Normal)
                editProfileButton.setTitleColor(UIColor(red:0.22, green:0.59, blue:0.94, alpha:1.00), forState: UIControlState.Normal)
                editProfileButton.layer.borderWidth = 0.8
                editProfileButton.layer.borderColor = UIColor(red:0.22, green:0.59, blue:0.94, alpha: 1.00).CGColor
                editProfileButton.layer.cornerRadius = cornerRadius
            }
        }
        
        let layout: UICollectionViewFlowLayout = profileCollectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: screenWidth/3, height: screenWidth/3)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        // Modifying the ui elements of a page based on whether it is your own or someone elses
        
        if otherProfile == true {
            
            editProfileButton.hidden = false
            profileDescriptionLabel.editable = false
            profileDescriptionLabel.selectable = false
            profileDescriptionLabel.text = otherUserDescription
            // profileNameLabel.editable
        } else {
            
            profileDescriptionLabel.editable = true
            profileDescriptionLabel.editable = true
        }
        
        // If it is your own profile you are viewing
        if otherProfile != true {
            
            rootRefDB.observeSingleEventOfType(.Value) { (snap: FIRDataSnapshot) in
                let totalSnap = (snap.value as? NSDictionary)!
                if let users = totalSnap["users"] as? NSDictionary {
                    
                    // Get the username for the current user.
                    self.currentUsername = users.valueForKey("\(self.user!)")!.valueForKey("username")! as? String
                    
                    // set title on page to be your own username
                    self.navigationItem.title = "\(self.currentUsername!)"
                    
                    // Profile picture for yourself
                    let urlString = users.valueForKey("\(self.user!)")!.valueForKey("profilePicture")! as? String
                    self.profilePicture.kf_setImageWithURL(NSURL(string: "\(urlString!)")!, placeholderImage: nil)
                    self.profileURLString = users.valueForKey("\(self.user!)")!.valueForKey("profilePicture")! as? String
                    
                    self.profileNameLabel.text = users.valueForKey("\(self.user!)")!.valueForKey("realName")! as? String
                    
                    let selfDescription = users.valueForKey("\(self.user!)")!.valueForKey("profileDescription")! as? String
                    self.profileDescriptionLabel.text = selfDescription
                    
                }
            }
            
            // ?? Loading newArray with all of YOUR OWN images
            rootRefDB.observeSingleEventOfType(.Value) { (snap: FIRDataSnapshot) in
                self.newArray.removeAll()
                let snapshotAll = (snap.value as? NSDictionary)!
                if let posts = snapshotAll["posts"] as? NSDictionary {
                    
                    for (_, value) in posts {
                        let valueDict = value as! NSDictionary
                        if valueDict.valueForKey("username") as! String == "\(self.currentUsername!)" {
                            let finalPost = valueDict.valueForKey("imageString")! as! String
                            let newURL = NSURL(string: finalPost)
                            self.newArray.append(newURL!)
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.postsCounterLabel.text = "\(self.newArray.count)"
                        self.profileCollectionView.reloadData()
                    })
                }
            }
            
        // Else if it is not your profile.
        } else {
            
            rootRefDB.observeSingleEventOfType(.Value) { (snap: FIRDataSnapshot) in
                let totalSnap = (snap.value as? NSDictionary)!
                if let users = totalSnap["users"] as? NSDictionary {
                    
                    for (key, value) in users {
                        let valueDict = value as! NSDictionary
                        if valueDict.valueForKey("username") as! String == "\(self.otherUser!)" {
                            self.otherUserID = key as? String
                            self.currentUsername = users.valueForKey("\(key)")!.valueForKey("username")! as? String
                            self.navigationItem.title = "\(self.currentUsername!)"
                            self.otherUserDescription = users.valueForKey("\(key)")!.valueForKey("profileDescription")! as? String
                            self.profileDescriptionLabel.text = self.otherUserDescription
                            
                            // Profile Picture for someone else.
                            let urlString = users.valueForKey("\(key)")!.valueForKey("username")! as? String
                            self.profilePicture.kf_setImageWithURL(NSURL(string: "\(urlString!)")!, placeholderImage: nil)
                            self.profileNameLabel.text = users.valueForKey("\(key)")!.valueForKey("realName")! as? String
                        }
                        
                    }
                }
            }
            
            // Loading newArray with the urls of the OTHER USERS images
            rootRefDB.observeSingleEventOfType(.Value) { (snap: FIRDataSnapshot) in
                self.newArray.removeAll()
                let snapshotAll = (snap.value as? NSDictionary)!
                if let posts = snapshotAll["posts"] as? NSDictionary {
                    
                    for (_, value) in posts {
                        let valueDict = value as! NSDictionary
                        if valueDict.valueForKey("username") as! String == "\(self.currentUsername!)" {
                            let finalPost = valueDict.valueForKey("imageString")! as! String
                            let newURL = NSURL(string: finalPost)
                            //print("in it!")
                            self.newArray.append(newURL!)
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.postsCounterLabel.text = "\(self.newArray.count)"
                        self.profileCollectionView.reloadData()
                    })
                }
            }
        }
        
    }
    
    //set up the profile to function/look different depending on if it is your own profile or someone elses
    override func viewWillAppear(animated: Bool) {
        if otherProfile == true {
            if following == true {
                editProfileButton.hidden = false
                
                let cornerRadius : CGFloat = 3.0
                
                editProfileButton.backgroundColor = UIColor(red:0.44, green:0.75, blue:0.31, alpha:1.00)
                editProfileButton.setTitle("FOLLOWING", forState: UIControlState.Normal)
                editProfileButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                editProfileButton.layer.cornerRadius = cornerRadius
                
            } else {
                editProfileButton.hidden = false
                
                //                let borderAlpha : CGFloat = 0.7
                let cornerRadius : CGFloat = 3.0
                
                editProfileButton.backgroundColor = UIColor.clearColor()
                editProfileButton.setTitle("+ FOLLOW", forState: UIControlState.Normal)
                editProfileButton.setTitleColor(UIColor(red:0.22, green:0.59, blue:0.94, alpha:1.00), forState: UIControlState.Normal)
                editProfileButton.layer.borderWidth = 0.8
                editProfileButton.layer.borderColor = UIColor(red:0.22, green:0.59, blue:0.94, alpha: 1.00).CGColor
                
                editProfileButton.layer.cornerRadius = cornerRadius
                
            }
        } else {
            editProfileButton.hidden = true
        }
        profileCollectionView.reloadData()
        
    }
    
    
    func imageTapped(img: AnyObject) {
        
        if otherProfile == false || otherProfile == nil {
            self.presentCamera()
        }
    }
    
    // Shows camera
    
    func presentCamera() {
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        imagePicker.allowsEditing = true
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // for the image picker that controls photo taking
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        profilePicture.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        //        profilePicture.clipsToBounds = true
        orientation = (profilePicture.image?.imageOrientation)!
        
        
        let imageData = profilePicture.image!.lowestQualityJPEGNSData
        //let imageURL: NSURL = (info[UIImagePickerControllerReferenceURL] as? NSURL)!
        
        //let photoObject = Photo(image: imageURL) //1
        
        let photosRef = rootRefStorage.child("\(user)_photos")
        let database = rootRefDB.child("users/") //2
        
        
        let storageRef = photosRef.child("\(NSUUID().UUIDString).png")
        
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpg"
        storageRef.putData(imageData, metadata: metadata).observeStatus(.Success) { (snapshot) in
            
            database.child("\(self.user!)/profilePicture").setValue(snapshot.metadata?.downloadURL()?.absoluteString)
            
            
        }
        
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if newArray.count == 0 {
            return 0
        } else {
            return newArray.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProfilePhotoCell", forIndexPath: indexPath) as! ProfileGridCells
        
        cell.backgroundColor = UIColor.whiteColor()
        collectionView.backgroundColor = UIColor.whiteColor()
        
        if let url = self.newArray[indexPath.row] {
            cell.profileGridImageView.kf_setImageWithURL(NSURL(string: "\(url)")!, placeholderImage: nil)
        }
        
        cell.frame.size.width = screenWidth / 3
        
        
        return cell
        
    }
    
    @IBAction func onEditProfileButtonPressed(sender: AnyObject) {
        
        if otherProfile == true {
            if following == true {
                
                //obtain this users uid and remove them from your array of followed accounts
                rootRefDB.observeSingleEventOfType(.Value) { (snap: FIRDataSnapshot) in
                    let totalSnap = (snap.value as? NSDictionary)!
                    if let users = totalSnap["users"] as? NSDictionary {
                        for (key, value) in (users.valueForKey(self.user!))!.valueForKey("following") as! NSDictionary {
                            let newDict = value as? NSDictionary
                            for (key2, _) in newDict! {
                                if key2 as? String == self.otherUser! {
                                    let database = self.rootRefDB.child("users/\(self.user!)/following/\(key)")
                                    database.removeValue()
                                }
                            }
                        }
                        
                    }
                }
                
                print("delete")
                
                editProfileButton.backgroundColor = UIColor.clearColor()
                editProfileButton.setTitle("+ FOLLOW", forState: UIControlState.Normal)
                editProfileButton.setTitleColor(UIColor(red:0.22, green:0.59, blue:0.94, alpha:1.00), forState: UIControlState.Normal)
                editProfileButton.layer.borderWidth = 0.8
                editProfileButton.layer.borderColor = UIColor(red:0.22, green:0.59, blue:0.94, alpha: 1.00).CGColor
                
                
                following = false
                
            } else {
                let thisUser: NSString = otherUser!
                let thisUserID: NSString = otherUserID!
                //obtain this users uid and add them to your array of followed account
                print("add")
                let database = rootRefDB.child("users/\(user!)/following")
                database.childByAutoId().setValue(["\(thisUser)" : thisUserID])
                //                let userDatabase = rootRefDB.child("users/\(user)")
                //                database.setValue(["followCount": ])
                
                editProfileButton.backgroundColor = UIColor(red:0.44, green:0.75, blue:0.31, alpha:1.00)
                editProfileButton.setTitle("FOLLOWING", forState: UIControlState.Normal)
                editProfileButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                editProfileButton.layer.borderWidth = 0.8
                editProfileButton.layer.borderColor = UIColor.clearColor().CGColor
                
                
                following = true
                
            }
        }
        
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToIndividualPost" {
            let dvc = segue.destinationViewController as? IndividualPostViewController
            let indexPath = self.profileCollectionView.indexPathsForSelectedItems()
            let url = self.newArray[(indexPath?.first?.row)!]
            dvc!.postURL = url
            dvc!.profilePictureString = profileURLString!
            
        } else {
            
            if otherProfile == true {
                otherProfile = false
                
            }
        }
    }
    
    
    
}
