//
//  SocketIOManagerDefault.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 24/10/2022.
//

import Foundation
import SocketIO

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
        print("-=-=-=-=-=-=-=Token = \(UserDefaults.userInfo?.token ?? "")")
        
        socket = manager.defaultSocket
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func connectToSocket() {
        
        self.configSocket()
        socket.disconnect()
        socket.on("connect_error") { data, _ in
            print("=-=-=--=-=-=-=- error = \(data)")
        }
        socket.on(clientEvent: .connect) {data, _ in
            print(" socket connected")
        }
        
        socket.on(clientEvent: .error) { data, _ in
            print("--------------- lỗi connect socket: \(data.description)")
        }
        
        socket.connect()
    }
    
    func observeUserList(completionHandler: @escaping ([[String: Any]]) -> Void) {
        socket.on("userList") { dataArray, _ in
            completionHandler(dataArray[0] as! [[String: Any]])
        }
    }
    
    func sendMessage(_ message: Message) {
        let params = ["type": message.type, "content": message.content, "chatId": message.chatId] as [String : Any]
        socket.emit("User-Send-Message", params)
        socket.on("Error") { error, _ in
            print("=-=-=-=-=-=-=-=-=-=-Error = \(error)")
        }
    }
    
    func receiveMessages(completion: @escaping(Message) -> Void) {
        socket.on("User-Send-Message") { responseData, _ in
            let messageResponse = responseData[0] as! NSDictionary
            let messageContent = messageResponse["content"] as! String
            let messageType = messageResponse["type"] as! Int
            let chatId = messageResponse["chatId"] as! String
            let senderId = (messageResponse["sender"] as! NSDictionary)["id"] as! String
            let senderName = (messageResponse["sender"] as! NSDictionary)["name"] as! String

            let message = Message(type: messageType, content: messageContent, chatId: chatId, sender: UserInfo(id: senderId, name: senderName))
            completion(message)
        }
    }
}
