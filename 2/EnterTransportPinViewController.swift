//
//  EnterTransportPinViewController.swift
//  eleven-actor
//
//  Created by Alexander Kovalov on 12.03.2018.
//

import UIKit

class EnterTransportPinViewController: LocalizableViewController, UITextFieldDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pinTextField: UITextField!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var importButton: GradientButton!
    @IBOutlet weak var contentPinPassView: UIView!
    
    var importDidComplite: (() -> Void)?
    
    var humanReadableKey : HumanReadableKey!
    
    var walletManager: WalletManagerProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(walletManager != nil, "WalletManager should be set")
        pinTextField.becomeFirstResponder()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let secret = SecretKey(humanReadableKey: humanReadableKey, passphrase: pinTextField.text!) else {
            pinTextField.text = nil
            contentPinPassView.shake()
            return false
        }
        walletManager.importWalletWithSecretKey(secret)
        walletManager.setHumanReadableKey(humanReadableKey)
        if let importDidComplite = importDidComplite {
            importDidComplite()
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? WalletViewController {
            controller.walletManager = walletManager
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        guard let pinPass = pinTextField.text else {
            return
        }
        importButton.isEnabled = pinPass.count > 0
    }
    
    // MARK: - Private
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: - Localization
    
    override func localizeContent() {
        title = LocalizedStringConstants.importTransportPinTitle
        titleLabel.text = LocalizedStringConstants.importTransportPinHeaderText
        pinTextField.placeholder = LocalizedStringConstants.importTransportPinPlaceholder
        alertLabel.text = LocalizedStringConstants.importTransportPinAlertText
        importButton.setTitle(LocalizedStringConstants.importButtonTitle.uppercased(), for: .normal)
    }
}
