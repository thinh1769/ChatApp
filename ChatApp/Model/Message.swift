//
//  Message.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 09/10/2022.
//

import Foundation
import SocketIO

struct Message: Codable, SocketData {
    var id: String?
    var type: Int
    var content: String
    var chatId: String?
    var sender: UserInfo?
}
