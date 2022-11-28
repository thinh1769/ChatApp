//
//  UserInfoViewModel.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 28/11/2022.
//

import UIKit
import RxCocoa
import RxSwift

class UserInfoViewModel {
    let awsService = AWSService()
    let userService = UserService()
    let bag = DisposeBag()
    
    var avatar = UIImage()
    var name = UserDefaults.userInfo?.name ?? ""
    var imageSelected = UIImage()
    
    func updateUserInfo() -> Observable<UserInfo> {
        return userService.updateUserInfo()
    }
    
    func uploadImage(completion: @escaping() -> Void) {
        guard let data = imageSelected.pngData() else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = DefaultConstants.dateFormat
        
        let assetDataModel = AssetDataModel(data: data, pathFile: "", thumbnail: imageSelected)
        assetDataModel.compressed = true
        assetDataModel.compressData()
        assetDataModel.remoteName = "\(UserDefaults.userInfo?.id ?? "")_" + formatter.string(from: Date())
        
        //self.sendMessage(Message(type: MessageType.image.rawValue, content: assetDataModel.remoteName, chatId: chatId, imageHeight: self.calculateNewHeight()))
        
//        awsService.uploadImage(data: assetDataModel, completionHandler:  { [weak self] _, error in
//            guard self != nil else { return }
//            if error != nil {
//                print("---------------- Lỗi upload lên AWS S3 : \(String(describing: error))")
//            }
//            completion()
//        })
    }
    
    func getImage(remoteName: String, completion: @escaping(UIImage) -> Void) {
//        awsService.getImage(remoteName: remoteName) { data in
//            guard let data = data else { return }
//            guard let image = UIImage(data: data) else { return }
//            completion(image)
//        }
    }
    
}
