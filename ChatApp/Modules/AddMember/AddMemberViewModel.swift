//
//  AddMemberViewModel.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh 06/11/2022.
//

import Foundation
import RxCocoa
import RxSwift

class AddMemberViewModel {
    let bag = DisposeBag()
    private let chatService = ChatService()
    var selectedFriendsList = BehaviorRelay<[String]>(value: [])
    var searchFriendsList = BehaviorRelay<[UserInfo]>(value: [])
    private var socket = Managers.socketManager
    var listMember = BehaviorRelay<[UserInfo]>(value: [])
    var usersId = [String]()
    var chatId = ""
    var chatName = ""
    
    func searchFriend(_ nameOrPhoneNumber: String) -> Observable<[UserInfo]> {
        return chatService.searchFriend(nameOrPhoneNumber)
    }
    
    func removeSelectedFriend(index: Int) {
        var list = selectedFriendsList.value
        list.remove(at: index)
        selectedFriendsList.accept(list)
    }
    
    func checkSelectedFriend(_ userId: String) -> Bool {
        if selectedFriendsList.value.count > 0 {
            for (_, element) in selectedFriendsList.value.enumerated() {
                if element == userId {
                    return true
                }
            }
        }
        
        for (_, element) in listMember.value.enumerated() {
            if element.id == userId {
                return true
            }
        }
        return false
    }
    
    ///------SocketIO
    func addMember(_ chatId: String, usersId: [String]) {
        socket.addMember(chatId, usersId: usersId)
    }
}
