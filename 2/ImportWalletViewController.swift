//
//  ImportWalletViewController.swift
//  eleven-actor
//
//  Created by Alexander Kovalov on 12.03.2018.
//

import Foundation
import UIKit
import QRCodeReader
import AVFoundation

fileprivate struct ImportWalletConstants {
    static let walletAddressCharactersCount = 64
    static let fieldCharsCapacity = 4
    static let charatersSetString = "ACDEFHIJKLMNPQRTUVWXYacdefghjklmnpqrstuvwxy3479"
}

class ImportWalletViewController: LocalizableViewController, UITextFieldDelegate, QRCodeReaderViewControllerDelegate, PasswordTextFieldDelegate {

    @IBOutlet weak var scanQRButton: UIButton!
    @IBOutlet var textFields: [PasswordTextField]!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var qrCodeLabel: UILabel!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    @IBOutlet weak var contentViewTopConstraint: NSLayoutConstraint!
    
    var humanReadableKeyEntered: ((_ humanReadableKey: HumanReadableKey) -> Void)?
    
    var walletManager: WalletManagerProtocol!
    
    var keyboardObserver : KeyboardObserver!
    var activeTextField: PasswordTextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        assert(walletManager != nil, "WalletManager should be set")
        _ = self.textFields.map{ $0.deleteDelegate = self }
        
        keyboardObserver = KeyboardObserver.init(block: { [unowned self] (rect) in
            var frame = rect
            frame.origin.y = frame.origin.y - 64
            let coveredFrame = self.stackView.frame.intersection(frame)
            self.contentViewTopConstraint.constant =  coveredFrame.size.height > 0.0 ? self.contentViewTopConstraint.constant - coveredFrame.size.height : 30;
        }) { [unowned self] in
            self.view.layoutIfNeeded()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardObserver.startObserving()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        keyboardObserver.stopObserving()
    }

    @IBAction func scanQRButtonAction(_ sender: UIButton) {
        let qrVC = QRCodeReaderViewController(delegate: self, completionBlock: nil)
        present(qrVC, animated: true, completion: nil)
    }
        
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard nextButton === sender as? UIBarButtonItem else {
            return false
        }
        
        if let humanReadableKeyEntered = humanReadableKeyEntered {
            humanReadableKeyEntered(HumanReadableKey(rawValue: textFields.finalString, networkId: walletManager.networkId))
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? EnterTransportPinViewController {
            controller.walletManager = walletManager
            controller.humanReadableKey = HumanReadableKey(rawValue: textFields.finalString, networkId: walletManager.networkId)
        }
    }
    
    // MARK: - Private methods
    
    func allFilled() -> Bool {
        for textField in textFields {
            if let text = textField.text, text.length < ImportWalletConstants.fieldCharsCapacity {
                return false
            }
        }
        return true
    }
    
    func textFieldIndex(textField: PasswordTextField) -> NSInteger {
        guard let textFieldIndex = textFields.index(of: textField) else {
            return 0
        }
        return textFieldIndex
    }
    
    func hexTextFieldAfter(textField: PasswordTextField) -> UITextField? {
        let nextIndex = textFieldIndex(textField: textField) + 1
        if nextIndex == textFields.count {
            return nil
        }
        return textFields[nextIndex]
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textField = textField as? PasswordTextField else {
            return true
        }
        
        let numbersOnly = CharacterSet(charactersIn: ImportWalletConstants.charatersSetString)
        let characterSetFromTextField = CharacterSet(charactersIn: string)
        
        if let textFieldText = textField.text, textFieldText.length >= ImportWalletConstants.fieldCharsCapacity {
            if string == "" && range.location <= ImportWalletConstants.fieldCharsCapacity {
                return true
            }
            
            if textFieldIndex(textField: textField) == textFields.count - 1 {
                textField.resignFirstResponder()
                nextButton?.isEnabled = allFilled()
                return false
            }
            
            if allFilled() {
                nextButton?.isEnabled = true
                textField.resignFirstResponder()
                return false
            }
            
            let newField = hexTextFieldAfter(textField: textField)
            if let field = newField, numbersOnly.isSuperset(of: characterSetFromTextField) {
                field.becomeFirstResponder()
                field.text = string.uppercased()
            }
            return false
        }
        
        var lowercaseCharRange = string.rangeOfCharacter(from: CharacterSet.lowercaseLetters)
        lowercaseCharRange = lowercaseCharRange ?? string.rangeOfCharacter(from: CharacterSet.decimalDigits)
        let stringIsValid = numbersOnly.isSuperset(of: characterSetFromTextField)
        
        if let lowercaseRange = lowercaseCharRange, !lowercaseRange.isEmpty, stringIsValid {
            let textFieldString = textField.text as NSString?
            textField.text = textFieldString?.replacingCharacters(in: range, with: string.uppercased())
            nextButton?.isEnabled = allFilled()
            return false
        }
        
        return stringIsValid
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let textField = textField as? PasswordTextField else {
            return true
        }
        
        let nextTextField = hexTextFieldAfter(textField: textField)
        if let nextField = nextTextField {
            nextField.becomeFirstResponder()
        } else {
            view.endEditing(true)
            nextButton?.isEnabled = allFilled()
        }
        return true
    }
    
    
    // MARK: - QRCodeReaderViewControllerDelegate
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        reader.dismiss(animated: true, completion: {
            if result.value.length != ImportWalletConstants.walletAddressCharactersCount { return }
            
            var blockCounter = 0
            for i in 0 ..< self.textFields.count {
                let resultString = result.value as NSString
                self.textFields[i].text = resultString.substring(with: NSRange(location: blockCounter, length: ImportWalletConstants.fieldCharsCapacity))
                blockCounter += ImportWalletConstants.fieldCharsCapacity
            }
            self.nextButton?.isEnabled = self.allFilled()
        })
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - PasswordTextFieldDelegate
    
    func textFieldDidDelete(textField: PasswordTextField) {
        if textFieldIndex(textField: textField) != 0 && textField.text?.count == 0 {
            activeTextField = textFields[textFieldIndex(textField: textField) - 1]
            activeTextField?.becomeFirstResponder()
        }else {
            self.nextButton?.isEnabled = false
        }
    }
    
    // MARK: - Localization
    
    override func localizeContent() {
        self.title = LocalizedStringConstants.importWalletControllerTitle
        titleLabel.text = LocalizedStringConstants.enterPrivateKeyLabelText.replace("{currency}", dest: walletManager.cryptoCurrency.symbol())
        qrCodeLabel.text = LocalizedStringConstants.qrCodeLabelText
        nextButton.title = LocalizedStringConstants.nextButtonTitle
        scanQRButton.setTitle(LocalizedStringConstants.scanQRButtonTitle, for: .normal)
    }
    
    // MARK: - Private
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}

extension Array where Element: PasswordTextField {

    var finalString: String {
        let components = self.compactMap { $0.text }
        return components.joined(separator: "-")
    }

}
