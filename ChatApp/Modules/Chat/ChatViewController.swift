//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 06/10/2022.
//

import UIKit
import RxSwift
import RxCocoa

class ChatViewController: UIViewController {
    
    @IBOutlet weak private var statusLabel: UILabel!
    @IBOutlet weak private var addMemberBtn: UIButton!
    @IBOutlet weak private var otherUserNameLabel: UILabel!
    @IBOutlet weak private var chatInputText: UITextField!
    @IBOutlet weak private var avatarImage: UIImageView!
    @IBOutlet weak private var messageTableView: UITableView!
    @IBOutlet weak private var inforButton: UIButton!
    
    var viewModel = ChatViewModel()
    
    func inject(otherUserId: String?, chatId: String?, chatName: String, chatType: Int, adminId: String) {
        viewModel.chatId = chatId ?? ""
        viewModel.chatName = chatName
        viewModel.otherUserId = otherUserId ?? ""
        viewModel.chatType = chatType
        viewModel.adminId = adminId
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if viewModel.chatType == ChatType.single.rawValue {
            addMemberBtn.isHidden = true
        } else {
            addMemberBtn.isHidden = false
        }
        avatarImage.layer.cornerRadius = avatarImage.bounds.size.height/2
        otherUserNameLabel.text = viewModel.chatName
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        setupMessageTableView()
        subscribeSocketIO()
    }
    
    private func fetchData() {
        if viewModel.chatType == ChatType.group.rawValue {
            viewModel.getAllMembers(viewModel.chatId).subscribe { users in
                self.viewModel.listMember.accept(users)
                self.setupUI()
            } onError: { _ in
            }.disposed(by: viewModel.bag)
        }
    }
    
    private func setupUI() {
        if viewModel.chatType == ChatType.single.rawValue {
            statusLabel.text = "Online"
        } else {
            statusLabel.text = "\(viewModel.listMember.value.count) thành viên"
            avatarImage.image = UIImage(named: "avatar-group")
        }
    }
    
