//
//  HomeViewController.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 25/09/2022.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var homeFriendsCollectionView: UICollectionView!
    @IBOutlet weak var conversationTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var cellSize = 0.0
    var name = ""
    private var viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.receiveMessage { message in
            self.viewModel.chats.accept(self.viewModel.sortChat(self.viewModel.updateChatWhenReceiveNewMessage(message)))
            self.conversationTableView.reloadData()
        }
        
        viewModel.receiveCreateChat { chat in
            var listChat = self.viewModel.chats.value
            if chat.receiver?.id == UserDefaults.userInfo?.id {
                let convertedChat = self.viewModel.updateChatWhenReceiveNewChat(chat)
                listChat.append(convertedChat)
            } else {
                listChat.append(chat)
            }
            self.viewModel.chats.accept(self.viewModel.sortChat(listChat))
            self.setUpTableView(TypeTableCell.chat.rawValue)
        }
        
        searchTextField.rx.controlEvent([.editingDidEnd]).subscribe { [weak self] _ in
            guard let self = self else { return }
            if self.searchTextField.text == "" {
                self.viewModel.typeTable = TypeTableCell.chat.rawValue
                self.setUpTableView(self.viewModel.typeTable)
                self.conversationTableView.reloadData()
            }
        }onError: { _ in
        }
        .disposed(by: viewModel.bag)
        searchTextField.delegate = self
        
        nameLabel.text = name
        setupCollection()
        setUpTableView(TypeTableCell.chat.rawValue)
        setupBinding()
    }
    
    @IBAction func createGroupBtnClicked(_ sender: UIButton) {
        let vc = CreateGroupViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func logoutBtnClicked(_ sender: UIButton) {
        viewModel.logout()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func setupCollection() {
        homeFriendsCollectionView.delegate = self
        homeFriendsCollectionView.dataSource = self
        homeFriendsCollectionView.register(UINib(nibName: "HomeFriendsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "homeFriendsCollectionViewcell")
        homeFriendsCollectionView.backgroundColor = .clear
        cellSize = homeFriendsCollectionView.frame.size.height
        homeFriendsCollectionView.backgroundColor = .clear
    }
    
    func setUpTableView(_ typeTableCell: Int) {
        self.conversationTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        conversationTableView.delegate = self
        conversationTableView.dataSource = self
        if typeTableCell == TypeTableCell.chat.rawValue {
            conversationTableView.register(UINib(nibName: "ConversationTableViewCell", bundle: nil), forCellReuseIdentifier: "conversationTableViewCell")
        } else {
            conversationTableView.register(UINib(nibName: "FriendTableCell", bundle: nil), forCellReuseIdentifier: "friendTableCell")
        }
    }
    
    func setupBinding() {
        viewModel.getAllChats().bind { [weak self] chats in
            guard let self = self else { return }
            self.viewModel.chats.accept(self.viewModel.sortChat(chats))
            self.conversationTableView.reloadData()
        }.disposed(by: viewModel.bag)
    }
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeFriendsCollectionViewcell", for: indexPath) as? HomeFriendsCollectionViewCell else { return UICollectionViewCell() }
        cell.avatarImage.layer.cornerRadius = cellSize/2
        cell.deleteBtn.isHidden = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ChatViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.typeTable == TypeTableCell.chat.rawValue {
            return viewModel.chats.value.count
        } else {
            return viewModel.searchFriendsList.value.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.typeTable == TypeTableCell.chat.rawValue {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "conversationTableViewCell", for: indexPath) as? ConversationTableViewCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            var name = ""
            if viewModel.chats.value[indexPath.row].type == 0 {
                name = viewModel.chats.value[indexPath.row].receiver?.name ?? ""
            } else {
                name = viewModel.chats.value[indexPath.row].chatName ?? ""
            }
            cell.userNameLabel.text = name
            cell.lastMessageLabel.text = viewModel.chats.value[indexPath.row].lastMessage?.content ?? ""
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendTableCell", for: indexPath) as? FriendTableCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.otherUserNameLabel.text = viewModel.searchFriendsList.value[indexPath.row].name
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ChatViewController()
        if viewModel.typeTable == TypeTableCell.chat.rawValue {
            var name = ""
            if viewModel.chats.value[indexPath.row].type == 0 {
                name = viewModel.chats.value[indexPath.row].receiver?.name ?? ""
            } else {
                name = viewModel.chats.value[indexPath.row].chatName ?? ""
            }
            vc.inject(otherUserId: nil, chatId: viewModel.chats.value[indexPath.row].id, chatName: name)
        } else {
            vc.inject(otherUserId: viewModel.searchFriendsList.value[indexPath.row].id, chatId: nil, chatName: viewModel.searchFriendsList.value[indexPath.row].name ?? "")
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: homeFriendsCollectionView.bounds.size.height , height: homeFriendsCollectionView.bounds.size.height )
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let nameOrPhone = searchTextField.text else { return false }
        viewModel.searchFriend(nameOrPhone).subscribe { listUser in
            self.viewModel.searchFriendsList.accept(listUser)
            self.viewModel.typeTable = TypeTableCell.friend.rawValue
            self.setUpTableView(self.viewModel.typeTable)
            self.conversationTableView.reloadData()
        } onError: { _ in
        }.disposed(by: viewModel.bag)
        return true
    }
}
