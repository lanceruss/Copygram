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
    
    var orientation: UIImageOrientation = .up //1
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
    
    var newArray = [URL?]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
        profilePicture.clipsToBounds = true
        
        screenSize = UIScreen.main.bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        navigationItem.setRightBarButtonItems(nil, animated: false)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(ProfileViewController.imageTapped(_:)))
        profilePicture.isUserInteractionEnabled = true
        profilePicture.addGestureRecognizer(tapGestureRecognizer)
        
        if otherProfile == true {

            rootRefDB.observeSingleEvent(of: .value) { (snap: FIRDataSnapshot) in
                let totalSnap = (snap.value as? NSDictionary)!
                if let users = totalSnap["users"] as? NSDictionary {
                    for (key, value) in (users.value(forKey: self.user!))! as! NSDictionary {
                        if key as! String == "following" {
                            for (_, value2) in value as! NSDictionary {
                                for (key2, _) in value2 as! NSDictionary {
                                    if key2 as! String == "\(self.otherUser!)" { // Check to see if you are following this user
                                        self.following = true
                                        
                                        let cornerRadius : CGFloat = 3.0
                                        
                                        self.editProfileButton.backgroundColor = UIColor(red:0.44, green:0.75, blue:0.31, alpha:1.00)
                                        self.editProfileButton.setTitle("FOLLOWING", for: UIControlState())
                                        self.editProfileButton.setTitleColor(UIColor.white, for: UIControlState())
                                        self.editProfileButton.layer.cornerRadius = cornerRadius
                                        self.editProfileButton.layer.borderWidth = 0.8
                                        self.editProfileButton.layer.borderColor = UIColor.clear.cgColor
                                        
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
                editProfileButton.setTitle("FOLLOWING", for: UIControlState())
                editProfileButton.setTitleColor(UIColor.white, for: UIControlState())
                editProfileButton.layer.cornerRadius = cornerRadius
                
            } else {
                
                // let borderAlpha : CGFloat = 0.7
                let cornerRadius : CGFloat = 3.0
                
                editProfileButton.backgroundColor = UIColor.clear
                editProfileButton.setTitle("+ FOLLOW", for: UIControlState())
                editProfileButton.setTitleColor(UIColor(red:0.22, green:0.59, blue:0.94, alpha:1.00), for: UIControlState())
                editProfileButton.layer.borderWidth = 0.8
                editProfileButton.layer.borderColor = UIColor(red:0.22, green:0.59, blue:0.94, alpha: 1.00).cgColor
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
            
            editProfileButton.isHidden = false
            profileDescriptionLabel.isEditable = false
            profileDescriptionLabel.isSelectable = false
            profileDescriptionLabel.text = otherUserDescription
            // profileNameLabel.editable
        } else {
            
            profileDescriptionLabel.isEditable = true
            profileDescriptionLabel.isEditable = true
        }
        
        // If it is your own profile you are viewing
        if otherProfile != true {
            
            rootRefDB.observeSingleEvent(of: .value) { (snap: FIRDataSnapshot) in
                let totalSnap = (snap.value as? NSDictionary)!
                if let users = totalSnap["users"] as? NSDictionary {
                    
                    // Get the username for the current user.
                    self.currentUsername = (users.value(forKey: "\(self.user!)")! as AnyObject).value(forKey: "username")! as? String
                    
                    // set title on page to be your own username
                    self.navigationItem.title = "\(self.currentUsername!)"
                    
                    // Profile picture for yourself
                    let urlString = (users.value(forKey: "\(self.user!)")! as AnyObject).value(forKey: "profilePicture")! as? String
                    self.profilePicture.kf_setImageWithURL(URL(string: "\(urlString!)")!, placeholderImage: nil)
                    self.profileURLString = (users.value(forKey: "\(self.user!)")! as AnyObject).value(forKey: "profilePicture")! as? String
                    
                    self.profileNameLabel.text = (users.value(forKey: "\(self.user!)")! as AnyObject).value(forKey: "realName")! as? String
                    
                    let selfDescription = (users.value(forKey: "\(self.user!)")! as AnyObject).value(forKey: "profileDescription")! as? String
                    self.profileDescriptionLabel.text = selfDescription
                    
                }
            }
            
            // ?? Loading newArray with all of YOUR OWN images
            rootRefDB.observeSingleEvent(of: .value) { (snap: FIRDataSnapshot) in
                self.newArray.removeAll()
                let snapshotAll = (snap.value as? NSDictionary)!
                if let posts = snapshotAll["posts"] as? NSDictionary {
                    
                    for (_, value) in posts {
                        let valueDict = value as! NSDictionary
                        if valueDict.value(forKey: "username") as! String == "\(self.currentUsername!)" {
                            let finalPost = valueDict.value(forKey: "imageString")! as! String
                            let newURL = URL(string: finalPost)
                            self.newArray.append(newURL!)
                        }
                    }
                    DispatchQueue.main.async(execute: {
                        self.postsCounterLabel.text = "\(self.newArray.count)"
                        self.profileCollectionView.reloadData()
                    })
                }
            }
            
        // Else if it is not your profile.
        } else {
            
            rootRefDB.observeSingleEvent(of: .value) { (snap: FIRDataSnapshot) in
                let totalSnap = (snap.value as? NSDictionary)!
                if let users = totalSnap["users"] as? NSDictionary {
                    
                    for (key, value) in users {
                        let valueDict = value as! NSDictionary
                        if valueDict.value(forKey: "username") as! String == "\(self.otherUser!)" {
                            self.otherUserID = key as? String
                            self.currentUsername = (users.value(forKey: "\(key)")! as AnyObject).value(forKey: "username")! as? String
                            self.navigationItem.title = "\(self.currentUsername!)"
                            self.otherUserDescription = (users.value(forKey: "\(key)")! as AnyObject).value(forKey: "profileDescription")! as? String
                            self.profileDescriptionLabel.text = self.otherUserDescription
                            
                            // Profile Picture for someone else.
                            let urlString = (users.value(forKey: "\(key)")! as AnyObject).value(forKey: "username")! as? String
                            self.profilePicture.kf_setImageWithURL(URL(string: "\(urlString!)")!, placeholderImage: nil)
                            self.profileNameLabel.text = (users.value(forKey: "\(key)")! as AnyObject).value(forKey: "realName")! as? String
                        }
                        
                    }
                }
            }
            
            // Loading newArray with the urls of the OTHER USERS images
            rootRefDB.observeSingleEvent(of: .value) { (snap: FIRDataSnapshot) in
                self.newArray.removeAll()
                let snapshotAll = (snap.value as? NSDictionary)!
                if let posts = snapshotAll["posts"] as? NSDictionary {
                    
                    for (_, value) in posts {
                        let valueDict = value as! NSDictionary
                        if valueDict.value(forKey: "username") as! String == "\(self.currentUsername!)" {
                            let finalPost = valueDict.value(forKey: "imageString")! as! String
                            let newURL = URL(string: finalPost)
                            //print("in it!")
                            self.newArray.append(newURL!)
                        }
                    }
                    DispatchQueue.main.async(execute: {
                        self.postsCounterLabel.text = "\(self.newArray.count)"
                        self.profileCollectionView.reloadData()
                    })
                }
            }
        }
        
    }
    
    //set up the profile to function/look different depending on if it is your own profile or someone elses
    override func viewWillAppear(_ animated: Bool) {
        if otherProfile == true {
            if following == true {
                editProfileButton.isHidden = false
                
                let cornerRadius : CGFloat = 3.0
                
                editProfileButton.backgroundColor = UIColor(red:0.44, green:0.75, blue:0.31, alpha:1.00)
                editProfileButton.setTitle("FOLLOWING", for: UIControlState())
                editProfileButton.setTitleColor(UIColor.white, for: UIControlState())
                editProfileButton.layer.cornerRadius = cornerRadius
                
            } else {
                editProfileButton.isHidden = false
                
                //                let borderAlpha : CGFloat = 0.7
                let cornerRadius : CGFloat = 3.0
                
                editProfileButton.backgroundColor = UIColor.clear
                editProfileButton.setTitle("+ FOLLOW", for: UIControlState())
                editProfileButton.setTitleColor(UIColor(red:0.22, green:0.59, blue:0.94, alpha:1.00), for: UIControlState())
                editProfileButton.layer.borderWidth = 0.8
                editProfileButton.layer.borderColor = UIColor(red:0.22, green:0.59, blue:0.94, alpha: 1.00).cgColor
                
                editProfileButton.layer.cornerRadius = cornerRadius
                
            }
        } else {
            editProfileButton.isHidden = true
        }
        profileCollectionView.reloadData()
        
    }
    
    
    func imageTapped(_ img: AnyObject) {
        
        if otherProfile == false || otherProfile == nil {
            self.presentCamera()
        }
    }
    
    // Shows camera
    
    func presentCamera() {
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    // for the image picker that controls photo taking
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        imagePicker.dismiss(animated: true, completion: nil)
        profilePicture.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        //        profilePicture.clipsToBounds = true
        orientation = (profilePicture.image?.imageOrientation)!
        
        
        let imageData = profilePicture.image!.lowestQualityJPEGNSData
        //let imageURL: NSURL = (info[UIImagePickerControllerReferenceURL] as? NSURL)!
        
        //let photoObject = Photo(image: imageURL) //1
        
        let photosRef = rootRefStorage.child("\(user)_photos")
        let database = rootRefDB.child("users/") //2
        
        
        let storageRef = photosRef.child("\(UUID().uuidString).png")
        
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpg"
        storageRef.put(imageData as Data, metadata: metadata).observe(.success) { (snapshot) in
            
            database.child("\(self.user!)/profilePicture").setValue(snapshot.metadata?.downloadURL()?.absoluteString)
            
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if newArray.count == 0 {
            return 0
        } else {
            return newArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfilePhotoCell", for: indexPath) as! ProfileGridCells
        
        cell.backgroundColor = UIColor.white
        collectionView.backgroundColor = UIColor.white
        
        if let url = self.newArray[(indexPath as NSIndexPath).row] {
            cell.profileGridImageView.kf_setImageWithURL(URL(string: "\(url)")!, placeholderImage: nil)
        }
        
        cell.frame.size.width = screenWidth / 3
        
        
        return cell
        
    }
    
    @IBAction func onEditProfileButtonPressed(_ sender: AnyObject) {
        
        if otherProfile == true {
            if following == true {
                
                //obtain this users uid and remove them from your array of followed accounts
                rootRefDB.observeSingleEvent(of: .value) { (snap: FIRDataSnapshot) in
                    let totalSnap = (snap.value as? NSDictionary)!
                    if let users = totalSnap["users"] as? NSDictionary {
                        for (key, value) in ((users.value(forKey: self.user!))! as AnyObject).value(forKey: "following") as! NSDictionary {
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
                
                editProfileButton.backgroundColor = UIColor.clear
                editProfileButton.setTitle("+ FOLLOW", for: UIControlState())
                editProfileButton.setTitleColor(UIColor(red:0.22, green:0.59, blue:0.94, alpha:1.00), for: UIControlState())
                editProfileButton.layer.borderWidth = 0.8
                editProfileButton.layer.borderColor = UIColor(red:0.22, green:0.59, blue:0.94, alpha: 1.00).cgColor
                
                
                following = false
                
            } else {
                let thisUser: NSString = otherUser! as NSString
                let thisUserID: NSString = otherUserID! as NSString
                //obtain this users uid and add them to your array of followed account
                print("add")
                let database = rootRefDB.child("users/\(user!)/following")
                database.childByAutoId().setValue(["\(thisUser)" : thisUserID])
                //                let userDatabase = rootRefDB.child("users/\(user)")
                //                database.setValue(["followCount": ])
                
                editProfileButton.backgroundColor = UIColor(red:0.44, green:0.75, blue:0.31, alpha:1.00)
                editProfileButton.setTitle("FOLLOWING", for: UIControlState())
                editProfileButton.setTitleColor(UIColor.white, for: UIControlState())
                editProfileButton.layer.borderWidth = 0.8
                editProfileButton.layer.borderColor = UIColor.clear.cgColor
                
                
                following = true
                
            }
        }
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToIndividualPost" {
            let dvc = segue.destination as? IndividualPostViewController
            let indexPath = self.profileCollectionView.indexPathsForSelectedItems
            let url = self.newArray[((indexPath?.first as NSIndexPath?)?.row)!]
            dvc!.postURL = url
            dvc!.profilePictureString = profileURLString!
            
        } else {
            
            if otherProfile == true {
                otherProfile = false
                
            }
        }
    }
    
    
    
}
