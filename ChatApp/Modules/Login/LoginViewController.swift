//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 24/09/2022.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginBtn.layer.cornerRadius = 17
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    @IBAction func onClickLoginBtn(_ sender: UIButton) {
        let vc = HomeViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onClickSignUpBtn(_ sender: UIButton) {
        let vc = SignUpViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
