//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 24/09/2022.
//

import UIKit
import RxSwift

class LoginViewController: UIViewController {

    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var viewModel = LoginViewModel()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneTextField.text = "11111"
        passwordTextField.text = "11111"
        loginBtn.layer.cornerRadius = 17
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    @IBAction func onClickLoginBtn(_ sender: UIButton) {
        guard let phone = phoneTextField.text, phone.isMatches(RegexConstants.PHONE_NUMBER),
              let password = passwordTextField.text, password.isMatches(RegexConstants.PASSWORD)
        else {
            showAlert(DefaultConstants.registerInformation)
            return
        }
        viewModel.login(userName: phone, password: password).subscribe { [weak self] user in
            guard let self = self else { return }
            UserDefaults.userInfo = user
            self.viewModel.connectToSocket()
            let vc = HomeViewController()
            vc.name = user.name ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        } onError: { error in
            self.showAlert(DefaultConstants.loginFailed)
            print("------------------------ error = \(error.localizedDescription)")
        }.disposed(by: viewModel.bag)

    }
    
    @IBAction func onClickSignUpBtn(_ sender: UIButton) {
        let vc = SignUpViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: DefaultConstants.alertTitle, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: DefaultConstants.ok, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
