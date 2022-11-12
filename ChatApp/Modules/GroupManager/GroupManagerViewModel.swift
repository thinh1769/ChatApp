//
//  GroupManagerViewModel.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 08/11/2022.
//

import Foundation
import RxSwift
import RxCocoa

class GroupManagerViewModel {
    private var socket = Managers.socketManager
    let listMember = BehaviorRelay<[UserInfo]>(value: [])
    var groupName = ""
    var adminId = ""
    var isAdmin = false
    var isChooseAdmin = false
    var chatId = ""
    
    func chooseAdmin(index: Int) {
        adminId = listMember.value[index].id ?? ""
        isAdmin = false
        socket.chooseAdmin(chatId: chatId, userId: adminId)
    }
    
    func removeMember(index: Int) {
        socket.removeMember(chatId: chatId, userId: listMember.value[index].id ?? "")
        var list = listMember.value
        list.remove(at: index)
        listMember.accept(list)
    }
    
    func leaveGroup() {
        socket.leaveGroup(chatId: chatId)
    }
}
