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
    
    func sortChat(_ chats: [Chat]) -> [Chat] {
        return chats.sorted(by: {
            if self.convertDate($0.lastMessage?.createdAt ?? "").compare(self.convertDate($1.lastMessage?.createdAt ?? "")) == .orderedDescending {
                return true
            } else { return false }
        })
    }
    
    func convertDate(_ dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        guard let date = dateFormatter.date(from: dateString) else { return Date() }
        return date
    }
    
    func receiveMessage(completion: @escaping(Message) -> Void) {
        socket.receiveMessages { message in
            completion(message)
        }
    }
    
    func receiveCreateChat(completion: @escaping(Chat) -> Void) {
        socket.receiveCreateChat { chat in
            completion(chat)
        }
    }
    
    func updateChatWhenReceiveNewMessage(_ message: Message) -> [Chat] {
        var listChat = chats.value
        for (index, element) in listChat.enumerated() {
            if element.id == message.chatId {
                listChat[index].lastMessage = Message(type: message.type, content: message.content, recall: message.recall, createdAt: message.createdAt, sender: message.sender)
            }
        }
        return listChat
    }
    
    func updateChatWhenReceiveNewChat(_ chat: Chat) -> Chat {
        var convertChat = chat
        convertChat.receiver?.id = chat.lastMessage?.sender?.id
        convertChat.receiver?.name = chat.lastMessage?.sender?.name
        return convertChat
    }
    
    func logout() {
        UserDefaults.userInfo = nil
        self.socket.closeConnection()
        authService.logOut().subscribe { _ in
        } onError: { _ in
        }.disposed(by: bag)
    }
}
