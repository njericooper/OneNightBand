//
//  ArtistFinderViewController.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 10/8/16.
//  Copyright © 2016 Thomas Threlkeld. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreLocation


class ArtistFinderViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SessionIDDest, PerformSegueInArtistFinderController, UIPickerViewDelegate,UIPickerViewDataSource{
 
    @IBOutlet weak var InstrumentPicker: UIPickerView!
    
    @IBOutlet weak var artistCollectionView: UICollectionView!
    
    
    @IBOutlet weak var noArtistsFoundLabel: UILabel!
    
    var sizingCell: ArtistCardCell?
    weak var getSessionID : GetSessionIDDelegate?
    var artistPageViewController: UIPageViewController!
    var artistArray = [Artist]()
    var ref = FIRDatabase.database().reference()
    var thisSession: String!
    var thisSessionObject: Session!
    var instrumentPicked: String!
    var distancePicked: String!
    var profileArtistUID: String?
    var distanceMenuText = ["5","25", "50", "75", "100", "125","150", "175","500", "2000"]
    var menuText = ["Guitar", "Bass Guitar", "Piano", "Saxophone", "Trumpet", "Stand-up Bass", "violin", "Drums", "Cello", "Trombone", "Vocals", "Mandolin", "Banjo", "Harp"]
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ArtistProfileViewController
        {
            vc.artistUID = profileArtistUID
        }
    }
    @IBOutlet weak var searchButton: UIButton!
    func performSegueToProfile(artistUID: String) {
        self.profileArtistUID = artistUID
        performSegue(withIdentifier: "FinderToProfile", sender: self)
    }
    @IBOutlet weak var distancePicker: UIPickerView!
    
    var coordinateUser1: CLLocation?
    var coordinateUser2: CLLocation?
    //var distance: Double?
    
    var tempLong: CLLocationDegrees?
    var tempLat: CLLocationDegrees?
    var distanceInMeters: Double?
    var artistAfterDist = [Artist]()
    
    var instrumentArray = [String]()
    @IBAction func searchForArtistsPressed(_ sender: AnyObject) {
        var tempCoordinate: CLLocation?
        var tempLong: CLLocationDegrees?
        var tempLat: CLLocationDegrees?
        var tempCoordinate2: CLLocation?
        var tempLong2: CLLocationDegrees?
        var tempLat2: CLLocationDegrees?
        var tempDistInMeters: Double?
        

        artistArray = [Artist]()
        artistAfterDist = [Artist]()
        FIRDatabase.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                var index = 0
                var artistsAlreadyInSession = [String]()
                FIRDatabase.database().reference().child("sessions").child(self.thisSession).child("sessionArtists").observeSingleEvent(of: .value, with: { (snapshot) in
                for snap in snapshots{
                    if(snap.key != FIRAuth.auth()?.currentUser?.uid){
                        
                        if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                            for snap in snapshots{
                                artistsAlreadyInSession.append(snap.value as! String)
                            }
                        }
                        
                        if let dictionary = snap.value as? [String: Any] {
                            let artist = Artist()
                            artist.setValuesForKeys(dictionary)
                            if(artistsAlreadyInSession.contains(artist.artistUID!) == false){
                                if(self.artistArray.contains(artist) == false){
                                    
                                    //if(artist.instruments.contains(where: (key: self.menuText[self.InstrumentPicker.selectedRow(inComponent: 0)],value: self.menuText.index(of: self.menuText[self.InstrumentPicker.selectedRow(inComponent: 0)]))) == true){
                                    
                                    for key in artist.instruments.keys{
                                        self.instrumentArray.append(key)
                                    }
                                    if(self.instrumentArray.contains(self.menuText[self.InstrumentPicker.selectedRow(inComponent: 0)]) == true){
                                        self.instrumentPicked = self.menuText[self.InstrumentPicker.selectedRow(inComponent: 0)]
                                        self.artistArray.append(artist)
                                        index += 1
                                    }
                                }
                                if(self.artistArray.contains(artist) == true){
                                    if(self.instrumentArray.contains(self.menuText[self.InstrumentPicker.selectedRow(inComponent: 0)]) == false){
                                        self.artistArray.remove(at: index)
                                        index -= 1
                                        
                                    }
                                    
                                }
                                
                            }
                        }
                    }
                    }
                    
        DispatchQueue.main.async {
            print(self.artistArray)
            let userID = FIRAuth.auth()?.currentUser?.uid
            self.ref.child("users").child(userID!).child("location").observeSingleEvent(of: .value, with: { (snapshot) in
            for artist in self.artistArray{
                                print("in artitAfterDist filler")
                                tempLong = artist.location["long"] as? CLLocationDegrees
                                tempLat = artist.location["lat"] as? CLLocationDegrees
                                tempCoordinate = CLLocation(latitude: tempLat!, longitude: tempLong!)
                
                
                                        if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                                            for snap in snapshots{
                                                if snap.key == "long"{
                                                    tempLong2 = snap.value as? CLLocationDegrees
                                                }else{
                                                    tempLat2 = snap.value as? CLLocationDegrees
                                                }
                                            }
                                            tempCoordinate2 = CLLocation(latitude: tempLat2!, longitude: tempLong2!)
                                            tempDistInMeters = tempCoordinate?.distance(from: tempCoordinate2!)
                                            let distanceInMiles = Double(round(10*(tempDistInMeters! * 0.000621371))/10)
                                            //print(distanceInMiles)
                                            if distanceInMiles <= Double(self.distanceMenuText[self.distancePicker.selectedRow(inComponent: 0)])!{
                                                print(distanceInMiles)
                                                self.artistAfterDist.append(artist)
                                                //tempIndex += 1
                                            }
                                        }
                }
                
            
                print(self.artistAfterDist)
                            if self.artistAfterDist.isEmpty{
                                self.noArtistsFoundLabel.isHidden = false
                                self.artistCollectionView.isHidden = true
                                return
                            }else{
                                self.noArtistsFoundLabel.isHidden = true
                                self.artistCollectionView.isHidden = false

                                for _ in self.artistAfterDist{
                                    self.InstrumentPicker.delegate = self
                                    self.InstrumentPicker.dataSource = self
                                    self.distancePicker.delegate = self
                                    self.distancePicker.dataSource = self
                                    let cellNib = UINib(nibName: "ArtistCardCell", bundle: nil)
                                    self.artistCollectionView.register(cellNib, forCellWithReuseIdentifier: "ArtistCardCell")
                                    self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! ArtistCardCell?
                                    self.artistCollectionView.dataSource = self
                                    self.artistCollectionView.delegate = self
                                    self.artistCollectionView.reloadData()
                                    self.artistCollectionView.gestureRecognizers?.first?.cancelsTouchesInView = false
                                    self.artistCollectionView.gestureRecognizers?.first?.delaysTouchesBegan = false
                                }
            }
        
        
            
    
        
                    })
                    }
                })
                
                
            }
            self.reloadInputViews()
        })
        


        
    }
   override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        noArtistsFoundLabel.isHidden = false
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        layout.minimumInteritemSpacing = 20
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        artistCollectionView.collectionViewLayout = layout
        InstrumentPicker.selectRow(menuText.count/2, inComponent: 0, animated: true)
    }
    var currentUser: String?
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleBack), with: nil, afterDelay: 0)
        } else {
            
            currentUser = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    for snap in snapshots{
                        if let dictionary = snap.value as? [String: AnyObject] {
                        let artist = Artist()
                        artist.setValuesForKeys(dictionary)
                        self.artistArray.append(artist)

                    }
                }
            }
                //self.artistCollectionView.gestureRecognizers?.first?.cancelsTouchesInView = false
                self.InstrumentPicker.delegate = self
                self.InstrumentPicker.dataSource = self
                self.distancePicker.delegate = self
                self.distancePicker.dataSource = self
                self.InstrumentPicker.selectRow(self.menuText.count/2, inComponent: 0, animated: false)
                
            }, withCancel: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return artistAfterDist.count
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistCardCell", for: indexPath as IndexPath) as! ArtistCardCell
        cell.delegate = self
        
        
        self.configureCell(cell, forIndexPath: indexPath as NSIndexPath)
        return cell

        
    }

    func configureCell(_ cell: ArtistCardCell, forIndexPath indexPath: NSIndexPath) {
        cell.artistCardCellBioTextView.text = artistAfterDist[indexPath.row].bio
        cell.artistCardCellNameLabel.text = artistAfterDist[indexPath.row].name
        
        cell.artistCardCellImageView.loadImageUsingCacheWithUrlString(artistAfterDist[indexPath.row].profileImageUrl.first!)
        cell.artistUID = artistAfterDist[indexPath.row].artistUID
        cell.invitedSessionID = self.thisSession
        cell.buttonName = self.instrumentPicked
        cell.sessionDate = self.thisSessionObject.sessionDate
        
        self.ref.child("users").child(artistAfterDist[indexPath.row].artistUID!).child("location").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                
                for snap in snapshots{
                        if snap.key == "long"{
                            self.tempLong = snap.value as? CLLocationDegrees
                            
                        }else{
                            self.tempLat = snap.value as? CLLocationDegrees
                        }
                    }
                
                self.coordinateUser2 = CLLocation(latitude: self.tempLat!, longitude: self.tempLong!)
                let userID = FIRAuth.auth()?.currentUser?.uid
                self.ref.child("users").child(userID!).child("location").observeSingleEvent(of: .value, with: { (snapshot) in
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                        
                        for snap in snapshots{
                                if snap.key == "long"{
                                    self.tempLong = snap.value as? CLLocationDegrees
                                    
                                }else{
                                    self.tempLat = snap.value as? CLLocationDegrees
                                }
                            }
                        self.coordinateUser1 = CLLocation(latitude: self.tempLat!, longitude: self.tempLong!)
                        
                        self.distanceInMeters = self.coordinateUser1?.distance(from: self.coordinateUser2!) // result is in meters
                        
                        let distanceInMiles = Double(round(10*(self.distanceInMeters! * 0.000621371))/10)
                        cell.distanceLabel.text = String(distanceInMiles) + " miles"

                        /*if((distanceInMeters! as Double) <= 1609){
                         // under 1 mile
                         }
                         else
                         {
                         // out of 1 mile
                         }*/
                    }
                })
            }
        })
        self.ref.child("users").child(artistAfterDist[indexPath.row].artistUID!).child("instruments").observeSingleEvent(of: .value, with: {(snapshot) in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot]{
                for snap in snapshots{
                    if snap.key == self.instrumentPicked{
                        cell.reputationLabel.text = "skill lvl: \(snap.value as! Int)"
                    }
                }
                
            }
        })
    }

    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    // returns the # of rows in each component..
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if pickerView == self.distancePicker{
            return distanceMenuText.count
        }else{
            return menuText.count
        }
    }
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if pickerView == self.distancePicker{
            let titleData = distanceMenuText[row]
            
            let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.white])
            return myTitle
        }else{
            let titleData = menuText[row]
            
            let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:UIColor.white])
            return myTitle

        }
    
    }
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        
    }
    func handleBack() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        let sessTemp = SessionMakerViewController()
        present(sessTemp, animated: true, completion: nil)
    }

    
    
}



