//
//  SignUpViewController.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 24/09/2022.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var passworfTextField: UITextField!
    
    @IBOutlet weak var nameTextField: UITextField!
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
        guard let phone = phoneTextField.text,
              let password = passworfTextField.text,
              let name = nameTextField.text,
              let confirmPass = confirmPasswordTextField.text
        else { return }
        if password == confirmPass {
            self.viewModel.register(phoneNumber: phone, password: password, name: name).subscribe { user in
                let vc = HomeViewController()
                vc.name = user.user.name ?? ""
                self.navigationController?.pushViewController(vc, animated: true)
            } onDisposed: {
            }.disposed(by: self.viewModel.bag)
        }
    }
}
