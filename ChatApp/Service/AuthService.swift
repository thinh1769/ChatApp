//
//  AuthService.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 21/10/2022.
//

import Foundation
import Alamofire
import RxSwift
import Security

class AuthService: BaseService {
    static func getAuthInfo(info: KeyAuth) -> String {
        return UserDefaults.getInfo(key: info) ?? ""
    }
    static func setAuthInfo(info: KeyAuth, value: String) {
        UserDefaults.setInfo(key: info, value: value)
    }
    
    static func isLoggedIn() -> Bool {
        return getAuthInfo(info: KeyAuth.token) != ""
    }
    
    func login(userName: String, password: String) -> Observable<UserResponse> {
        let params = ["phoneNumber" : userName, "password": password]
        return createRequest(api: ApiConstants.login, method: .post, parameters: params)
    }
    
    func register(user: UserInfo) -> Observable<UserResponse> {
        return createRequest(api: ApiConstants.register, method: .post, parameters: user)
    }
    
    func logOut() -> Observable<String> {
        return request(api: .logout)
    }
}

