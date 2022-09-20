//
//  CustomTVC.swift
//  APITestForRest
//
//  Created by yeoh on 19/09/2022.
//

import UIKit

class CustomTVC: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var townLabel: UILabel!
    @IBOutlet weak var adultMaskLabel: UILabel!
    @IBOutlet weak var childMaskLabel: UILabel!
    
    
    static let cellIdentifier = "CustomTVC"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
