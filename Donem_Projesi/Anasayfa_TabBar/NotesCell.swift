//
//  NotesCell.swift
//  Donem_Projesi
//
//  Created by Zeynep Cansız on 2.05.2023.
//

import UIKit

class NotesCell: UITableViewCell {
    
    @IBOutlet weak var notlar: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
