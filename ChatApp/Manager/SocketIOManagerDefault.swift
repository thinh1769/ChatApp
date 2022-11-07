//
//  SocketIOManagerDefault.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 24/10/2022.
//

import Foundation
import SocketIO

protocol SocketIOManager {
    
    func connectToSocket()
    func sendMessage(_ message: Message)
    func receiveMessages(completion: @escaping(Message) -> Void)
    func receiveCreateChat(completion: @escaping(Chat) -> Void)
    func addMember(_ chatId: String, usersId: [String])
    func closeConnection()
}

class SocketIOManagerDefault: NSObject, SocketIOManager {
    
    //MARK: - Instance Properties
    private var manager: SocketManager!
    private var socket: SocketIOClient!
    
    //MARK: - Initializers
    
    override init() {
        super.init()
    }
    
    //MARK: - Instance Methods
    
    func configSocket() {
        manager  = SocketManager(socketURL:  URL(string: Base.url.rawValue)!)

        manager.config = SocketIOClientConfiguration(
            arrayLiteral:.log(true), .compress, .extraHeaders(["token" : "Bearer \(UserDefaults.userInfo?.token ?? "")"])
        )
        socket = manager.defaultSocket
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func connectToSocket() {
        
        self.configSocket()
        socket.disconnect()
        socket.on(clientEvent: .connect) {data, _ in
            print("Socket connected")
        }
        
        socket.on(clientEvent: .error) { data, _ in
            print("--------------- lỗi connect socket: \(data.description)")
        }
        
        socket.connect()
    }
    
    func sendMessage(_ message: Message) {
        let params = ["type": message.type, "content": message.content, "chatId": message.chatId] as [String : Any]
        socket.emit("User-Send-Message", params)
    }
    
    func addMember(_ chatId: String, usersId: [String]) {
        let params = ["chatId": chatId, "usersId": usersId] as [String: Any]
        socket.emit("User-Add-Member", params)
    }
    
    func receiveMessages(completion: @escaping(Message) -> Void) {
        socket.on("User-Send-Message") { responseData, _ in
            let messageResponse = responseData[0] as! NSDictionary
            let content = messageResponse["content"] as! String
            let type = messageResponse["type"] as! Int
            let chatId = messageResponse["chatId"] as! String
            let createdAt = messageResponse["createdAt"] as! String
            
            if type != 2 {
                let recall = messageResponse["recall"] as! Bool
                let senderId = (messageResponse["sender"] as! NSDictionary)["id"] as! String
                let senderName = (messageResponse["sender"] as! NSDictionary)["name"] as! String
                let message = Message(type: type, content: content, chatId: chatId, recall: recall, createdAt: createdAt, sender: UserInfo(id: senderId, name: senderName))
                completion(message)
            } else {
                let message = Message(type: type, content: content, chatId: chatId, createdAt: createdAt)
                completion(message)
            }
            
        }
    }
    
    func receiveCreateChat(completion: @escaping(Chat) -> Void) {
        socket.on("User-Create-Chat") { responseData, _ in
            let chatResponse = responseData[0] as! NSDictionary
            let chatId = chatResponse["id"] as! String
            let type = chatResponse["type"] as! Int
            
            let lassMessageResponse = chatResponse ["lastMessage"] as! NSDictionary
            let messageType = lassMessageResponse["type"] as! Int
            let messageContent = lassMessageResponse["content"] as! String
            let recall = lassMessageResponse["recall"] as! Bool
            let sender = lassMessageResponse["sender"] as! NSDictionary
            let senderId = sender["id"] as! String
            let senderName = sender["name"] as! String
            let createdAt = lassMessageResponse["createdAt"] as! String
            
            let lassMessage = Message(type: messageType, content: messageContent, recall: recall, createdAt: createdAt, sender: UserInfo(id: senderId, name: senderName))
            
            if type == 1 {
                let chatName = chatResponse["chatName"] as! String
                let chat = Chat(id: chatId, type: type, chatName: chatName, lastMessage: lassMessage)
                completion(chat)
            } else {
                let receiver = chatResponse["receiver"] as! NSDictionary
                let receiverId = receiver["id"] as! String
                let receiverName = receiver["name"] as! String
                let chat = Chat(id: chatId, type: type, receiver: UserInfo(id: receiverId, name: receiverName), lastMessage: lassMessage)
                completion(chat)
            }
        }
    }
}
