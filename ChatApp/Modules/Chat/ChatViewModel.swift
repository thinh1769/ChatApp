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
    var chatId = ""
    var chatName = ""
    var otherUserId = ""
    let chatService = ChatService()
    
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
        socket.receiveMessages { message in
            completion(message)
        }
    }
}
