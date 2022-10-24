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

    @IBOutlet weak var chatInputText: UITextField!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var inforButton: UIButton!
    
    var messages = [
        Message(id: 1, ownerId: 1, text: "chào bạn"),
        Message(id: 2, ownerId: 1, text: "mình có học chung lớp với bạn ấy"),
        Message(id: 3, ownerId: 1, text: "cho mình hỏi mai mình có kiểm tra ko ta"),
        Message(id: 4, ownerId: 2, text: "à mai có kiểm tra á nghen"),
        Message(id: 5, ownerId: 2, text: "học kĩ chương 1 2 là bao đậu rồi yên tâm"),
        Message(id: 6, ownerId: 1, text: "à ok cảm ơn bạn"),
        Message(id: 7, ownerId: 1, text: "chào bạn"),
        Message(id: 8, ownerId: 1, text: "mình có học chung lớp với bạn ấy"),
        Message(id: 9, ownerId: 1, text: "cho mình hỏi mai mình có kiểm tra ko ta"),
        Message(id: 10, ownerId: 2, text: "à mai có kiểm tra á nghen"),
        Message(id: 11, ownerId: 2, text: "học kĩ chương 1 2 là bao đậu rồi yên tâm"),
        Message(id: 12, ownerId: 1, text: "à ok cảm ơn bạn"),
        Message(id: 13, ownerId: 1, text: "chào bạn"),
        Message(id: 14, ownerId: 1, text: "mình có học chung lớp với bạn ấy"),
        Message(id: 15, ownerId: 1, text: "cho mình hỏi mai mình có kiểm tra ko ta"),
        Message(id: 16, ownerId: 2, text: "à mai có kiểm tra á nghen"),
        Message(id: 17, ownerId: 2, text: "học kĩ chương 1 2 là bao đậu rồi yên tâm"),
        Message(id: 18, ownerId: 1, text: "à ok cảm ơn bạn"),
        Message(id: 19, ownerId: 1, text: "chào bạn"),
        Message(id: 20, ownerId: 1, text: "mình có học chung lớp với bạn ấy"),
        Message(id: 21, ownerId: 1, text: "cho mình hỏi mai mình có kiểm tra ko ta"),
        Message(id: 22, ownerId: 2, text: "à mai có kiểm tra á nghen"),
        Message(id: 23, ownerId: 2, text: "học kĩ chương 1 2 là bao đậu rồi yên tâm"),
        Message(id: 24, ownerId: 1, text: "à ok cảm ơn bạn")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarImage.layer.cornerRadius = avatarImage.bounds.size.height/2
        inforButton.setTitle("", for: .normal)
        setupMessageTableView()
        
        chatInputText.rx.controlEvent([.editingDidBegin])
            .subscribe {
                self.messageTableView.scrollToRow(at: [0, self.messages.count - 1], at: .top, animated: true)
            }.disposed(by: DisposeBag())
    }
    
    private func setupMessageTableView() {
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "messageCell")
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.scrollToRow(at: [0, messages.count - 1], at: .top, animated: true)
    }
    @IBAction func sendMessageBtn(_ sender: UIButton) {
        if let textMessage = chatInputText.text, textMessage.count > 0 {
            chatInputText.text = ""
            messages.append(Message(id: messages.count + 1, ownerId: 1, text: textMessage))
            messageTableView.reloadData()
            messageTableView.scrollToRow(at: [0, messages.count - 1], at: .top, animated: true)
        }
    }
    
    @IBAction func onClickBackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as? MessageCell
            else{ return UITableViewCell() }
        if messages[indexPath.row].ownerId == 1 {
            cell.emptyViewSender.isHidden = true
            cell.emptyViewMe.isHidden = false
        } else {
            cell.emptyViewMe.isHidden = true
            cell.emptyViewSender.isHidden = false
        }
        cell.messageText.text = messages[indexPath.row].text
//        if indexPath.row == messages.count - 1 {
//            messageTableView.scrollToRow(at: [0,messages.count - 1], at: .top, animated: true)
//        }
        return cell
    }
}
