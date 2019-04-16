//
//  AnswerButtonTableCell.swift
//  FitGrid
//
//  Created by Alexander Kovalov on 02.05.2018.
//  Copyright © 2018 YourGuru, Inc. All rights reserved.
//

import UIKit

protocol AnswerButtonTableCellDelegate: class {
    func chosenAnswer(oldAnswer: QuizAnswerViewModel?, newAnswer: QuizAnswerViewModel)
}

class AnswerButtonTableCell: BaseTableViewCell {
    
    weak var delegate: AnswerButtonTableCellDelegate?
    
    @IBOutlet weak var firstButton: QuizRoundedButton!
    @IBOutlet weak var secondButton: QuizRoundedButton!
    var answers: (firstAnswer: QuizAnswerViewModel, secondAnswer: QuizAnswerViewModel)!
    
    func configure(firstAnswer: QuizAnswerViewModel, secondAnswer: QuizAnswerViewModel, isSelectedFirstAnswer: Bool = false, isSelectedSecondAnswer: Bool = false) {
        configButton(button: firstButton, answer: firstAnswer.answer, isSelectedAnswer: isSelectedFirstAnswer)
        configButton(button: secondButton, answer: secondAnswer.answer, isSelectedAnswer: isSelectedSecondAnswer)
        answers = (firstAnswer: firstAnswer, secondAnswer: secondAnswer)
    }
    
    func configButton(button: QuizRoundedButton, answer: String?, isSelectedAnswer: Bool) {
        button.setButtonActive(isActive: isSelectedAnswer)
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        button.setTitle(answer, for: .normal)
    }
    
    @IBAction func choiceButtonAction(_ sender: QuizRoundedButton) {
        if sender == firstButton {
            firstButton.setButtonActive(isActive: true)
            secondButton.setButtonActive(isActive: false)
            delegate?.chosenAnswer(oldAnswer: answers.secondAnswer, newAnswer: answers.firstAnswer)
        } else {
            firstButton.setButtonActive(isActive: false)
            secondButton.setButtonActive(isActive: true)
            delegate?.chosenAnswer(oldAnswer: answers.firstAnswer, newAnswer: answers.secondAnswer)
        }
    }
}
