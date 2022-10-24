//
//  HomeViewController.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 25/09/2022.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var homeFriendsCollectionView: UICollectionView!
    @IBOutlet weak var conversationTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var cellSize = 0.0
    var name = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = name
        setupCollectionAndTableView()
    }
    
    @IBAction func logoutBtnClicked(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    func setupCollectionAndTableView() {
        homeFriendsCollectionView.delegate = self
        homeFriendsCollectionView.dataSource = self
        homeFriendsCollectionView.register(UINib(nibName: "HomeFriendsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "homeFriendsCollectionViewcell")
        homeFriendsCollectionView.backgroundColor = .clear
        cellSize = homeFriendsCollectionView.frame.size.height
        
        self.conversationTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        conversationTableView.delegate = self
        conversationTableView.dataSource = self
        conversationTableView.register(UINib(nibName: "ConversationTableViewCell", bundle: nil), forCellReuseIdentifier: "conversationTableViewCell")
        homeFriendsCollectionView.backgroundColor = .clear
    }
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeFriendsCollectionViewcell", for: indexPath) as? HomeFriendsCollectionViewCell else { return UICollectionViewCell() }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ChatViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "conversationTableViewCell", for: indexPath) as? ConversationTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ChatViewController()
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
