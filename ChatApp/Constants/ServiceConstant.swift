//
//  ServiceConstant.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 21/10/2022.
//

import Foundation

enum Base: String {
    case url = "http://192.168.1.119:9090/"
//    case url = "http://localhost:9090/"
}

struct AWSConstants {
    static let accessKey = "AKIA4SZBYIUOX2L46WOP"
    static let secretKey = "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"
    static let s3Bucket = "congnghemoi-nhom15-chatapp"
}

struct DefaultConstants {
    static let recallMessage = "Tin nhắn đã được thu hồi"
    static let recallAlert = "Chỉ được thu hồi tin nhắn đã gửi trước 1 giờ"
    static let alertTitle = "Cảnh báo"
    static let ok = "Ok"
    static let wrongConfirmPassword = "Nhập lại mật khẩu chưa đúng"
    static let requireChooseAdmin = "Bạn phải chọn trường nhóm mới trước khi rời nhóm"
    static let requireNameGroup = "Chưa nhập tên nhóm"
    static let requireNumberOfMember = "Chưa đủ số lượng thành viên"
    static let cancel = "Hủy"
    static let recall = "Thu hồi"
    static let camera = "Máy ảnh"
    static let photoLibrary = "Thư viện ảnh"
    static let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    static let sendImage = " đã gửi 1 hình ảnh"
    static let you = "Bạn"
    static let registerInformation = "Chưa nhập đủ thông tin đăng ký"
    static let loginFailed = "Thông tin đăng nhập không đúng"
}

enum TableCellType: Int {
    case chat = 0
    case friend = 1
}

enum ChatType: Int {
    case single = 0
    case group = 1
}

enum MessageType: Int {
    case text = 0
    case image = 1
    case groupNotification = 2
    case adminNotification = 3
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
    static let NOT_FOUND_CHAT = 404
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
    case logout = "auth/logout"
    case getAllChats = "chats/"
    case getAllMessages = "chats/messages/" // {chatId}
    case searchFriends = "users/search/" // {userName or phoneNumber}
    case getChatByUserId = "chats/getByOtherUser/" //{userId}
    case getUserByChatId = "users/getByChat/" // {chatId}
    
    var method: HTTPMethodSupport {
        switch self {
        case .login:
            return .post
        case .register:
            return .post
        case .logout:
            return .post
        case .getAllChats:
            return .get
        case .getAllMessages:
            return .get
        case .searchFriends:
            return .get
        case .getChatByUserId:
            return .get
        case .getUserByChatId:
            return .get
        }
    }

}
