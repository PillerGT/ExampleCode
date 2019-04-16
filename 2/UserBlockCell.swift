//
//  UserBlockCell.swift
//  eleven-actor
//
//  Created by Alexander Kovalov on 19.02.2018.
//

import UIKit
import ActorSDK

class UserBlockCell: UITableViewCell {

    @IBOutlet weak var titleLabel : UILabel!

    func configBlockCell(isBlocked: Bool) {
        if isBlocked {
            self.titleLabel.text = LocalizedStringConstants.contactsUnblockUser
        } else {
            self.titleLabel.text = LocalizedStringConstants.contactsBlockUser
        }
        self.titleLabel.textColor = ActorSDK.sharedActor().style.cellDestructiveColor
    }
}
