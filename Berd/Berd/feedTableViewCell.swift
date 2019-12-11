//
//  feedTableViewCell.swift
//  Berd
//
//  Created by Aaron Parks on 12/2/19.
//  Copyright © 2019 Aaron Parks. All rights reserved.
//

import UIKit

class feedTableViewCell: UITableViewCell {

    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var rating5: UIImageView!
    @IBOutlet weak var rating4: UIImageView!
    @IBOutlet weak var rating3: UIImageView!
    @IBOutlet weak var rating2: UIImageView!
    @IBOutlet weak var rating1: UIImageView!
    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
