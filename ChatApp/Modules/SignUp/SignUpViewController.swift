//
//  SignUpViewController.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 24/09/2022.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var signUpBtn: UIButton!
    
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
        let vc = HomeViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