    private func subscribeSocketIO() {
        viewModel.receiveMessage { [weak self] message in
            guard let self = self else { return }
            if self.viewModel.chatId == message.chatId {
                if message.type == MessageType.groupNotification.rawValue {
                    self.fetchData()
                }
                var listMessages = self.viewModel.messages.value
                listMessages.append(message)
                self.viewModel.messages.accept(listMessages)
                self.messageTableView.reloadData()
                self.messageTableView.scrollToRow(at: [0, self.viewModel.messages.value.count - 1], at: .top, animated: true)
            }
        }
        
        viewModel.receiveLeaveChat { [weak self] chatId in
            guard let self = self else { return }
            if self.viewModel.chatId == chatId {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        // Đang làm on recall chat
    }
    
    private func setupMessageTableView() {
        messageTableView.register(UINib(nibName: "SenderMessageCell", bundle: nil), forCellReuseIdentifier: "senderMessageCell")
        messageTableView.register(UINib(nibName: "ReceiveMessageCell", bundle: nil), forCellReuseIdentifier: "receiveMessageCell")
        messageTableView.register(UINib(nibName: "ReceiveGroupMessageCell", bundle: nil), forCellReuseIdentifier: "receiveGroupMessageCell")
        messageTableView.register(UINib(nibName: "GroupNotificationCell", bundle: nil), forCellReuseIdentifier: "groupNotificationCell")
        messageTableView.delegate = self
        messageTableView.dataSource = self

        
        if viewModel.chatId != "" {
            viewModel.getAllMessages().bind { [weak self] messages in
                guard let self = self else { return }
                self.setupBinding(messages)
            }.disposed(by: viewModel.bag)
        } else {
            viewModel.getAllMessagesByUserId(viewModel.otherUserId).bind { [weak self] chat in
                guard let self = self else { return }
                self.setupBinding(chat.messages ?? [])
                self.viewModel.chatId = chat.id
            }.disposed(by: viewModel.bag)
        }
    }
    
    private func setupBinding(_ messages: [Message]) {
        self.viewModel.messages.accept(messages)
        if messages.count > 0 {
            self.messageTableView.reloadData()
            self.messageTableView.scrollToRow(at: [0, self.viewModel.messages.value.count - 1], at: .top, animated: true)
        }
    }
    
    @IBAction func sendMessageBtn(_ sender: UIButton) {
        if let textMessage = chatInputText.text, textMessage.count > 0 {
            if viewModel.chatId == "" {
                viewModel.postChat(viewModel.otherUserId).subscribe { [weak self] chat in
                    guard let self = self else { return }
                    self.viewModel.chatId = chat.id
                } onError: { _ in
                } onCompleted: {
                    self.chatInputText.text = ""
                    self.viewModel.sendMessage(Message(type: 0, content: textMessage, chatId: self.viewModel.chatId))
                }.disposed(by: viewModel.bag)
            } else {
                chatInputText.text = ""
                viewModel.sendMessage(Message(type: 0, content: textMessage, chatId: viewModel.chatId))
            }
        }
    }
    
    @IBAction func onClickBackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickedAddMemberBtn(_ sender: UIButton) {
        let vc = AddMemberViewController()
        vc.inject(chatId: viewModel.chatId, members: viewModel.listMember.value, chatName: viewModel.chatName)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onClickedInfoBtn(_ sender: UIButton) {
        if viewModel.chatType == ChatType.group.rawValue {
            let vc = GroupManagerViewController()
            vc.inject(viewModel.listMember.value, viewModel.adminId, viewModel.chatId, viewModel.chatName)
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func showRecallSheet(index: Int) {
        let recallSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        recallSheet.addAction(UIAlertAction(title: "Thu hồi", style: .default,handler: { _ in
            print("---------------\(self.viewModel.messages.value[index].id ?? "")")
            self.viewModel.recallMessage(index: index)
        }))
        recallSheet.addAction(UIAlertAction(title: "Hủy", style: .destructive, handler: nil))
        present(recallSheet, animated: true, completion: nil)
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.messages.value[indexPath.row].type {
            ///ChatType: Text
        case 0:
            ///kiểm tra message có trùng với id đang đăng nhập
            if viewModel.messages.value[indexPath.row].sender?.id == UserDefaults.userInfo?.id {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "senderMessageCell", for: indexPath) as? SenderMessageCell
                else { return UITableViewCell() }
                if viewModel.messages.value[indexPath.row].recall ?? false {
                    cell.config(content: "Tin nhắn đã được thu hồi")
                } else {
                    cell.config(content: viewModel.messages.value[indexPath.row].content ?? "")
                }
                return cell
                
            } else if viewModel.messages.value[indexPath.row].recall ?? false {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "receiveMessageCell", for: indexPath) as? ReceiveMessageCell
                else { return UITableViewCell() }
                cell.config(content: "Tin nhắn đã được thu hồi")
                return cell
            } else if viewModel.chatType == ChatType.single.rawValue {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "receiveMessageCell", for: indexPath) as? ReceiveMessageCell
                else { return UITableViewCell() }
                cell.config(content: viewModel.messages.value[indexPath.row].content ?? "")
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "receiveGroupMessageCell", for: indexPath) as? ReceiveGroupMessageCell else { return UITableViewCell() }
                cell.config(name: viewModel.messages.value[indexPath.row].sender?.name ?? "", content: viewModel.messages.value[indexPath.row].content ?? "")
                return cell
            }
            ///ChatType: GroupNotification
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupNotificationCell", for: indexPath) as? GroupNotificationCell else { return UITableViewCell() }
            cell.config(viewModel.messages.value[indexPath.row].content ?? "")
            return cell
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupNotificationCell", for: indexPath) as? GroupNotificationCell else { return UITableViewCell() }
            cell.config(viewModel.messages.value[indexPath.row].content ?? "")
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showRecallSheet(index: indexPath.row)
    }
}

extension ChatViewController: ChooseNewAdminDelegate {
    func chooseNewAdmin(adminId: String) {
        viewModel.adminId = adminId
    }
}
