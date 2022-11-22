//
//  ChatViewModel.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 24/10/2022.
//

import Foundation
import RxSwift
import RxCocoa

class ChatViewModel {
    let bag = DisposeBag()
    private var socket = Managers.socketManager
    let messages = BehaviorRelay<[Message]>(value: [])
    let listMember = BehaviorRelay<[UserInfo]>(value: [])
    private let chatService = ChatService()
    private let userService = UserService()
    private let awsService = AWSService()
    let maxImageWidth = UIScreen.main.bounds.width * 3 / 5
    let maxImageHeight = UIScreen.main.bounds.height / 2
    var sendBtnStatus = MessageType.image.rawValue
    var imageSelected = UIImage()
    var chatId = ""
    var chatName = ""
    var otherUserId = ""
    var chatType = 0
    var adminId = ""
    
    func getAllMessages() -> Observable<[Message]> {
        return chatService.getAllMessages(chatId)
    }
    
    func getAllMessagesByUserId(_ userId: String) -> Observable<Chat> {
        return chatService.getChatByUserId(userId)
    }
    
    func sendMessage(_ message: Message) {
        socket.sendMessage(message)
    }
    
    func postChat(_ userId: String) -> Observable<Chat> {
        return chatService.postChat(0, [userId])
    }
    
    func receiveMessage(completion: @escaping(Message) -> Void) {
        socket.receiveMessages { message, adminId  in
            if let newAdminId = adminId, message.type == MessageType.adminNotification.rawValue  {
                self.adminId = newAdminId
            }
            completion(message)
        }
    }
    
    func receiveLeaveChat(completion: @escaping(String) -> Void) {
        socket.receiveLeaveGroup { chatId in
            completion(chatId)
        }
    }
    
    func getAllMembers(_ chatId: String) -> Observable<[UserInfo]> {
        return userService.getUserByChatId(chatId)
    }
    
    func recallMessage(index: Int) {
        socket.recallMessage(messageId: messages.value[index].id ?? "")
    }
    
    func receiveRecallMessage(completion: @escaping(String, String) -> Void) {
        socket.receiveRecallMessage { chatId, messageId in
            completion(chatId, messageId)
        }
    }
    
    func updateRecallMessage(_ messageId: String) -> [Message] {
        var listMessage = messages.value
        for (index, element) in listMessage.enumerated() {
            if messageId == element.id {
                listMessage[index].content = nil
                listMessage[index].recall = true
            }
        }
        return listMessage
    }
    
    func uploadImage(completion: @escaping() -> Void) {
        guard let data = imageSelected.pngData() else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = DefaultConstants.dateFormat
        
        let assetDataModel = AssetDataModel(data: data, pathFile: "", thumbnail: imageSelected)
        assetDataModel.compressed = true
        assetDataModel.compressData()
        assetDataModel.remoteName = "\(UserDefaults.userInfo?.id ?? "")_" + formatter.string(from: Date())
        
        let ratio = imageSelected.size.width / imageSelected.size.height
        var newHeight = 0.0
        if ratio > 1 {
            newHeight = maxImageWidth / ratio
        }
        else {
            newHeight = maxImageHeight * ratio
        }
        
        self.sendMessage(Message(type: MessageType.image.rawValue, content: assetDataModel.remoteName, chatId: chatId, imageHeight: Int(floor(newHeight))))
        
        awsService.uploadImage(data: assetDataModel, completionHandler:  { [weak self] _, error in
            guard self != nil else { return }
            if error != nil {
                print("---------------- Lỗi upload lên AWS S3 : \(String(describing: error))")
            }
            completion()
        })
    }
    
    func getImage(index: Int, completion: @escaping(UIImage) -> Void) {
        awsService.getImage(remoteName: messages.value[index].content ?? "") { data in
            guard let data = data else { return }
            guard let image = UIImage(data: data) else { return }
            completion(image)
        }
    }
}
