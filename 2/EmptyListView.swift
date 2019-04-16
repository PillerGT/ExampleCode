//
//  TransactionEmptyListView.swift
//  eleven-actor
//
//  Created by Alexander Kovalov on 23.03.2018.
//

import UIKit

protocol EmptyDataSourceProtocol {
    var emptyTitle: String {get}
    var emptyDetails: String {get}
    var emptyImage: UIImage? {get}
}

class EmptyListView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var emptyListIcon: UIImageView!
    
    class func loadFromNib(with dataSource: EmptyDataSourceProtocol) -> EmptyListView {
        let transactionEmptyListView = String(describing: EmptyListView.self)
        
        let emptyView: EmptyListView = Bundle.main.loadNibNamed( transactionEmptyListView, owner: self, options: nil)?.first as! EmptyListView
        
        emptyView.emptyListIcon.image = dataSource.emptyImage
        emptyView.titleLabel.text = dataSource.emptyTitle
        emptyView.textLabel.text = dataSource.emptyDetails
 
        return emptyView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.textColor = UIColor.elevenEmptyListTextColor
        textLabel.textColor = UIColor.elevenEmptyListTextColor
    }
}
