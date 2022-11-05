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

    @IBOutlet weak var otherUserNameLabel: UILabel!
    @IBOutlet weak var chatInputText: UITextField!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var inforButton: UIButton!
    
    var viewModel = ChatViewModel()
    
    func inject(otherUserId: String?, chatId: String?, chatName: String, chatType: Int) {
        viewModel.chatId = chatId ?? ""
        viewModel.chatName = chatName
        viewModel.otherUserId = otherUserId ?? ""
        viewModel.chatType = chatType
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        otherUserNameLabel.text = viewModel.chatName
        avatarImage.layer.cornerRadius = avatarImage.bounds.size.height/2
        inforButton.setTitle("", for: .normal)
        setupMessageTableView()
        viewModel.receiveMessage { message in
            if self.viewModel.chatId == message.chatId {
                var listMessages = self.viewModel.messages.value
                listMessages.append(message)
                self.viewModel.messages.accept(listMessages)
                self.messageTableView.reloadData()
                self.messageTableView.scrollToRow(at: [0, self.viewModel.messages.value.count - 1], at: .top, animated: true)
            }
        }
//        chatInputText.rx.controlEvent([.editingDidBegin])
//            .subscribe {
//                self.messageTableView.scrollToRow(at: [0, self.viewModel.messages.value.count - 1], at: .top, animated: true)
//            }.disposed(by: DisposeBag())
    }
    
    private func setupMessageTableView() {
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "messageCell")
        messageTableView.register(UINib(nibName: "BubbleMessageCell", bundle: nil), forCellReuseIdentifier: "bubbleMessageCell")
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
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.messages.value[indexPath.row].sender?.id == UserDefaults.userInfo?.id {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as? MessageCell
                else{ return UITableViewCell() }
            cell.emptyViewSender.isHidden = true
            cell.emptyViewMe.isHidden = false
            cell.messageText.text = viewModel.messages.value[indexPath.row].content
            return cell
        } else {
            if viewModel.chatType == 1 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "bubbleMessageCell", for: indexPath) as? BubbleMessageCell
                    else{ return UITableViewCell() }
                cell.emptyViewMe.isHidden = true
                cell.emptyViewSender.isHidden = false
                cell.senderNameLabel.text = viewModel.messages.value[indexPath.row].sender?.name ?? ""
                cell.messageText.text = viewModel.messages.value[indexPath.row].content
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as? MessageCell
                    else{ return UITableViewCell() }
                cell.emptyViewSender.isHidden = false
                cell.emptyViewMe.isHidden = true
                cell.messageText.text = viewModel.messages.value[indexPath.row].content
                return cell
            }
        }
    }
}
