//
//  UserActionContactCell.swift
//  eleven-actor
//
//  Created by Alexander Kovalov on 22.02.2018.
//

import UIKit
import ActorSDK

class UserActionContactCell: UITableViewCell {

    @IBOutlet weak var iconImageView : UIImageView!
    @IBOutlet weak var titleLabel : UILabel!

    func configActionCell(isContactModel:Bool) {
        if isContactModel {
            self.iconImageView.image = UIImage.init(named: "remove_contact")
            self.titleLabel.text = AALocalized("ProfileRemoveFromContacts")
        } else {
            self.iconImageView.image = UIImage.init(named: "add_contact")
            self.titleLabel.text = AALocalized("ProfileAddToContacts")
        }
    }
}
