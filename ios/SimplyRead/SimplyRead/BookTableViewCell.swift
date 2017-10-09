//
//  BookTableViewCell.swift
//  SimplyRead
//
//  Created by jim on 29/8/2017.
//
//

import UIKit

class BookTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var ourPriceLabel: UILabel!
    @IBOutlet weak var depositLabel: UILabel!
    @IBOutlet weak var holderLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
