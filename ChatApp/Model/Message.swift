//
//  Message.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 09/10/2022.
//

import Foundation

struct Message: Codable {
    var id: Int
    var ownerId: Int
    var text: String
}
