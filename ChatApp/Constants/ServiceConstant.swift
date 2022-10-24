//
//  ServiceConstant.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 21/10/2022.
//

import Foundation

enum Base: String {
    case url = "http://localhost:9090/"
}

enum HeaderRequest: String {
    case token = "Authorization"
    case contentType = "Content-Type"
}

enum KeyAuth: String {
    case token = "token"
}

enum ServiceError: Error {
    case network
    case badRequest(message: String)
    case unauthorized(message: String)
    case serverError(message: String)
    case unknown(message: String)
    case emptyResponse(message: String)
    case invalidMethod
    
    func get() -> String {
        switch self {
        case .network:
            return "Lỗi kết nối, vui lòng kiểm tra lại!"
        case .badRequest(let message):
            return message
        case .unauthorized(let message):
            return message
        case .serverError(let message):
            return message
        case .unknown(let message):
            return message
        case .emptyResponse(let message):
            return message
        case .invalidMethod:
            return "Lỗi ứng dụng, vui lòng quay lại sau!"
        }
    }
}

struct StatusCode {
    static let OK = 200
    static let BAD_REQUEST = 400
    static let UNAUTHORIZED = 401
    static let SERVER_ERROR = 500
}


enum HTTPMethodSupport: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
}

enum ApiConstants: String {
    case login = "auth/login/"
    case register = "auth/register/"
    case logout = "log-out"
   
    
    var method: HTTPMethodSupport {
        switch self {
        case .login:
            return .post
        case .register:
            return .post
        case .logout:
            return .post
        }
    }

}
