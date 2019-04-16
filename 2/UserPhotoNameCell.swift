//
//  UserPhotoNameCell.swift
//  eleven-actor
//
//  Created by Alexander Kovalov on 19.02.2018.
//

import UIKit
import ActorSDK

protocol UserPhotoNameCellDelegate: class {
    func avatarViewTap(_ cell: UserPhotoNameCell)
    func audioCallStart(_ cell: UserPhotoNameCell)
    func videoCallStart(_ cell: UserPhotoNameCell)
}

class UserPhotoNameCell: UITableViewCell, FormatUserPresenceProtocol {
    private let binder = AABinder()

    weak var delegate : UserPhotoNameCellDelegate?
    
    let avatarView: AAAvatarView = {
        let view = AAAvatarView()
        view.size = CGSize(width: 56, height: 56)
        return view
    }()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    func configureCellUser(user: ACUserVM) {
        self.separatorInset = UIEdgeInsets.zero
        self.nameLabel.text = user.getNameModel().get()
        
        binder.bind(user.getAvatarModel(), closure: { (value: ACAvatar?) -> () in
            self.avatarView.bind(user.getNameModel().get(), id: Int(user.getId()), avatar: value)
        })
        
        binder.bind(user.getPresenceModel()) { [unowned self] (presence:ACUserPresence?) in
            guard let presence = presence else {
                return
            }
            
            var presenceText: String
            
            var subtitleColor: UIColor
            
            if user.isBot() {
                presenceText = "bot"
                subtitleColor = ActorSDK.sharedActor().style.userOnlineColor
            } else if presence.state.ordinal() == ACUserPresence_State.online().ordinal() {
                subtitleColor = ActorSDK.sharedActor().style.userOnlineColor
                presenceText = LocalizedStringConstants.contactsElvnOnline
            } else {
                subtitleColor = ActorSDK.sharedActor().style.userOfflineColor
                presenceText = self.getDateTextDescription(date: presence.lastSeen)
            }
            
            self.statusLabel.text = presenceText
            self.statusLabel.textColor = subtitleColor
        }
    }
    
    @IBAction func actionCallButton(_ sender: UIButton) {
        if let delegate = self.delegate {
            delegate.audioCallStart(self)
        }
    }
    
    @IBAction func actionVideoCallButton(_ sender: UIButton) {
        if let delegate = self.delegate {
            delegate.videoCallStart(self)
        }
    }
    
    @objc func actionAvatarDidTap() {
        if let delegate = self.delegate {
            delegate.avatarViewTap(self)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(actionAvatarDidTap)))
        avatarView.isUserInteractionEnabled = true
        addSubview(avatarView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarView.origin.x = 16
        avatarView.center.y = bounds.midY
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        binder.unbindAll()
    }
}
