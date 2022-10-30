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
    static func getAuthInfo(response: KeyAuth) -> String {
        return UserDefaults.getInfo(key: response) ?? ""
    }
    static func setAuthInfo(info: KeyAuth, value: String) {
        UserDefaults.setInfo(key: info, value: value)
    }
    
    static func isLoggedIn() -> Bool {
        return getAuthInfo(response: KeyAuth.token) != ""
    }
    
    func login(userName: String, password: String) -> Observable<UserInfo> {
        let params = ["phoneNumber" : userName, "password": password]
        return createRequest(api: ApiConstants.login, method: .post, parameters: params)
    }
    
    func register(user: UserInfo) -> Observable<UserInfo> {
        return createRequest(api: ApiConstants.register, method: .post, parameters: user)
    }
    
    func logOut() -> Observable<String> {
        return request(api: .logout)
    }
    
//    func saveLogin(userResponse: UserResponse) -> UserResponse {
//        UserDefaults.userResponse = userResponse
//        return userResponse
//    }
}

