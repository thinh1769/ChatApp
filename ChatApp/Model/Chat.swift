//
//  Chat.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 24/10/2022.
//

import Foundation

struct Chat: Codable {
    let id: String
    var createBy: String?
    var type: Int
    var receiver: UserInfo?
    var chatName: String?
    var lastMessage: Message?
    var messages: [Message]?
}
