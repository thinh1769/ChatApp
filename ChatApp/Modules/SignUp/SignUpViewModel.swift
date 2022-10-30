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
    private var socket = Managers.socketManager
    
    func register(phoneNumber: String, password: String, name: String) -> Observable<UserInfo> {
        let user = UserInfo(phoneNumber: phoneNumber, password: password, name: name)
        return service.register(user: user)
    }
    
    func connectToSocket() {
        socket.connectToSocket()
    }
}
