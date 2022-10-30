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
    private var socket = Managers.socketManager
    
    func login(userName: String, password: String) -> Observable<UserInfo> {
        return service.login(userName: userName, password: password)
    }
    
    func connectToSocket() {
        socket.connectToSocket()
    }
}
