//
//  CustomChatCollectionViewCell.swift
//  WebSocialNetwork
//
//  Created by Jason on 1/31/20.
//  Copyright © 2020 Jason. All rights reserved.
//

import UIKit

class CustomChatCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var oppoView: UIView!
    @IBOutlet weak var oppoLabel: UILabel!
    
    @IBOutlet weak var meView: UIView!
    @IBOutlet weak var meLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setUpCellData(recId: String, contentTxt: String, curUserId: String) {
        meView.isHidden = true
        oppoView.isHidden = true
        
        if recId == curUserId {
            // TODO: unsolved mystery of isHidden property
            oppoView.isHidden = false
            oppoLabel.text = contentTxt
        } else {
            
            meView.isHidden = false
            meLabel.text = contentTxt
        }
             
        
        
    }
}
