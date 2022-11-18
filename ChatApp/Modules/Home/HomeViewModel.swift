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
    private var socket = Managers.socketManager
    var typeTable = 0
    var adminId = ""
    
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
    
    func updateAdmin(chatId: String, adminId: String) {
        var listChat = chats.value
        for (index, element) in listChat.enumerated() {
            if element.id == chatId {
                listChat[index].createBy = adminId
                chats.accept(listChat)
                return
            }
        }
    }
    
    func receiveMessage(completion: @escaping(Message) -> Void) {
        socket.receiveMessages { message, newAdminId in
            if let newAdminId = newAdminId {
                self.updateAdmin(chatId: message.chatId ?? "", adminId: newAdminId)
            }
            completion(message)
        }
    }
    
    func receiveCreateChat(completion: @escaping(Chat) -> Void) {
        socket.receiveCreateChat { chat in
            completion(chat)
        }
    }
    
    func receiveLeaveChat(completion: @escaping(String) -> Void) {
        socket.receiveLeaveGroup { chatId in
            completion(chatId)
        }
    }
    
    func removeChat(_ chatId: String) {
        var listChat = chats.value
        for (index, element) in listChat.enumerated() {
            if element.id == chatId {
                listChat.remove(at: index)
                chats.accept(listChat)
                return
            }
        }
    }
    
    func updateChatWhenReceiveNewMessage(_ message: Message) -> [Chat] {
        var listChat = chats.value
        for (index, element) in listChat.enumerated() {
            if element.id == message.chatId {
                listChat[index].lastMessage = Message(id: message.id, type: message.type, content: message.content, recall: message.recall, createdAt: message.createdAt, sender: message.sender)
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
    
    func receiveRecallMessage(completion: @escaping(String, String) -> Void) {
        socket.receiveRecallMessage { chatId, messageId in
            completion(chatId, messageId)
        }
    }
    
    func updateRecallMessage(_ chatId: String, _ messageId: String) -> [Chat] {
        var listChat = chats.value
        for (index, element) in listChat.enumerated() {
            if chatId == element.id && messageId == element.lastMessage?.id {
                listChat[index].lastMessage?.content = nil
                listChat[index].lastMessage?.recall = true
            }
        }
        return listChat
    }
    
    func logout() {
        UserDefaults.userInfo = nil
        self.socket.closeConnection()
        authService.logOut().subscribe { _ in
        } onError: { _ in
        }.disposed(by: bag)
    }
}
