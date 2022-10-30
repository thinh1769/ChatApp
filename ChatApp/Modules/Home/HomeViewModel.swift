//
//  HomeViewModel.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 21/10/2022.
//

import Foundation
import RxCocoa
import RxSwift

class HomeViewModel {
    let bag = DisposeBag()
    private let chatService = ChatService()
    private let authService = AuthService()
    var chats = BehaviorRelay<[Chat]>(value: [])
    var searchFriendsList = BehaviorRelay<[UserInfo]>(value: [])
    var typeTable = 0
    private var socket = Managers.socketManager
    
    func getAllChats() -> Observable<[Chat]>{
        return chatService.getAllChats()
    }
    
    func searchFriend(_ nameOrPhoneNumber: String) -> Observable<[UserInfo]> {
        return chatService.searchFriend(nameOrPhoneNumber)
    }
    
    func logout() {
        UserDefaults.userInfo = nil
        self.socket.closeConnection()
        authService.logOut().subscribe { _ in
        } onError: { _ in
        }.disposed(by: bag)
    }
}
