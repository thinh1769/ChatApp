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
    func receiveMessages(completion: @escaping(Message, String?) -> Void)
    func receiveCreateChat(completion: @escaping(Chat) -> Void)
    func receiveLeaveGroup(completion: @escaping(String) -> Void)
    func addMember(_ chatId: String, usersId: [String])
    func chooseAdmin(chatId: String, userId: String)
    func removeMember(chatId: String, userId: String)
    func leaveGroup(chatId: String)
    func recallMessage(messageId: String)
    func receiveRecallMessage(completion: @escaping(String, String) -> Void)
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
            print("lỗi connect socket: \(data.description)")
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
    
    func receiveMessages(completion: @escaping(Message, String?) -> Void) {
        socket.on("User-Send-Message") { responseData, _ in
            let messageResponse = responseData[0] as! NSDictionary
            let messageId = messageResponse["id"] as! String
            let content = messageResponse["content"] as! String
            let type = messageResponse["type"] as! Int
            let chatId = messageResponse["chatId"] as! String
            let createdAt = messageResponse["createdAt"] as! String
            
            switch type{
            case MessageType.text.rawValue:
                let recall = messageResponse["recall"] as! Bool
                let senderId = (messageResponse["sender"] as! NSDictionary)["id"] as! String
                let senderName = (messageResponse["sender"] as! NSDictionary)["name"] as! String
                let message = Message(id: messageId, type: type, content: content, chatId: chatId, recall: recall, createdAt: createdAt, sender: UserInfo(id: senderId, name: senderName))
                completion(message, nil)
            case MessageType.groupNotification.rawValue:
                let message = Message(id: messageId, type: type, content: content, chatId: chatId, createdAt: createdAt)
                completion(message, nil)
            case MessageType.adminNotification.rawValue:
                let message = Message(id: messageId, type: type, content: content, chatId: chatId, createdAt: createdAt)
                let adminId = messageResponse["adminId"] as! String
                completion(message, adminId)
            default: break
            }
            
        }
    }
    
    func receiveCreateChat(completion: @escaping(Chat) -> Void) {
        socket.on("User-Create-Chat") { responseData, _ in
            let chatResponse = responseData[0] as! NSDictionary
            let chatId = chatResponse["id"] as! String
            let type = chatResponse["type"] as! Int
            
            let lassMessageResponse = chatResponse ["lastMessage"] as! NSDictionary
            let messageId = lassMessageResponse["id"] as! String
            let messageType = lassMessageResponse["type"] as! Int
            let messageContent = lassMessageResponse["content"] as! String
            let recall = lassMessageResponse["recall"] as! Bool
            let sender = lassMessageResponse["sender"] as! NSDictionary
            let senderId = sender["id"] as! String
            let senderName = sender["name"] as! String
            let createdAt = lassMessageResponse["createdAt"] as! String
            
            let lassMessage = Message(id: messageId, type: messageType, content: messageContent, recall: recall, createdAt: createdAt, sender: UserInfo(id: senderId, name: senderName))
            
            if type == ChatType.group.rawValue {
                let chatName = chatResponse["chatName"] as! String
                let createBy = chatResponse["createBy"] as! String
                let chat = Chat(id: chatId, createBy: createBy, type: type, chatName: chatName, lastMessage: lassMessage)
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
    
    func chooseAdmin(chatId: String, userId: String) {
        let params = ["chatId": chatId, "userId": userId] as [String: Any]
        socket.emit("User-Select-Admin", params)
    }
    
    func leaveGroup(chatId: String)   {
        let param = ["chatId": chatId] as [String: Any]
        socket.emit("User-Leave-Group", param)
    }
    
    func receiveLeaveGroup(completion: @escaping(String) -> Void) {
        socket.on("User-Remove-Chat") { responseData, _ in
            let chatIdResponse = responseData[0] as! NSDictionary
            let chatId = chatIdResponse["chatId"] as! String
            completion(chatId)
        }
    }
    
    func removeMember(chatId: String, userId: String) {
        let params = ["chatId": chatId, "userId": userId] as [String: Any]
        socket.emit("User-Remove-Member", params)
    }
    
    func recallMessage(messageId: String) {
        let param = ["messageId": messageId] as [String: Any]
        socket.emit("User-Recall-Message", param)
    }
    
    func receiveRecallMessage(completion: @escaping(String, String) -> Void) {
        socket.on("User-Recall-Message") { responseData, _ in
            let data = responseData[0] as! NSDictionary
            let chatId = data["chatId"] as! String
            let messageId = data["messageId"] as! String
            completion(chatId, messageId)
        }
    }
}
