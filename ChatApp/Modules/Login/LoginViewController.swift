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
        phoneTextField.text = ""
        passwordTextField.text = ""
        loginBtn.layer.cornerRadius = 17
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    @IBAction func onClickLoginBtn(_ sender: UIButton) {
        guard let phone = phoneTextField.text,
              let password = passwordTextField.text else { return }
        
        viewModel.login(userName: phone, password: password).subscribe { user in
            let vc = HomeViewController()
            vc.name = user.user.name ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
        } onCompleted: { 
        }.disposed(by: viewModel.bag)

    }
    
    @IBAction func onClickSignUpBtn(_ sender: UIButton) {
        let vc = SignUpViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
