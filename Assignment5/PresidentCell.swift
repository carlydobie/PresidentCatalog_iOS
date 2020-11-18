//
//  PresidentCell.swift
//  Assignment4
//
//  Created by Carly Dobie on 11/4/20.
//  Copyright © 2020 Carly Dobie. All rights reserved.
//

import UIKit

// View for each cell in table
class PresidentCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var partyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}