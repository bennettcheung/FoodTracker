//
//  MealTableViewCell.swift
//  FoodTracker
//
//  Created by Bennett on 2018-09-07.
//  Copyright © 2018 Bennett. All rights reserved.
//

import UIKit

class MealTableViewCell: UITableViewCell {

  //MARK: Properties
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var photoImageView: UIImageView!
  @IBOutlet weak var ratingControl: RatingControl!

  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
  override func prepareForReuse() {
    nameLabel.text = ""
    photoImageView.image = nil
    ratingControl.rating = 0
  }
}
