//
//  UserService.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 06/11/2022.
//

import Foundation
import Alamofire
import RxSwift

class UserService: BaseService {
    func getUserByChatId(_ chatId: String) -> Observable<[UserInfo]> {
        return request(api: ApiConstants.getUserByChatId.rawValue + chatId, method: .get)
    }
    
    func updateUserInfo() -> Observable<UserInfo> {
        return request(api: ApiConstants.updateUserInfo.rawValue + (UserDefaults.userInfo?.id ?? ""), method: .put)
    }
}
