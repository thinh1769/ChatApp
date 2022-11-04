//
//  SocketIOManager.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 24/10/2022.
//

import Foundation

protocol SocketIOManager {
    
    func connectToSocket()
    func observeUserList(completionHandler: @escaping ([[String: Any]]) -> Void)
    func sendMessage(_ message: Message)
    func receiveMessages(completion: @escaping(Message) -> Void)
    func receiveCreateChat(completion: @escaping(Chat) -> Void)
    func closeConnection()
}
