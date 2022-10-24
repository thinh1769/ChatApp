//
//  LoginViewModel.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 21/10/2022.
//

import Foundation
import Alamofire
import RxSwift

class LoginViewModel {
    private let service = AuthService()
    let bag = DisposeBag()
    func login(userName: String, password: String) -> Observable<UserResponse> {
        return service.login(userName: userName, password: password)
    }
}
