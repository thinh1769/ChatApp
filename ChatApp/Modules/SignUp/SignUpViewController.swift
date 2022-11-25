//
//  SignUpViewController.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 24/09/2022.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet private weak var signUpBtn: UIButton!
    @IBOutlet private weak var phoneTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    @IBOutlet private weak var passworfTextField: UITextField!
    @IBOutlet private weak var nameTextField: UITextField!
    
    var viewModel = SignUpViewModel()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpBtn.layer.cornerRadius = 17
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }

    @IBAction func onClickSignUpBtn(_ sender: UIButton) {
        guard let phone = phoneTextField.text, phone.isMatches(RegexConstants.PHONE_NUMBER),
              let password = passworfTextField.text, password.isMatches(RegexConstants.PASSWORD),
              let name = nameTextField.text,
              let confirmPass = confirmPasswordTextField.text
        else {
            showAlert(DefaultConstants.registerInformation)
            return
        }
        if password == confirmPass {
            self.viewModel.register(phoneNumber: phone, password: password, name: name).subscribe { user in
                UserDefaults.userInfo = user
                self.viewModel.connectToSocket()
                let vc = HomeViewController()
                vc.name = user.name ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            } onDisposed: {
            }.disposed(by: self.viewModel.bag)
        } else {
            showAlert(DefaultConstants.wrongConfirmPassword)
        }
    }
    @IBAction func onClickedSignInBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: DefaultConstants.alertTitle, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: DefaultConstants.ok, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
