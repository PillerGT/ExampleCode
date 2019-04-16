//
//  UserDescriptionCell.swift
//  eleven-actor
//
//  Created by Alexander Kovalov on 19.02.2018.
//

import UIKit
import ActorSDK

public enum TypeDescription : UInt {
    case nick = 0
    case phone
    case email
}

class UserDescriptionCell: UITableViewCell {

    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var descriptionLabel : UILabel!

    func configDescriptionCell(type:TypeDescription, data:AnyObject) {
        var title: String
        var description: String
        
        switch type {
        case .nick:
            title = AALocalized("ProfileUsername")
            description = "@\(data as! String)"
            
        case .phone:
            let phoneUser = data as! ACUserPhone
            title = AALocalized("SettingsMobilePhone")
            description = "+\(phoneUser.phone)"
            
        case .email:
            let emailUser = data as! ACUserEmail
            title = emailUser.title
            description = emailUser.email
        }
        
        self.titleLabel.text = title
        self.descriptionLabel.text = description
    }  
}
