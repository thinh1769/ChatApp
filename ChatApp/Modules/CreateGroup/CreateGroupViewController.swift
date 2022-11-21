//
//  CreateGroupViewController.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 30/10/2022.
//

import UIKit

//protocol CreateGroupDelegate: AnyObject {
//    func createGroup(adminId: String)
//}

class CreateGroupViewController: UIViewController {

    @IBOutlet weak var viewOfSelectedFriends: UIView!
    @IBOutlet weak var createGroupBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var searchContactTextField: UITextField!
    @IBOutlet weak var selectedFriendsCollectionView: UICollectionView!
    @IBOutlet weak var friendsTableView: UITableView!
    
    //weak var delegate: CreateGroupDelegate?
    var viewModel = CreateGroupViewModel()
    var cellSize = 0.0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupCollectionView()
        viewOfSelectedFriends.isHidden = true
    }
    
    private func setupUI() {
        searchContactTextField.rx.controlEvent([.editingDidEnd]).subscribe { [weak self] _ in
            guard let self = self else { return }
            if self.searchContactTextField.text == "" {
                self.viewModel.searchFriendsList.accept([])
                self.friendsTableView.reloadData()
            }
        }onError: { _ in
        }
        .disposed(by: viewModel.bag)
        
        searchContactTextField.delegate = self
    }
    
    @IBAction func onClickedCreateGroupBtn(_ sender: UIButton) {
        if let chatName = groupNameTextField.text, chatName.count > 0 && viewModel.selectedFriendsList.value.count > 1 {
            viewModel.postChat(users: viewModel.selectedFriendsList.value, chatName: chatName).subscribe { [weak self] chat in
                guard let self = self else { return }
                self.viewModel.sendMessage(Message(type: 2, content: "\(UserDefaults.userInfo?.name ?? "") vừa tạo nhóm", chatId: chat.id))
                self.navigationController?.popViewController(animated: true)
            } onError: { _ in
            } .disposed(by: viewModel.bag)
        } else if let chatName = groupNameTextField.text, chatName.count == 0 {
            showAlert(message: DefaultConstants.requireNameGroup)
        } else if viewModel.selectedFriendsList.value.count <= 1 {
            showAlert(message: DefaultConstants.requireNumberOfMember)
        }
    }
    
    @IBAction func onClickedBackBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupTableView() {
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
        friendsTableView.register(UINib(nibName: "FriendTableCell", bundle: nil), forCellReuseIdentifier: "friendTableCell")
    }
    
    private func setupCollectionView() {
        selectedFriendsCollectionView.delegate = self
        selectedFriendsCollectionView.dataSource = self
        selectedFriendsCollectionView.register(UINib(nibName: "HomeFriendsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "homeFriendsCollectionViewcell")
        selectedFriendsCollectionView.backgroundColor = .clear
        cellSize = selectedFriendsCollectionView.frame.size.height
        selectedFriendsCollectionView.backgroundColor = .clear
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: DefaultConstants.alertTitle, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: DefaultConstants.ok, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    
}

///---------TableView Delegate & DataSource
extension CreateGroupViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !viewModel.checkSelectedFriend(viewModel.searchFriendsList.value[indexPath.row].id ?? "") {
            var list = viewModel.selectedFriendsList.value
            list.append(viewModel.searchFriendsList.value[indexPath.row].id ?? "")
            viewModel.selectedFriendsList.accept(list)
            viewOfSelectedFriends.isHidden = false
            selectedFriendsCollectionView.reloadData()
        }
    }
}

extension CreateGroupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchFriendsList.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendTableCell", for: indexPath) as? FriendTableCell else { return UITableViewCell() }
        cell.config(name: viewModel.searchFriendsList.value[indexPath.row].name ?? "", false, false)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

///------------CollectionView Delegate & DataSource
extension CreateGroupViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.selectedFriendsList.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeFriendsCollectionViewcell", for: indexPath) as? HomeFriendsCollectionViewCell else { return UICollectionViewCell() }
        
        cell.avatarImage.layer.cornerRadius = cellSize/2
        cell.deleteButtonDidTappedAtIndex = { [weak self] in
            guard let self = self else { return }
            self.viewModel.removeSelectedFriend(index: indexPath.row)
            if self.viewModel.selectedFriendsList.value.count == 0 {
                self.viewOfSelectedFriends.isHidden = true
            }
            self.selectedFriendsCollectionView.reloadData()
        }
        
        return cell
    }
}

extension CreateGroupViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: selectedFriendsCollectionView.bounds.size.height , height: selectedFriendsCollectionView.bounds.size.height )
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
}

///---------------UITextFieldDelegate
extension CreateGroupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let nameOrPhone = searchContactTextField.text else { return false }
        viewModel.searchFriend(nameOrPhone).subscribe { listUser in
            self.viewModel.searchFriendsList.accept(listUser)
            self.friendsTableView.reloadData()
        } onError: { _ in
        }.disposed(by: viewModel.bag)
        return true
    }
}
