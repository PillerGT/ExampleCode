//
//  QuizNextView.swift
//  FitGrid
//
//  Created by Alexander Kovalov on 30.04.2018.
//  Copyright © 2018 YourGuru, Inc. All rights reserved.
//

import UIKit

protocol QuizNextViewDelegate: class {
    func nextTapButton()
}

class QuizNextView: LocalizableView {

    weak var delegate: QuizNextViewDelegate?
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var nextButton: RoundedButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()
        localizeContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        delegate?.nextTapButton()
    }
    
    override func localizeContent() {
        nextButton.setTitle(L10n.next.uppercased(), for: .normal)
    }
}
