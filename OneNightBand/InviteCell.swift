//
//  InviteCell.swift
//  OneNightBand
//
//  Created by Thomas Threlkeld on 2/5/17.
//  Copyright © 2017 Thomas Threlkeld. All rights reserved.
//

import UIKit

class InviteCell: UICollectionViewCell, AcceptDeclineData  {

    @IBAction func acceptButtonPressed(_ sender: Any) {
        acceptDeclineDelegate?.acceptPressed(indexPathRow: self.indexPathRow, indexPath: self.indexPath,curCell: self)
    }
    @IBAction func declineButtonPressed(_ sender: Any) {
        acceptDeclineDelegate?.declinePressed(indexPathRow: self.indexPathRow, indexPath: self.indexPath, curCell: self)
    }
    @IBOutlet weak var sessionImage: UIImageView!
    @IBOutlet weak var senderPic: UIImageView!
    @IBOutlet weak var senderName: UILabel!
    @IBOutlet weak var instrumentNeeded: UILabel!
    @IBOutlet weak var sessionDate: UILabel!
    @IBOutlet weak var sessionName: UILabel!
    @IBOutlet weak var sessionDescription: UITextView!
    
    weak var acceptDeclineDelegate : AcceptDeclineDelegate?
    
    var indexPathRow = Int()
    var indexPath = IndexPath()
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

}
