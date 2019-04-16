//
//  UserInfoViewController.swift
//  eleven-actor
//
//  Created by Alexander Kovalov on 23.02.2018.
//

import UIKit
import ActorSDK

class UserViewController: AAViewController {

    lazy var tableViewController: UserTableViewController = {
        let controller = UIStoryboard.user.instantiateInitialViewController() as! UserTableViewController
        controller.user = user
        return controller
    }()
    
    lazy var tableUpdateBlock: (( ) -> Void) =  { [weak self] in
        self?.tableViewController.tableView.reloadData()
    }
    
    init(userId: Int) {
        super.init(nibName: nil, bundle: nil)
        uid = userId
        title = AALocalized("ProfileTitle")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AALocalized("Edit"), style: .done, target: self, action: #selector(actionEditButton))
    }
    
    convenience init(userId: Int, delegate: UserTableViewControllerProtocol?) {
        self.init(userId: userId)
        self.tableViewController.delegate = delegate
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildViewController(tableViewController)
        view.addSubview(tableViewController.view)
        tableViewController.didMove(toParentViewController: self)
    }
    
    // MARK: - Actions
    @objc func actionEditButton() {
        guard let editNameController = EditContactNameViewController.load(with: self.user, tableUpdateBlock: tableUpdateBlock) else {
            return
        }
        navigateDetail(editNameController)
    }
}
