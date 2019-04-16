//
//  AnswerHeaderView.swift
//  FitGrid
//
//  Created by Alexander Kovalov on 30.04.2018.
//  Copyright © 2018 YourGuru, Inc. All rights reserved.
//

import UIKit

class AnswerHeaderView: BaseTableViewHeaderFooterView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func configure(question: QuizQuiestionViewModel) {
        titleLabel.text = question.title
        subTitleLabel.text = question.subtitle
        descriptionLabel.text = question.questionDescription
    }
}
