//
//  CreateGroupViewModel.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 31/10/2022.
//

import Foundation
import RxCocoa
import RxSwift

class CreateGroupViewModel {
    let bag = DisposeBag()
    private let chatService = ChatService()
    var selectedFriendsList = BehaviorRelay<[String]>(value: [])
    var searchFriendsList = BehaviorRelay<[UserInfo]>(value: [])
    private var socket = Managers.socketManager
    
    func searchFriend(_ nameOrPhoneNumber: String) -> Observable<[UserInfo]> {
        return chatService.searchFriend(nameOrPhoneNumber)
    }
    
    func removeSelectedFriend(index: Int) {
        var list = selectedFriendsList.value
        list.remove(at: index)
        selectedFriendsList.accept(list)
    }
    
    func checkSelectedFriend(_ userId: String) -> Bool {
        if selectedFriendsList.value.count == 0 { return false }
        for (_, element) in selectedFriendsList.value.enumerated() {
            if element == userId {
                return true
            }
        }
        return false
    }
    
    func postChat(users: [String], chatName: String) -> Observable<Chat> {
        return chatService.postChat(1, users, chatName)
    }
    
    func sendMessage(_ message: Message) {
        socket.sendMessage(message)
    }
}
