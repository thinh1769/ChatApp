//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 06/10/2022.
//

import UIKit
import RxSwift
import RxCocoa
import PhotosUI

class ChatViewController: UIViewController {
    
    @IBOutlet weak private var statusLabel: UILabel!
    @IBOutlet weak private var addMemberBtn: UIButton!
    @IBOutlet weak private var otherUserNameLabel: UILabel!
    @IBOutlet weak private var chatInputText: UITextField!
    @IBOutlet weak private var avatarImage: UIImageView!
    @IBOutlet weak private var messageTableView: UITableView!
    @IBOutlet weak private var inforButton: UIButton!
    @IBOutlet weak private var sendButton: UIButton!
    
    var viewModel = ChatViewModel()
    let imagePicked = UIImagePickerController()
    
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
        setupUI()
        fetchData()
        setupMessageTableView()
        subscribeSocketIO()
    }
    
    private func setupUI() {
        chatInputText.rx.controlEvent([.editingChanged]).subscribe { [weak self] _ in
            guard let self = self else { return }
            if self.chatInputText.text?.count != 0 {
                self.sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
                self.viewModel.sendBtnStatus = MessageType.text.rawValue
            } else {
                self.sendButton.setImage(UIImage(systemName: "photo.fill.on.rectangle.fill"), for: .normal)
                self.viewModel.sendBtnStatus = MessageType.image.rawValue
            }
        }.disposed(by: viewModel.bag)
        
        imagePicked.delegate = self
        imagePicked.allowsEditing = false
    }
    
    private func fetchData() {
        if viewModel.chatType == ChatType.group.rawValue {
            viewModel.getAllMembers(viewModel.chatId).subscribe { users in
                self.viewModel.listMember.accept(users)
                self.setupUIAfterFetchingData()
            } onError: { _ in
            }.disposed(by: viewModel.bag)
        }
    }
    
    private func setupUIAfterFetchingData() {
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
                if message.type == MessageType.image.rawValue {
                    self.viewModel.getImage(remoteName: message.content ?? "") { _ in
                        DispatchQueue.main.async {
                            self.messageTableView.reloadData()
                        }
                    }
                }
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
        
        viewModel.receiveRecallMessage { [weak self] chatId, messageId in
            guard let self = self else { return }
            if chatId == self.viewModel.chatId {
                self.viewModel.messages.accept(self.viewModel.updateRecallMessage(messageId))
                self.messageTableView.reloadData()
                self.messageTableView.scrollToRow(at: [0, self.viewModel.messages.value.count - 1], at: .top, animated: true)
            }
        }
    }
    
    private func setupMessageTableView() {
        messageTableView.register(UINib(nibName: "SenderMessageCell", bundle: nil), forCellReuseIdentifier: "senderMessageCell")
        messageTableView.register(UINib(nibName: "ReceiveMessageCell", bundle: nil), forCellReuseIdentifier: "receiveMessageCell")
        messageTableView.register(UINib(nibName: "ReceiveGroupMessageCell", bundle: nil), forCellReuseIdentifier: "receiveGroupMessageCell")
        messageTableView.register(UINib(nibName: "GroupNotificationCell", bundle: nil), forCellReuseIdentifier: "groupNotificationCell")
        messageTableView.register(UINib(nibName: "ImageSenderCell", bundle: nil), forCellReuseIdentifier: "imageSenderCell")
        messageTableView.register(UINib(nibName: "ImageReceiverCell", bundle: nil), forCellReuseIdentifier: "imageReceiverCell")
        messageTableView.register(UINib(nibName: "ImageReceiverGroupCell", bundle: nil), forCellReuseIdentifier: "imageReceiverGroupCell")
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
        if viewModel.sendBtnStatus == MessageType.text.rawValue {
            if let textMessage = chatInputText.text, textMessage.count > 0 {
                if viewModel.chatId == "" {
                    viewModel.postChat(viewModel.otherUserId).subscribe { [weak self] chat in
                        guard let self = self else { return }
                        self.viewModel.chatId = chat.id
                    } onError: { _ in
                    } onCompleted: {
                        self.chatInputText.text = ""
                        self.sendButton.setImage(UIImage(systemName: "photo.fill.on.rectangle.fill"), for: .normal)
                        self.viewModel.sendBtnStatus = MessageType.image.rawValue
                        self.viewModel.sendMessage(Message(type: 0, content: textMessage, chatId: self.viewModel.chatId))
                    }.disposed(by: viewModel.bag)
                } else {
                    chatInputText.text = ""
                    self.sendButton.setImage(UIImage(systemName: "photo.fill.on.rectangle.fill"), for: .normal)
                    self.viewModel.sendBtnStatus = MessageType.image.rawValue
                    viewModel.sendMessage(Message(type: 0, content: textMessage, chatId: viewModel.chatId))
                }
            }
        } else {
            self.showMediaSheet()
        }
    }
    
    private func showImagePickerView() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
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
        recallSheet.addAction(UIAlertAction(title: DefaultConstants.recall, style: .default,handler: { _ in
            self.viewModel.recallMessage(index: index)
        }))
        recallSheet.addAction(UIAlertAction(title: DefaultConstants.cancel, style: .destructive, handler: nil))
        present(recallSheet, animated: true, completion: nil)
    }
    
    private func showMediaSheet() {
        let mediaSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        mediaSheet.addAction(UIAlertAction(title: DefaultConstants.camera, style: .default, handler: { _ in
            self.imagePicked.sourceType = .camera
            self.present(self.imagePicked, animated: true)
        }))
        mediaSheet.addAction(UIAlertAction(title: DefaultConstants.photoLibrary, style: .default, handler: { _ in
            self.showImagePickerView()
        }))
        mediaSheet.addAction(UIAlertAction(title: DefaultConstants.cancel, style: .destructive, handler: nil))
        present(mediaSheet, animated: true, completion: nil)
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: DefaultConstants.alertTitle, message: DefaultConstants.recallAlert, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: DefaultConstants.ok, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
                    cell.config(content: DefaultConstants.recallMessage)
                } else {
                    cell.config(content: viewModel.messages.value[indexPath.row].content ?? "")
                }
                return cell
                
            } else if viewModel.messages.value[indexPath.row].recall ?? false {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "receiveMessageCell", for: indexPath) as? ReceiveMessageCell
                else { return UITableViewCell() }
                cell.config(content: DefaultConstants.recallMessage)
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
            
        ///Image
        case 1:
            if viewModel.messages.value[indexPath.row].sender?.id == UserDefaults.userInfo?.id {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "imageSenderCell", for: indexPath) as? ImageSenderCell
                else { return UITableViewCell() }
                self.viewModel.getImage(remoteName: self.viewModel.messages.value[indexPath.row].content ?? "") { image in
                    DispatchQueue.main.async {
                        cell.configImage(image: image, imageHeight: self.viewModel.messages.value[indexPath.row].imageHeight ?? 0)
                    }
                }
                return cell
            } else if viewModel.chatType == ChatType.single.rawValue {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "imageReceiverCell", for: indexPath) as? ImageReceiverCell
                else { return UITableViewCell() }
                self.viewModel.getImage(remoteName: self.viewModel.messages.value[indexPath.row].content ?? "") { image in
                    DispatchQueue.main.async {
                        cell.configImage(image: image, imageHeight: self.viewModel.messages.value[indexPath.row].imageHeight ?? 0)
                    }
                }
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "imageReceiverGroupCell", for: indexPath) as? ImageReceiverGroupCell
                else { return UITableViewCell() }
                self.viewModel.getImage(remoteName: self.viewModel.messages.value[indexPath.row].content ?? "") { image in
                    DispatchQueue.main.async {
                        cell.configImage(image: image, imageHeight: self.viewModel.messages.value[indexPath.row].imageHeight ?? 0, name: self.viewModel.messages.value[indexPath.row].sender?.name ?? "")
                    }
                }
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
        let message = viewModel.messages.value[indexPath.row]
        if !(message.recall ?? false) && (message.sender?.id == UserDefaults.userInfo?.id) && (message.type == MessageType.text.rawValue) {
            if message.createdAt?.getSecondsFromPresent() ?? 0 < 3600 {
                self.showRecallSheet(index: indexPath.row)
            } else {
                self.showAlert()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewModel.messages.value[indexPath.row].type == MessageType.image.rawValue {
            if viewModel.chatType == ChatType.group.rawValue && viewModel.messages.value[indexPath.row].sender?.id != UserDefaults.userInfo?.id {
                return CGFloat(viewModel.messages.value[indexPath.row].imageHeight ?? 0) + 25
            } else {
                return CGFloat(viewModel.messages.value[indexPath.row].imageHeight ?? 0) + 10
            }
        } else {
            return UITableView.automaticDimension
        }
    }
}

extension ChatViewController: ChooseNewAdminDelegate {
    func chooseNewAdmin(adminId: String) {
        viewModel.adminId = adminId
    }
}


extension ChatViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        for item in results {
            item.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                if let image = image {
                    self.viewModel.imageSelected = (image as! UIImage).rotate()
                    self.viewModel.uploadImage {
                        DispatchQueue.main.async {
                            self.messageTableView.reloadData()
                        }
                    }
                }
            }
        }
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            self.viewModel.imageSelected = userPickedImage.rotate()
            self.viewModel.uploadImage {
                DispatchQueue.main.async {
                    self.messageTableView.reloadData()
                }
            }
        }
        imagePicked.dismiss(animated: true, completion: nil)
    }
}
