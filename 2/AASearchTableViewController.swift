//
//  AASearchTableViewController.swift
//  ActorSDK
//
//  Created by Alexander Kovalov on 06.03.2018.
//  Copyright © 2018 Steve Kite. All rights reserved.
//

import UIKit

class AASearchTableViewController<BindCell>: UITableViewController where BindCell: AABindedSearchCell, BindCell: UITableViewCell {
    
    let config: AAManagedSearchConfig<BindCell>
    let searchList: ARBindedDisplayList?
    let searchModel: ARSearchValueModel?
    
    lazy var noResultsLabel: UILabel = {
        let label: UILabel  = UILabel()
        label.text = AALocalized("FindNoResults")
        label.numberOfLines = 0
        label.textColor = .darkText
        label.textAlignment = .center
        return label
    }()
    
    init(config: AAManagedSearchConfig<BindCell>) {
        self.config = config
        self.searchList = config.searchList
        self.searchModel = config.searchModel
        super.init(style: .plain)
        extendedLayoutIncludesOpaqueBars = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = ActorSDK.sharedActor().style.vcBgColor
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        noResultsLabel.frame = view.bounds
    }

    //Support function
    
    func showNoResult(count: Int) -> Int {
        if count == 0 {
            tableView.backgroundView = noResultsLabel
            return count
        }
        tableView.backgroundView = UIView()
        return count
    }
    
    // Model
    
    func objectAtIndexPath(_ indexPath: IndexPath) -> BindCell.BindData {
        if let ds = searchList {
            return ds.item(with: jint((indexPath as NSIndexPath).row)) as! BindCell.BindData
        } else if let sm = searchModel {
            let list = sm.getResults().get() as! JavaUtilList
            return list.getWith(jint((indexPath as NSIndexPath).row)) as! BindCell.BindData
        } else {
            fatalError("No search model or search list is set!")
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let ds = searchList {
            return showNoResult(count: Int(ds.size()))
        } else if let sm = searchModel {
            let list = sm.getResults().get() as! JavaUtilList
            return showNoResult(count: Int(list.size()))
        } else {
            fatalError("No search model or search list is set!")
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = objectAtIndexPath(indexPath)
        return BindCell.self.bindedCellHeight(item)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = objectAtIndexPath(indexPath)
        let cell = tableView.dequeueCell(BindCell.self, indexPath: indexPath) as! BindCell
        cell.bind(item, search: nil)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = objectAtIndexPath(indexPath)
        config.selectAction!(item)
    }
}
