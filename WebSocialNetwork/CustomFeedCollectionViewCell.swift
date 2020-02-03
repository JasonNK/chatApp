//
//  CustomFeedCollectionViewCell.swift
//  WebSocialNetwork
//
//  Created by Jason on 1/28/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import UIKit
import Firebase

class CustomFeedCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var txtLabel: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var curView: UIView!
    
    @IBOutlet weak var deleteBtn: UIButton!
    var userId: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func awakeFromNib() {
        // gurantee all the iboutlets in the storyboard have already initialized
        super.awakeFromNib()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    
    
    func updateCell(userId: String?, userFirstName: String?, desc: String?, feedImage: UIImage?, userImage: UIImage?, time: String?) {
        self.userId = userId
        self.userImg.image = userImage ?? UIImage()
        self.userName.text = userFirstName
        self.txtLabel.text = desc
        self.postImg.image = feedImage ?? UIImage()
        
        
        
    }
    
    
    
    
    
}
