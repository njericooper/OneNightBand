//
//  AddMediaToProfile.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 12/1/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage
import Firebase

protocol RemoveVideoDelegate : class
{
    func removeVideo(removalVid: NSURL)
    
}
protocol RemoveVideoData : class
{
    weak var removeVideoDelegate : RemoveVideoDelegate? { get set }
}
protocol RemovePicDelegate : class
{
    func removePic(removalPic: UIImage)
    
}
protocol RemovePicData : class
{
    weak var removePicDelegate : RemovePicDelegate? { get set }
}



class AddMediaToSession: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, RemoveVideoDelegate, RemovePicDelegate{
    
    
    var curIndexPath = [IndexPath]()
    var curCount = Int()
    
    let picker = UIImagePickerController()
    
    var movieURLFromPicker: NSURL?
    var curCell: VideoCollectionViewCell?
    


    
    
    @IBAction func addPicTouched(_ sender: AnyObject) {
        currentPicker = "photo"
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)

    }
    
    
    @IBAction func chooseVidFromPhoneSelected(_ sender: AnyObject) {
        currentPicker = "vid"
        picker.mediaTypes = ["public.movie"]
        present(picker, animated: true, completion: nil)
    }
    
    @IBOutlet weak var vidFromPhoneCollectionView: UICollectionView!
    @IBOutlet weak var youtubeCollectionView: UICollectionView!
    var tempArray1 = [String]()
    var tempArray = [String]()
    var lastIndexPath: IndexPath?
    @IBOutlet weak var shadeView: UIView!
    @IBAction func addYoutubeVideoButtonPressed(_ sender: AnyObject) {
        
        if youtubeLinkField == nil{
            print("youtube field empty") //display error popup
        }else{
            self.currentYoutubeLink = NSURL(string: self.youtubeLinkField.text!)
            
            
        
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            let snapshots = snapshot.children.allObjects as! [FIRDataSnapshot]
            
            for snap in snapshots{
                self.tempArray1.append(snap.key)
            }
            //if tempArray1.contains("media"){
                for snap in snapshots{
                    if snap.key == "media"{
                        let mediaKids = snap.children.allObjects as! [FIRDataSnapshot]
                        
                        for mediaKid in mediaKids{
                            self.tempArray.append(mediaKid.key )
                        }
                    }
            }
        })
        
                        //if self.tempArray.contains("youtube"){
                    
                            self.tempLink = self.currentYoutubeLink
                            self.currentCollectID = "youtube"
                                youtubeLinkArray.append(self.currentYoutubeLink)
                                print(youtubeLinkArray)
                                let insertionIndexPath = IndexPath(row: self.youtubeLinkArray.count - 1, section: 0)
                                DispatchQueue.main.async{


                            self.youtubeCollectionView.insertItems(at: [insertionIndexPath])
                            
            }
        }
        
        
        

        
        self.youtubeLinkField.text = ""

    
    }
    var mediaArray: [[String:Any]]?
    let userID = FIRAuth.auth()?.currentUser?.uid
    //var newestYoutubeVid: String?
    
    var currentYoutubeTitle: String?
    var vidFromPhoneArray = [NSURL]()
    var youtubeDataArray = [String]()
    var recentlyAddedVidArray = [String]()
    var recentlyAddedPicArray = [UIImage]()
    
    //uploads appropriate media to database
    @IBAction func saveTouched(_ sender: AnyObject) {
        if (recentlyAddedVidArray.count == 0 && currentYoutubeLink == nil && needToUpdatePics == false && needToRemove == false){
           print("field empty")
            
        }else{
            var values = Dictionary<String, Any>()
            var values2 = Dictionary<String, Any>()
            let recipient = self.ref.child("users").child(userID!).child("media")
            
            //var values4 = Dictionary<String, Any>()
            
            print("link array: \(self.youtubeLinkArray)")
            //for val in self.recentlyAddedVidArray{
              //  self.youtubeDataArray.append(String(describing: val))
            //}
            //values4["youtube"] = self.youtubeDataArray
            //ref.child("users").child(userID!).child("media").updateChildValues(values4)
            //print(self.youtubeDataArray)
            for link in youtubeLinkArray{
                self.youtubeDataArray.append(String(describing: link))
            }
            
            //self.youtubeDataArray.append(String(describing: self.currentYoutubeLink!))
            values2["youtube"] = self.youtubeDataArray
            
            recipient.updateChildValues(values2, withCompletionBlock: {(err, ref) in
                if err != nil {
                    print(err!)
                    return
                }
            })
            

            if recentlyAddedVidArray.count != 0{
                let videoName = NSUUID().uuidString
                let storageRef = FIRStorage.storage().reference(withPath: "session_videos").child("\(videoName).mov")
                let uploadMetadata = FIRStorageMetadata()
                uploadMetadata.contentType = "video/quicktime"
                for nsurl in recentlyAddedVidArray{
                    let uploadTask = storageRef.putFile(NSURL(string: nsurl) as! URL, metadata: uploadMetadata){(metadata, error) in
                        if(error != nil){
                            print("got an error: \(error)")
                        }
                    }
                }
                ref.child("users").child(userID!).child("media").child("vidsFromPhone").observeSingleEvent(of: .value, with: { (snapshot) in
                    let snapshots = snapshot.children.allObjects as! [FIRDataSnapshot]
                    for snap in snapshots{
                        self.vidFromPhoneArray.append(NSURL(string: snap.value as! String)!)
                    }
                    if self.vidFromPhoneArray.count != 0{
                        for vid in self.recentlyAddedPhoneVid{
                            self.vidFromPhoneArray.append(NSURL(string: vid)!)
                        }
                    }
                    values["vidsFromPhone"] = self.vidFromPhoneArray
                    if self.vidFromPhoneArray.count != 0{
                        recipient.updateChildValues(values, withCompletionBlock: {(err, ref) in
                            if err != nil {
                                print(err as Any)
                                return
                            }
                        })
                    }
                })
            }
            
            //**the only problem is reloading picture collection view on profile after adding new image
            print("hello")
            if self.needToUpdatePics == true{
                print("profPicArray: \(self.profPicArray)")
                var count = 0
                for pic in profPicArray{
                    
                    let imageName = NSUUID().uuidString
                    let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
                    if let uploadData = UIImageJPEGRepresentation(pic, 0.1) {
                        storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                            if error != nil {
                                print(error!)
                                return
                            }

                       
                    
                        
                    self.picArray.append((metadata?.downloadURL()?.absoluteString)!)
                                       //for pic in profPicArray{
                  //  self.picArray.append(String(describing: URL(Data(data: pic))))
                //}
                
               
                    var values3 = Dictionary<String, Any>()
                    print(self.picArray)
                    values3["profileImageUrl"] = self.picArray
                    self.ref.child("users").child(self.userID!).updateChildValues(values3, withCompletionBlock: {(err, ref) in
                        if err != nil {
                            print(err!)
                            return
                        }
                    })
                            if count == self.profPicArray.count-1{
                                self.performSegue(withIdentifier: "AddMediaToMain", sender: self)
                            }
                            count += 1
                            
                            
                        })
                        

                        
                    }
                    
                }
                

        
            }
        }
        
        


            
        
             
        
      

        
    }
    
    
    //**I'm removing the first element everytime rather than at the correct index path. Also might be adding to begginning but appending to array thus creating data inconsistency
    var needToUpdatePics = Bool()
    @IBOutlet weak var picCollectionView: UICollectionView!
    var needToRemovePic = Bool()
    internal func removePic(removalPic: UIImage){
        self.currentCollectID = "picsFromPhone"
        needToRemovePic = true
        needToUpdatePics = true
        print("removePic")
        for pic in 0...profPicArray.count-1{
            if removalPic == profPicArray[pic]{
                profPicArray.remove(at: pic)
                DispatchQueue.main.async{
                    self.picCollectionView.deleteItems(at: [IndexPath(row: pic, section: 0)])
                    print("PiccollectionViewCells: \(self.picCollectionView.visibleCells.count)")
                }
                break
            }
        }
        
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "AddMediaToMain", sender: self)
    }

    var needToRemove = Bool()
    internal func removeVideo(removalVid: NSURL) {
        self.currentCollectID = "youtube"
        
        needToRemove = true
        
        for vid in 0...youtubeLinkArray.count-1{
            if removalVid == youtubeLinkArray[vid]{
                youtubeLinkArray.remove(at: vid)
                DispatchQueue.main.async{
                    self.youtubeCollectionView.deleteItems(at: [IndexPath(row: vid, section: 0)])
                }
                break
                
                
                
            }
        }
        
        
        self.curCount -= 1
        
        
       /* self.youtubeCollectionView.animateWithDuration:0 animations:^{
            [collectionView performBatchUpdates:^{
            [collectionView reloadItemsAtIndexPaths:indexPaths];
            } completion:nil];
            }*/
        
        //DispatchQueue.main.async {
           // self.youtubeCollectionView.reloadData()
            
        //}
    }
    
    var picArray = [String]()
    var currentPicker: String?
    @IBOutlet weak var youtubeLinkField: UITextField!
    
    
    weak var dismissalDelegate: DismissalDelegate?
    var ref = FIRDatabase.database().reference()
    

    var sizingCell = VideoCollectionViewCell()
    var sizingCell2 = PictureCollectionViewCell()
    var currentCollectID = "youtube"
    var currentYoutubeLink: NSURL!
    var youtubeLinkArray = [NSURL]()
    
    var tempLink: NSURL?
   
    
    
    
    
    let imagePicker = UIImagePickerController()
    var videoCollectEmpty: Bool?
    var recentlyAddedPhoneVid = [String]()
    var profPicArray = [UIImage]()
    var viewDidAppearBool = false
    override func viewDidAppear(_ animated: Bool) {
        
        if viewDidAppearBool == false{
            recentlyAddedVidArray.removeAll()
            youtubeDataArray.removeAll()
            needToRemove = false
            needToRemovePic = false
            imagePicker.delegate = self
            picker.delegate = self
            curCount = 0
        
            ref.child("users").child(userID!).child("media").child("youtube").observeSingleEvent(of: .value, with: { (snapshot) in
            if self.youtubeLinkArray.count == 0{
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                self.currentCollectID = "youtube"
                
                    for snap in snapshots{
                    
                        self.youtubeLinkArray.append(NSURL(string: snap.value as! String)!)
                    
                    
                    }
                    if self.youtubeLinkArray.count == 0{
                        self.videoCollectEmpty = true
                        let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                        self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                    
                        self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                        self.youtubeCollectionView.backgroundColor = UIColor.clear
                        self.youtubeCollectionView.dataSource = self
                        self.youtubeCollectionView.delegate = self
                    
                    }else{
                        self.videoCollectEmpty = false
                        for snap in snapshots{
                            self.tempLink = NSURL(string: (snap.value as? String)!)
                        
                        //self.YoutubeArray.append(snap.value as! String)
                        
                            let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                            self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                        
                            self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                            self.youtubeCollectionView.backgroundColor = UIColor.clear
                            self.youtubeCollectionView.dataSource = self
                            self.youtubeCollectionView.delegate = self
                            self.curCount += 1
                        
                        }
                    }
            }
        }
            
            if self.vidFromPhoneArray.count == 0{
                self.ref.child("users").child(self.userID!).child("media").child("vidsFromPhone").observeSingleEvent(of: .value, with: { (snapshot) in
                
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    
                    
                        for snap in snapshots{
                        
                            self.vidFromPhoneArray.append(NSURL(string: (snap.value as? String)!)!)
                        
                        }
                        if self.vidFromPhoneArray.count == 0{
                            self.videoCollectEmpty = true
                        }else{
                            self.currentCollectID = "vidFromPhone"
                            self.videoCollectEmpty = false
                            for snap in snapshots{
                                self.tempLink = NSURL(string: (snap.value as? String)!)
                            
                            //self.YoutubeArray.append(snap.value as! String)
                            
                                let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                                self.vidFromPhoneCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                            
                                self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                                self.vidFromPhoneCollectionView.backgroundColor = UIColor.clear
                                self.vidFromPhoneCollectionView.dataSource = self
                                self.vidFromPhoneCollectionView.delegate = self
                                self.curCount += 1
                            
                            }
                        }
                    
                }
            })
            }
            if self.profPicArray.count == 0{
                self.ref.child("users").child(self.userID!).child("profileImageUrl").observeSingleEvent(of: .value, with: { (snapshot) in
                
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    
                    
                        for snap in snapshots{
                        
                            if let url = NSURL(string: snap.value as! String){
                                if let data = NSData(contentsOf: url as URL){
                                    self.profPicArray.append(UIImage(data: data as Data)!)
                                
                                }
                            
                            }
                        }
                        print("pArray: \(self.profPicArray)")
                        self.currentCollectID = "picsFromPhone"
                        self.videoCollectEmpty = false
                        for snap in snapshots{
                            self.tempLink = NSURL(string: (snap.value as? String)!)
                        
                            //self.YoutubeArray.append(snap.value as! String)
                        
                            let cellNib = UINib(nibName: "PictureCollectionViewCell", bundle: nil)
                            self.picCollectionView.register(cellNib, forCellWithReuseIdentifier: "PictureCollectionViewCell")
                        
                            self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! PictureCollectionViewCell?)!
                            self.picCollectionView.backgroundColor = UIColor.clear
                            self.picCollectionView.dataSource = self
                            self.picCollectionView.delegate = self
                        
                        }
                    }
                
                })
            }
            
            
        })
            self.viewDidAppearBool = true
        }
        
        
        
        
        
        
        
        
        
        
    }
    
    

    
    /*override func viewDidLoad(){
        super.viewDidLoad()
        recentlyAddedVidArray.removeAll()
        youtubeDataArray.removeAll()
        needToRemove = false
        needToRemovePic = false
        imagePicker.delegate = self
        picker.delegate = self
        curCount = 0
        
        ref.child("users").child(userID!).child("media").child("youtube").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                self.currentCollectID = "youtube"
                
                for snap in snapshots{
                    
                    self.youtubeLinkArray.append(NSURL(string: snap.value as! String)!)
                    

                }
                if self.youtubeLinkArray.count == 0{
                    self.videoCollectEmpty = true
                    let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                    self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                    
                    self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                    self.youtubeCollectionView.backgroundColor = UIColor.clear
                    self.youtubeCollectionView.dataSource = self
                    self.youtubeCollectionView.delegate = self
                    
                }else{
                    self.videoCollectEmpty = false
                    for snap in snapshots{
                        self.tempLink = NSURL(string: (snap.value as? String)!)
                        
                        //self.YoutubeArray.append(snap.value as! String)
                        
                        let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                        self.youtubeCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                        
                        self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                        self.youtubeCollectionView.backgroundColor = UIColor.clear
                        self.youtubeCollectionView.dataSource = self
                        self.youtubeCollectionView.delegate = self
                        self.curCount += 1

                    }
                }

                

                
            }
            
        
        self.ref.child("users").child(self.userID!).child("media").child("vidsFromPhone").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                
                
                for snap in snapshots{
                    
                    self.vidFromPhoneArray.append(NSURL(string: (snap.value as? String)!)!)

                }
                if self.vidFromPhoneArray.count == 0{
                    self.videoCollectEmpty = true
                    
                    /*let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                    self.vidFromPhoneCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                    
                    self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                    self.vidFromPhoneCollectionView.backgroundColor = UIColor.clear
                    self.vidFromPhoneCollectionView.dataSource = self
                    self.vidFromPhoneCollectionView.delegate = self*/
                    
                }else{
                    self.currentCollectID = "vidFromPhone"
                    self.videoCollectEmpty = false
                    for snap in snapshots{
                        self.tempLink = NSURL(string: (snap.value as? String)!)
                        
                        //self.YoutubeArray.append(snap.value as! String)
                        
                        let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                        self.vidFromPhoneCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                        
                        self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                        self.vidFromPhoneCollectionView.backgroundColor = UIColor.clear
                        self.vidFromPhoneCollectionView.dataSource = self
                        self.vidFromPhoneCollectionView.delegate = self
                        self.curCount += 1
                        
                    }
                }
                
                
                
                
            }
        })
            self.ref.child("users").child(self.userID!).child("profileImageUrl").observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    
                    
                    for snap in snapshots{
                        
                        if let url = NSURL(string: snap.value as! String){
                            if let data = NSData(contentsOf: url as URL){
                                self.profPicArray.append(UIImage(data: data as Data)!)
                                
                            }
                            
                        }
                    }
                    self.currentCollectID = "picsFromPhone"
                    self.videoCollectEmpty = false
                    for snap in snapshots{
                        self.tempLink = NSURL(string: (snap.value as? String)!)
                        
                        //self.YoutubeArray.append(snap.value as! String)
                        
                        let cellNib = UINib(nibName: "PictureCollectionViewCell", bundle: nil)
                        self.picCollectionView.register(cellNib, forCellWithReuseIdentifier: "PictureCollectionViewCell")
                        
                        self.sizingCell2 = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! PictureCollectionViewCell?)!
                        self.picCollectionView.backgroundColor = UIColor.clear
                        self.picCollectionView.dataSource = self
                        self.picCollectionView.delegate = self
                        
                    }
                }
                
            })

            
        })
        


        
        
        
       

        
    }*/
    
    
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
            }, completion:{(finished : Bool)  in
                if (finished)
                {
                    self.view.removeFromSuperview()
                }
        });
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if self.currentCollectID == "youtube"{
            return youtubeLinkArray.count
            

        }
        if self.currentCollectID == "vidsFromPhone"{
            return vidFromPhoneArray.count
        }
            else{
            return profPicArray.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if currentCollectID != "picsFromPhone"{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCollectionViewCell", for: indexPath as IndexPath) as! VideoCollectionViewCell
            self.configureCell(cell, forIndexPath: indexPath as NSIndexPath)
            cell.indexPath = indexPath
            
            //self.curIndexPath.append(indexPath)
            self.curCell = cell
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PictureCollectionViewCell", for: indexPath as IndexPath) as! PictureCollectionViewCell
            self.configurePictureCell(cell, forIndexPath: indexPath as NSIndexPath)
            
            
            //self.curIndexPath.append(indexPath)
            
            return cell
        }
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        
    }
    
    func configurePictureCell(_ cell: PictureCollectionViewCell, forIndexPath indexPath: NSIndexPath){
        if self.profPicArray.count != 0{
            print(indexPath.row)
            cell.picImageView.image = self.profPicArray[indexPath.row]//loadImageUsingCacheWithUrlString(String(describing: self.profPicArray[indexPath.row]))
            cell.picData = self.profPicArray[indexPath.row]
            cell.removePicDelegate = self
            cell.deleteButton.isHidden = false
        }
    }
    
    func configureCell(_ cell: VideoCollectionViewCell, forIndexPath indexPath: NSIndexPath) {
        print(self.currentCollectID)
        if(self.currentCollectID == "youtube"){
            if self.youtubeLinkArray.isEmpty == true{
                cell.layer.borderColor = UIColor.white.cgColor
                cell.layer.borderWidth = 2
                cell.removeVideoButton.isHidden = true
                cell.videoURL = nil
                cell.youtubePlayerView.isHidden = true
                //cell.youtubePlayerView.loadVideoURL(videoURL: self.youtubeArray[indexPath.row])
                cell.removeVideoButton.isHidden = true
                cell.noVideosLabel.isHidden = false
            }else{
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.layer.borderWidth = 0
                cell.removeVideoButton.isHidden = false
                cell.removeVideoDelegate = self
                cell.youtubePlayerView.isHidden = false
                cell.videoURL = self.youtubeLinkArray[indexPath.row] //NSURL(string: self.youtubeArray[indexPath.row])
                cell.youtubePlayerView.loadVideoURL(videoURL: self.youtubeLinkArray[indexPath.row])//NSURL(string: self.recentlyAddedVidArray[indexPath.row])!)
        
                cell.noVideosLabel.isHidden = true
            }
        }
        else{
            if self.vidFromPhoneArray.count == 0 {
                return
            }
        }
    }
    
    @IBOutlet weak var newImage: UIImageView!
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if currentPicker == "photo"{
        
            var selectedImageFromPicker: UIImage?
            
            if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
                selectedImageFromPicker = editedImage
            
            } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
                selectedImageFromPicker = originalImage
            }
        
            if let selectedImage = selectedImageFromPicker {
                
                self.recentlyAddedPicArray.append(selectedImage)
                self.profPicArray.append(selectedImage)
                needToUpdatePics = true
                
                
                
                
                }
            
            
        
            self.dismiss(animated: true, completion: nil)
            
            
            let insertionIndexPath = IndexPath(row: self.profPicArray.count - 1, section: 0)
            
            DispatchQueue.main.async{
                
                print("PiccollectionViewCells: \(self.picCollectionView.visibleCells.count)")
                self.picCollectionView.insertItems(at: [insertionIndexPath])
                print("PiccollectionViewCells: \(self.picCollectionView.visibleCells.count)")
                
            }
            

            
        
        }else{
            if let movieURL = info[UIImagePickerControllerMediaURL] as? NSURL{
                movieURLFromPicker = movieURL
                dismiss(animated: true, completion: nil)
                self.recentlyAddedPhoneVid.append(String(describing: movieURL))
                self.vidFromPhoneArray.append(movieURL)
                //uploadMovieToFirebaseStorage(url: movieURL)
                ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                    let snapshots = snapshot.children.allObjects as! [FIRDataSnapshot]
                    var tempArray1 = [String]()
                    for snap in snapshots{
                        tempArray1.append(snap.key)
                    }
                    if tempArray1.contains("media"){
                        for snap in snapshots{
                            if snap.key == "media"{
                                let mediaKids = snap.children.allObjects as! [FIRDataSnapshot]
                                var tempArray = [String]()
                                for mediaKid in mediaKids{
                                    tempArray.append(mediaKid.key)
                                }
                                if tempArray.contains("vidsFromPhone"){
                                   // self.tempLink = self.currentYoutubeLink
                                    self.currentCollectID = "vidFromPhone"
                                    self.vidFromPhoneArray.append(movieURL)
                                    
                                    let insertionIndexPath = IndexPath(row: self.vidFromPhoneArray.count - 1, section: 0)
                                    DispatchQueue.main.async{
                                        
                                        
                                        self.vidFromPhoneCollectionView.insertItems(at: [insertionIndexPath])
                                        
                                    }

                                    break
                                }else{
                                    //self.youtubeLinkArray.append(NSURL(string: self.youtubeLinkField.text!)!)
                                    //self.tempLink = NSURL(string: self.youtubeLinkField.text!)
                                    
                                    //self.YoutubeArray.append(snap.value as! String)
                                    let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                                    self.vidFromPhoneCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                                    
                                    self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                                    self.vidFromPhoneCollectionView.backgroundColor = UIColor.clear
                                    self.vidFromPhoneCollectionView.dataSource = self
                                    self.vidFromPhoneCollectionView.delegate = self
                                    self.curCount += 1
                                    break
                                }
                            }
                        }
                    }//else if it doesnt contain media
                    else{
                        //self.youtubeLinkArray.append(NSURL(string: self.youtubeLinkField.text!)!)
                        //self.tempLink = NSURL(string: self.youtubeLinkField.text!)
                        
                        //self.YoutubeArray.append(snap.value as! String)
                        let cellNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
                        self.vidFromPhoneCollectionView.register(cellNib, forCellWithReuseIdentifier: "VideoCollectionViewCell")
                        
                        self.sizingCell = ((cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! VideoCollectionViewCell?)!
                        self.vidFromPhoneCollectionView.backgroundColor = UIColor.clear
                        self.vidFromPhoneCollectionView.dataSource = self
                        self.vidFromPhoneCollectionView.delegate = self
                        self.curCount += 1
                        
                    }
                })
                
              
                /*DispatchQueue.main.async {
                    self.vidFromPhoneCollectionView.reloadData()
                    
                }*/
                
                
               // self.youtubeLinkField.text = ""
                
         

            }

        }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    }


    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
        
}
//crashes when you click remove video button before view fully loads
