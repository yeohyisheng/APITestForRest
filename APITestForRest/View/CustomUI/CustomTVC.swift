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
        nameLabel.textColor = #colorLiteral(red: 0.4388833642, green: 0.4838103056, blue: 0.4787042737, alpha: 1)
        townLabel.textColor = #colorLiteral(red: 0.4388833642, green: 0.4838103056, blue: 0.4787042737, alpha: 1)
        adultMaskLabel.textColor = #colorLiteral(red: 0.4388833642, green: 0.4838103056, blue: 0.4787042737, alpha: 1)
        childMaskLabel.textColor = #colorLiteral(red: 0.4388833642, green: 0.4838103056, blue: 0.4787042737, alpha: 1)
        self.backgroundColor = .clear
//        let bgColorView = UIView()
//        bgColorView.backgroundColor = .gray
//        self.selectedBackgroundView = bgColorView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
