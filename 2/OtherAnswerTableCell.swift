//
//  OtherAnswerTableCell.swift
//  FitGrid
//
//  Created by Alexander Kovalov on 30.04.2018.
//  Copyright © 2018 YourGuru, Inc. All rights reserved.
//

import UIKit

private struct Constants {
    static let minCharacter = 1
    static let maxCharacter = 100
    static let widthConstaraint: CGFloat = 32
    static let heightWithoutTextview: CGFloat = 85
}

protocol OtherAnswerTableCellDelegate: class {
    func didChangeOtherAnswer(_ text: String?)
    func textViewDidChange(_ properLength: Bool)
    func didBecomeActive()
}

class OtherAnswerTableCell: AnswerTableCell, UITextViewDelegate {

    @IBOutlet weak var otherTextView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    weak var delegate: OtherAnswerTableCellDelegate?
    
    // MARK: - UITextViewDelegate
    
    func configureWith(placeholder: String, isSelected: Bool, answer: QuizAnswerViewModel?) {
        if isSelected {
            otherTextView.text = answer?.answer ?? L10n.emptyString
            placeholderLabel.isHidden = otherTextView.text.isEmpty ? false : true
        }
        placeholderLabel.text = placeholder
        cellSelected(isSelected)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.didBecomeActive()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        let properLength = textView.text.count >= Constants.minCharacter
        cellSelected(properLength)
        delegate?.textViewDidChange(properLength)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        if textView.text.count < Constants.minCharacter {
            textView.textColor = ColorName.cellPlaceholderTextColor.color
            delegate?.didChangeOtherAnswer(nil)
        } else {
            delegate?.didChangeOtherAnswer(textView.text)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        if text == " ", textView.text.isEmpty {
            return false
        }
        
        if range.location <= Constants.maxCharacter {
            return true
        }
        return false
    }
    
    override func localizeContent() {
        answerLabel.text = L10n.Quizanswer.other
    }
}
