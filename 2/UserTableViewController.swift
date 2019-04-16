//
//  UserViewController.swift
//  eleven-actor
//
//  Created by Alexander Kovalov on 20.02.2018.
//

import UIKit
import ActorSDK

enum InfoRow: UInt {
    case avatarAndName = 0
    case sendMessage
    case infoUser
    case actionContact
    case notification
    case blockUser
}

struct StructureRow {
    var row : InfoRow
    var content : ContentType?
}

struct ContentType {
    var type : TypeDescription
    var data : AnyObject
}

protocol UserTableViewControllerProtocol: class {
    func userTableViewControllerDidUnblockUser(_ user: ACUserVM)
    func userTableViewControllerDidBlockUser(_ user: ACUserVM)
}

class UserTableViewController: UITableViewController, UserPhotoNameCellDelegate, UserNotificationCellDelegate  {
    
    var user: ACUserVM! {
        didSet {
            uid = user.getId()
            isBot = user.isBot()
            isContactModelTmp = user.isContactModel().get().booleanValue()
        }
    }
    
    weak var delegate: UserTableViewControllerProtocol?
    
    private(set) var uid: Int32!
    private(set) var isBot: Bool!
    private(set) var isContactModelTmp: Bool!
    
    var structureArray = [StructureRow]()
    
    let userPhotoNameIdentifier         = String(describing: UserPhotoNameCell.self)
    let userSendMessageIdentifier       = String(describing: UserSendMessageCell.self)
    let userDescriptionIdentifier       = String(describing: UserDescriptionCell.self)
    let userActionContactCellIdentifier = String(describing: UserActionContactCell.self)
    let userNotificationIdentifier      = String(describing: UserNotificationCell.self)
    let userBlockIdentifier             = String(describing: UserBlockCell.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(user != nil)
        
        setupUserRow()
        setupTableView()
    }
    
