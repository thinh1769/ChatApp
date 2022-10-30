//
//  ChatService.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 24/10/2022.
//

import Foundation
import Alamofire
import RxSwift

class ChatService: BaseService {
    
    func getAllChats() -> Observable<[Chat]> {
        return request(api: ApiConstants.getAllChats)
    }
    
    func getAllMessages(_ chatId: String) -> Observable<[Message]> {
        return request(api: ApiConstants.getAllMessages.rawValue + chatId, method: .get)
    }
    
    func getChatByUserId(_ userId: String) -> Observable<Chat> {
        return request(api: ApiConstants.getChatByUserId.rawValue + userId, method: .get)
    }
    
    func searchFriend(_ nameOrPhoneNumber: String) -> Observable<[UserInfo]> {
        return request(api: ApiConstants.searchFriends.rawValue + nameOrPhoneNumber, method: .get)
    }
    
    func postChat(_ userId: String) -> Observable<Chat> {
        let users = [userId]
        let params = ["type" : 0, "users": users] as [String : Any]
        return request(api: ApiConstants.getAllChats.rawValue, method: .post, params: params)
    }
}
