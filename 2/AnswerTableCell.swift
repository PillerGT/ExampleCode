//
//  AnswerTableCell.swift
//  FitGrid
//
//  Created by Alexander Kovalov on 30.04.2018.
//  Copyright © 2018 YourGuru, Inc. All rights reserved.
//

import UIKit

private struct Constants {
    static let unselectedCellFont = UIFont.systemFont(ofSize: 17, weight: .regular)
    static let selectedCellFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
    static let imageVerticalOffset: CGFloat = -5
}

class AnswerTableCell: BaseTableViewCell {
    
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    
    func configure(viewModel: QuizAnswerViewModel, isSelected: Bool) {
        if let image = viewModel.image {
            configure(with: viewModel.answer, image: image)
        } else {
            guard viewModel.answerType != .other else { return }
            answerLabel.text = viewModel.answer
        }
        
        cellSelected(isSelected)
    }
    
    func configure(text: String, isSelected: Bool) {
        cellSelected(isSelected)
        answerLabel.text = text
    }
    
    func cellSelected(_ isSelected: Bool) {
        var image: UIImage!
        var font: UIFont!
        if isSelected {
            font = Constants.selectedCellFont
            image = Asset.circleCheck.image
            answerButton.addShadow(style: .bottom, color: ColorName.mainColor.color)
        } else {
            font = Constants.unselectedCellFont
            image = Asset.circleEmpty.image
            answerButton.layer.shadowOpacity = 0
        }
        answerLabel.font = font
        answerButton.setImage(image, for: .normal)
    }
    
    private func configure(with text: String?, image: UIImage) {
        
        let attributedText = NSMutableAttributedString(string: text ?? L10n.emptyString)
        
        attributedText.append(NSAttributedString(string: " "))
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image
        imageAttachment.bounds = CGRect(x: 0, y: Constants.imageVerticalOffset, width: image.size.width, height: image.size.height)
        attributedText.append(NSAttributedString(attachment: imageAttachment))
        
        answerLabel.attributedText = attributedText
    }
}
