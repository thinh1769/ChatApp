//
//  ResponseMain.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 21/10/2022.
//

import Foundation

class ResponseMain<Payload: Codable>: Codable {
    var statusCode: Int
    var message: String
    var payload: Payload? = nil
}
