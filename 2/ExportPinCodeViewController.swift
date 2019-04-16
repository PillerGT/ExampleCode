//
//  ExportPinCodeViewController.swift
//  eleven-actor
//
//  Created by Alexander Kovalov on 06.03.2018.
//

import UIKit

class ExportPinCodeViewController: LocalizableViewController, UITextFieldDelegate {
    private struct Constants {
        static let nextSegue = "NextSegue"
        static let showError = true
        static let hideError = false
        static let additionSpace: CGFloat = 10
    }

    var walletManager: WalletManagerProtocol!
    
    private var secretKey: SecretKey!
    
    var pinCodeDelegate: PinCodeFlowDelegate!
    
    @IBOutlet weak var pinCodeContainerView: UIView!
    @IBOutlet weak var pinCodeLabel: UILabel!
    @IBOutlet weak var pinCodeTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pinCodeLabelBackground: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var nextButtonTopConstraint: NSLayoutConstraint!
    
    var initialTopConstraintValue: CGFloat!
    
    lazy var keyboardObserver = KeyboardObserver.init(block: { [unowned self] (rect) in
        let requiredOffset = self.statusBarHeight + self.navigationBarHeight + self.nextButton.frame.maxY - rect.minY + Constants.additionSpace
        self.nextButtonTopConstraint.constant = requiredOffset > 0.0 ? self.initialTopConstraintValue - requiredOffset : self.initialTopConstraintValue
    }) { [unowned self] in
        self.view.layoutIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialTopConstraintValue = nextButtonTopConstraint.constant
        assert(walletManager != nil, "WalletManager should be set")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardObserver.startObserving()
    }
    
    override func viewDidAppear(_ animated: Bool) {
       super.viewDidAppear(animated)
        pinCodeTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardObserver.stopObserving()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard (sender as? UIButton == nextButton) || (sender as? UITextField == pinCodeTextField) else {
            return true
        }
        return prepareSecret()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? ExportTransportPinViewController else {
            return
        }
        controller.walletManager = walletManager
        controller.pinCodeDelegate = pinCodeDelegate
        controller.secretKey = secretKey
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        pinCodeTextField.resignFirstResponder()
    }
    
    // MARK: - Private
    
    private func prepareSecret() -> Bool {
        guard let humanReadableKey = walletManager.humanReadableKey, let secretKey = SecretKey(humanReadableKey: humanReadableKey, passphrase: pinCodeTextField.text) else {
            processError( state: Constants.showError )
            return false
        }
        self.secretKey = secretKey
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func pinCodeTextFieldEditingChanged(_ sender: UITextField) {
        guard let text = sender.text else {
            nextButton.isEnabled = false
            return
        }
        nextButton.isEnabled = text.length >= HumanReadableKey.passphraseMinLength
    }
    
    @IBAction func pinCodeTextFieldPrimaryActionTriggered(_ sender: UITextField) {
        if prepareSecret() {
            performSegue(withIdentifier: Constants.nextSegue, sender: sender)
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        processError( state: Constants.hideError )
        return true;
    }
    
    // MARK: - Localization
    
    override func localizeContent() {
        title = pinCodeDelegate.currentPinCodeTitle
        pinCodeLabel.text = LocalizedStringConstants.exportWalletCurrentPin
        pinCodeTextField.placeholder = LocalizedStringConstants.exportWalletEnterPin
        nextButton.setTitle(LocalizedStringConstants.exportWalletNextButton, for: .normal)
    }
    
     // MARK: - Private methods
    
    private func processError( state: Bool ) {
        pinCodeLabelBackground.backgroundColor = state ? .elevenErrorColor : .elevenCreateWalletSeparatorsColor
        errorLabel.isHidden = !state;
    }
}
