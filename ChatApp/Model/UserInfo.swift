//
//  UserInfo.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 21/10/2022.
//

import Foundation

struct UserResponse: Codable {
    var user: UserInfo
    var token: String?
}

struct UserInfo: Codable {
    var id: String?
    var phoneNumber: String?
    var password: String?
    var name: String?
    var birthDay: String?
    var status: Bool?
    var v: Int?
}

enum CodingKeys: String, CodingKey {
    case id = "_id"
    case phoneNumber
    case password
    case name
    case birthDay
    case status
    case v = "__v"
}
