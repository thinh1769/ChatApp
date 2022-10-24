//
//  SignUpViewModel.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 22/10/2022.
//

import Foundation
import RxSwift
import RxRelay

class SignUpViewModel {
    let service = AuthService()
    var user = UserInfo()
    let bag = DisposeBag()
    
    func register(phoneNumber: String, password: String, name: String) -> Observable<UserResponse> {
        let user = UserInfo(phoneNumber: phoneNumber, password: password, name: name, status: true)
        return service.register(user: user)
    }
}
