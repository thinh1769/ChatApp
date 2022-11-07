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
    
    func inject(otherUserId: String?, chatId: String?, chatName: String, chatType: Int) {
        viewModel.chatId = chatId ?? ""
        viewModel.chatName = chatName
        viewModel.otherUserId = otherUserId ?? ""
        viewModel.chatType = chatType
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addMemberBtn.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        setupMessageTableView()
        subscribeReceiveMessage()
    }
    
    private func fetchData() {
        avatarImage.layer.cornerRadius = avatarImage.bounds.size.height/2
        otherUserNameLabel.text = viewModel.chatName
        if viewModel.chatType == 1 {
            viewModel.getAllMembers(viewModel.chatId).subscribe { users in
                self.viewModel.users.accept(users)
                self.setupUI()
            } onError: { _ in
            }.disposed(by: viewModel.bag)
        }
    }
    
    private func setupUI() {
        if viewModel.chatType == 0 {
            addMemberBtn.isHidden = true
            statusLabel.text = "Online"
        } else {
            addMemberBtn.isHidden = false
            statusLabel.text = "\(viewModel.users.value.count) thành viên"
        }
    }
    
    private func subscribeReceiveMessage() {
        viewModel.receiveMessage { message in
            if self.viewModel.chatId == message.chatId {
                var listMessages = self.viewModel.messages.value
                listMessages.append(message)
                self.viewModel.messages.accept(listMessages)
                self.messageTableView.reloadData()
                self.messageTableView.scrollToRow(at: [0, self.viewModel.messages.value.count - 1], at: .top, animated: true)
            }
        }
    }
    
    private func setupMessageTableView() {
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "messageCell")
        messageTableView.register(UINib(nibName: "BubbleMessageCell", bundle: nil), forCellReuseIdentifier: "bubbleMessageCell")
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
        vc.inject(chatId: viewModel.chatId, members: viewModel.users.value)
        self.navigationController?.pushViewController(vc, animated: true)
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
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as? MessageCell
                else{ return UITableViewCell() }
                cell.config(isViewSender: true, isViewMe: false, content: viewModel.messages.value[indexPath.row].content)
                return cell
                
                /// nếu không thì kiểm
            } else if viewModel.chatType == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as? MessageCell
                else{ return UITableViewCell() }
                cell.config(isViewSender: false, isViewMe: true, content: viewModel.messages.value[indexPath.row].content)
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "bubbleMessageCell", for: indexPath) as? BubbleMessageCell
                else{ return UITableViewCell() }
                cell.config(senderName: viewModel.messages.value[indexPath.row].sender?.name ?? "", content: viewModel.messages.value[indexPath.row].content)
                return cell
            }
            ///ChatType: GroupNotification
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupNotificationCell", for: indexPath) as? GroupNotificationCell else { return UITableViewCell() }
            cell.config(viewModel.messages.value[indexPath.row].content)
            return cell
        default:
            return UITableViewCell()
        }
    }
}
