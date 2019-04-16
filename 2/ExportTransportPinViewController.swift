//
//  ExportTransportPinViewController.swift
//  eleven-actor
//
//  Created by Alexander Kovalov on 06.03.2018.
//

import UIKit

struct ConfirmPinConstants {
    static let nextSegue = "NextSegue"
}

class ExportTransportPinViewController: LocalizableViewController, UITextFieldDelegate, PinCodeValuesProtocol, WalletDependencyProtocol{
    
    fileprivate struct Constants {
        static let additionSpace: CGFloat = 10.0
    }
    
    @IBOutlet weak var transportPinLabel: UILabel!
    @IBOutlet weak var passwordsContainerView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmationTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var firstSeparator: UIView!
    @IBOutlet weak var secondSeparator: UIView!
    @IBOutlet weak var errorLabelFirst: UILabel!
    @IBOutlet weak var errorLabelSecond: UILabel!
    @IBOutlet weak var nextButtonBotConstraint: NSLayoutConstraint!
    
    var walletManager: WalletManagerProtocol!
    
    var pinCodeDelegate: PinCodeFlowDelegate!
    
    public var secretKey: SecretKey!
    
    var humanReadableKey: HumanReadableKey!
    
    var initialNextButtonBotConstraintValue: CGFloat!
    
    lazy var keyboardObserver = KeyboardObserver.init(block: { [unowned self] (rect) in
        let coversHeigth = self.statusBarHeight + self.navigationBarHeight + self.nextButton.frame.maxY - rect.minY
        let isOffsetRequred = coversHeigth > 0.0
        let requiredOffset =  coversHeigth + Constants.additionSpace
        self.nextButtonBotConstraint.constant = isOffsetRequred ? self.initialNextButtonBotConstraintValue + requiredOffset : self.initialNextButtonBotConstraintValue
    }) { [unowned self] in
        self.view.layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialNextButtonBotConstraintValue = nextButtonBotConstraint.constant
        assert(walletManager != nil, "WalletManager should be set")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardObserver.startObserving()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardObserver.stopObserving()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        passwordTextField.becomeFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? ExportQRCodeViewController else {
            return
        }
        controller.localizedPrivateKeyTitle = walletManager.exportWalletPrivateKeyTitle
        controller.localizedTitle = walletManager.exportWalletScanTitle
        controller.humanReadableKey = humanReadableKey
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: - Actions
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        guard passwordTextField.text == passwordConfirmationTextField.text else  {
            showError(message: pinCodeDelegate.errorMessageDoesntMatch)
            return
        }
        
        guard let humanReadable = HumanReadableKey(secretKey: secretKey, passphrase: passwordTextField.text, networkId: walletManager.networkId) else {
            showError(message: LocalizedStringConstants.transportPinSomethingWentWrong)
            return
        }
        humanReadableKey = humanReadable;       
        pinCodeDelegate.nextButtonPressed(from: self)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        clearError()
        return true;
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let length = textField.text?.length, length < HumanReadableKey.passphraseMinLength {
            showError(message: pinCodeDelegate.errorMessageLessThanFour, textField: textField)
        }
    }
    
    @IBAction func textFieldsEditingChanged(_ sender: UITextField) {
        guard let pinLength = passwordTextField.text?.length, let pinConfirmLength = passwordConfirmationTextField.text?.length else {
            nextButton.isEnabled = false
            return
        }
        nextButton.isEnabled = pinLength >= HumanReadableKey.passphraseMinLength && pinConfirmLength >= HumanReadableKey.passphraseMinLength
    }
    
    @IBAction func passwordTextFieldPrimaryActionTriggered(_ sender: UITextField) {
        passwordConfirmationTextField.becomeFirstResponder()
    }
    
    @IBAction func passwordConfirmationTextFieldPrimaryActionTriggered(_ sender: UITextField) {
        if nextButton.isEnabled {
            nextButtonPressed(sender)
            return
        }
        sender.resignFirstResponder()
    }
    
    // MARK: - PinCodeValuesProtocol
    
    var pinCodeSecretKey: SecretKey {
        get {
            return secretKey
        }
    }
    
    var pinCode: String? {
        get {
            return passwordTextField.text
        }
    }
    
    // MARK: - Localization
    
    override func localizeContent() {
        title = pinCodeDelegate.changePinCodeTitle
        transportPinLabel.attributedText = pinCodeDelegate.pinAttributedDescription
        passwordTextField.placeholder = pinCodeDelegate.pinPlaceholder
        passwordConfirmationTextField.placeholder = pinCodeDelegate.confirmPinPlaceholder
        nextButton.setTitle(pinCodeDelegate.nextButtonTitle, for: .normal)
    }
    
    // MARK: - Private methods
    
    private func showError(message: String, textField: UITextField? = nil) {
        var errorLabel : UILabel?
        if textField == nil || textField == passwordConfirmationTextField {
            errorLabel = errorLabelSecond
            errorLabelFirst.isHidden = true
        } else {
            errorLabel = errorLabelFirst
            errorLabelSecond.isHidden = true
        }
        
        firstSeparator.backgroundColor = .elevenErrorColor
        secondSeparator.backgroundColor = .elevenErrorColor
        errorLabel?.text = message
        errorLabel?.isHidden = false
    }
    
    private func clearError() {
        firstSeparator.backgroundColor = .elevenExportWalletSeparatorsColor
        secondSeparator.backgroundColor = .elevenExportWalletSeparatorsColor
        errorLabelFirst.isHidden = true
        errorLabelSecond.isHidden = true
    }
}