    //MARK:- SetupFirstSettings
    private func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        
        tableView.register(UINib(nibName: userPhotoNameIdentifier, bundle: nil), forCellReuseIdentifier: userPhotoNameIdentifier)
        tableView.register(UINib(nibName: userSendMessageIdentifier, bundle: nil), forCellReuseIdentifier: userSendMessageIdentifier)
        tableView.register(UINib(nibName: userDescriptionIdentifier, bundle: nil), forCellReuseIdentifier: userDescriptionIdentifier)
        tableView.register(UINib(nibName: userActionContactCellIdentifier, bundle: nil), forCellReuseIdentifier: userActionContactCellIdentifier)
        tableView.register(UINib(nibName: userNotificationIdentifier, bundle: nil), forCellReuseIdentifier: userNotificationIdentifier)
        tableView.register(UINib(nibName: userBlockIdentifier, bundle: nil), forCellReuseIdentifier: userBlockIdentifier)
    }
    
    func setupUserRow() {
        
        structureArray.removeAll()
        structureArray.append(StructureRow(row: .avatarAndName, content: nil))
        structureArray.append(StructureRow(row: .sendMessage, content: nil))
        
        if let nick = self.user.getNickModel().get() {
            let userData = ContentType(type: .nick, data: nick as AnyObject)
            structureArray.append(StructureRow(row: .infoUser, content: userData))
        }
        
        let phoneData: [ACUserPhone] = user.getPhonesModel().get().toSwiftArray()
        for phone in phoneData {
            let userData = ContentType(type: .phone, data: phone)
            structureArray.append(StructureRow(row: .infoUser, content: userData))
        }
        
        let emailData: [ACUserEmail] = user.getEmailsModel().get().toSwiftArray()
        for email in emailData {
            let userData = ContentType(type: .email, data: email)
            structureArray.append(StructureRow(row: .infoUser, content: userData))
        }
        
        structureArray.append(StructureRow(row: .actionContact, content: nil))
        structureArray.append(StructureRow(row: .notification, content: nil))
        structureArray.append(StructureRow(row: .blockUser, content: nil))
    }
    
    //MARK:- TableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return structureArray.count 
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let element = structureArray[indexPath.row]
        
        // TODO: Create view models depending on cells content
        switch element.row {
        case .avatarAndName:
            let cell = tableView.dequeueReusableCell(withIdentifier: userPhotoNameIdentifier) as! UserPhotoNameCell
            cell.delegate = self
            cell.configureCellUser(user: user)
            return cell
        case .sendMessage:
            let cell = tableView.dequeueReusableCell(withIdentifier: userSendMessageIdentifier) as! UserSendMessageCell
            return cell
        case .infoUser:
            let cell = tableView.dequeueReusableCell(withIdentifier: userDescriptionIdentifier) as! UserDescriptionCell
            // TODO: Fix this
            // The table will reuse old data if the content is nil
            if let userData = element.content {
                cell.configDescriptionCell(type:userData.type, data:userData.data)
            }
            return cell
        case .actionContact:
            let cell = tableView.dequeueReusableCell(withIdentifier: userActionContactCellIdentifier) as! UserActionContactCell
            cell.configActionCell(isContactModel: isContactModelTmp)
            return cell
        case .notification:
            let cell = tableView.dequeueReusableCell(withIdentifier: userNotificationIdentifier) as! UserNotificationCell
            cell.configNotifCell(uid: uid)
            cell.delegate = self
            return cell
        case .blockUser:
            let cell = tableView.dequeueReusableCell(withIdentifier: userBlockIdentifier) as! UserBlockCell
            cell.configBlockCell(isBlocked: user.isBlockedModel().get().booleanValue())
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let element = structureArray[indexPath.row]
        
        switch element.row {
        case .sendMessage:
            if let customController = ActorSDK.sharedActor().delegate.actorControllerForConversation(ACPeer.user(with: uid)) {
                self.navigateDetail(customController)
            } else {
                self.navigateDetail(ConversationViewController(peer: ACPeer.user(with: uid)))
            }
        case .infoUser:
            guard let userData = element.content else {
                break
            }
            switch userData.type {
            case .phone:
                let phoneUser = userData.data as! ACUserPhone
                let phoneNumber = phoneUser.phone
                let hasPhone = UIApplication.shared.canOpenURL(URL(string: "telprompt://")!)
                if (hasPhone) {
                    ActorSDK.sharedActor().openUrl("telprompt://+\(phoneNumber)")
                } else {
                    UIPasteboard.general.string = "+\(phoneNumber)"
                    self.alertUser("NumberCopied")
                }
            case .email:
                let emailUser = userData.data as! ACUserEmail
                ActorSDK.sharedActor().openUrl("mailto:\(emailUser.email)")
            default:
                break
            }
            
        case .actionContact:
            if (self.isContactModelTmp) {
                let name = self.user.getNameModel().get().stringValue
                self.showAlert(title: (LocalizedStringConstants.contactsRemoveCommandTitle), message:"\(name) \(LocalizedStringConstants.contactsRemoveConfirmationText)", actionButtonTitle:LocalizedStringConstants.contactsRemoveCommand, cancelButtonTitle: LocalizedStringConstants.contactsCancel) { (_) in
                    self.executeContactCommand(command: Actor.removeContactCommand(withUid: self.uid))
                }
            } else {
                executeContactCommand(command: Actor.addContactCommand(withUid: uid))
            }
            
        case .blockUser:
            if user.isBlockedModel().get().booleanValue() {
                self.executePromise(Actor.unblockUser(uid),
                                    successBlock: { success in
                                        DispatchQueue.main.async(execute: {
                                            self.tableView.reloadData()
                                            self.delegate?.userTableViewControllerDidUnblockUser(self.user)
                                        })
                } ,failureBlock:nil)
            } else {
                let name = self.user.getNameModel().get().stringValue
                self.showAlert(title: "\(LocalizedStringConstants.contactsBlockCommand) \(name)", message: LocalizedStringConstants.contactsBlockConfirmationText, actionButtonTitle:LocalizedStringConstants.contactsBlockCommand, cancelButtonTitle: LocalizedStringConstants.contactsCancel) { (_) in
                    self.executePromise(Actor.blockUser(self.uid),
                                        successBlock: { success in
                                            DispatchQueue.main.async(execute: {
                                                self.tableView.reloadData()
                                                self.delegate?.userTableViewControllerDidBlockUser(self.user)
                                            })
                    } ,failureBlock:nil)
                }
            }

        default:
            break
        }
    }
    
    //MARK:- UserPhotoNameCellDelegate
    func avatarViewTap(_ cell: UserPhotoNameCell) {
        guard let avatar = self.user.getAvatarModel().get(), let fullImage = avatar.fullImage, let smallImage = avatar.smallImage else {
            return
        }
        let size = CGSize(width: Int(fullImage.width), height: Int(fullImage.height))
        let controller = AAPhotoPreviewController(file: fullImage.fileReference,
                                                  previewFile: smallImage.fileReference,
                                                  size: size,
                                                  fromView: cell.avatarView)
        self.present(controller, animated: true, completion: nil)
    }
    
    func audioCallStart(_ cell: UserPhotoNameCell) {
        if (ActorSDK.sharedActor().enableCalls && !self.isBot) {
            // Profile: Starting Voice Call
            self.execute(Actor.doCall(withUid: uid))
        }
    }
    
    func videoCallStart(_ cell: UserPhotoNameCell) {
        if (ActorSDK.sharedActor().enableVideoCalls && !self.isBot) {
            // Profile: Starting Video Call
            self.execute(Actor.doVideoCall(withUid: uid))
        }
    }
    
    //MARK:- UserNotificationCellDelegate
    func changeSwitch(_ cell: UserNotificationCell, isOn: Bool) {
        let peer = ACPeer.user(with: uid)
        
        if isOn || isBot {
            Actor.changeNotificationsEnabled(with: peer, withValue: isOn)
            return
        }
        self.confirmAlertUser("ProfileNotificationsWarring",
                              action: "ProfileNotificationsWarringAction",
                              tapYes: { () -> () in
                                Actor.changeNotificationsEnabled(with: peer, withValue: false)
        }, tapNo: { () -> () in
            self.tableView.reloadData()
        })
    }
    
    //MARK: -Private
    private func executeContactCommand(command: ACCommand?) {
        if let command = command {
            self.execute(command, successBlock: { [weak self] (success) in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.isContactModelTmp = !weakSelf.isContactModelTmp
                weakSelf.tableView.reloadData()
                }, failureBlock: nil)
        }
    }
}
