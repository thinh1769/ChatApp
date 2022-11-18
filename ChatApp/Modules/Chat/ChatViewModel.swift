//
//  ChatViewModel.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 24/10/2022.
//

import Foundation
import RxSwift
import RxCocoa

class ChatViewModel {
    let bag = DisposeBag()
    private var socket = Managers.socketManager
    let messages = BehaviorRelay<[Message]>(value: [])
    let listMember = BehaviorRelay<[UserInfo]>(value: [])
    private let chatService = ChatService()
    private let userService = UserService()
    var chatId = ""
    var chatName = ""
    var otherUserId = ""
    var chatType = 0
    var adminId = ""
    
    func getAllMessages() -> Observable<[Message]> {
        return chatService.getAllMessages(chatId)
    }
    
    func getAllMessagesByUserId(_ userId: String) -> Observable<Chat> {
        return chatService.getChatByUserId(userId)
    }
    
    func sendMessage(_ message: Message) {
        socket.sendMessage(message)
    }
    
    func postChat(_ userId: String) -> Observable<Chat> {
        return chatService.postChat(0, [userId])
    }
    
    func receiveMessage(completion: @escaping(Message) -> Void) {
        socket.receiveMessages { message, adminId  in
            if let newAdminId = adminId, message.type == MessageType.adminNotification.rawValue  {
                self.adminId = newAdminId
            }
            completion(message)
        }
    }
    
    func receiveLeaveChat(completion: @escaping(String) -> Void) {
        socket.receiveLeaveGroup { chatId in
            completion(chatId)
        }
    }
    
    func getAllMembers(_ chatId: String) -> Observable<[UserInfo]> {
        return userService.getUserByChatId(chatId)
    }
    
    func recallMessage(index: Int) {
        socket.recallMessage(messageId: messages.value[index].id ?? "")
    }
    
    func receiveRecallMessage(completion: @escaping(String, String) -> Void) {
        socket.receiveRecallMessage { chatId, messageId in
            completion(chatId, messageId)
        }
    }
    
    func updateRecallMessage(_ messageId: String) -> [Message] {
        var listMessage = messages.value
        for (index, element) in listMessage.enumerated() {
            if messageId == element.id {
                listMessage[index].content = nil
                listMessage[index].recall = true
            }
        }
        return listMessage
    }
}
