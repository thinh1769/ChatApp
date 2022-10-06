//
//  HomeViewController.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 25/09/2022.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var homeFriendsCollectionView: UICollectionView!
    @IBOutlet weak var conversationTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var cellSize = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionAndTableView()
        
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
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
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "conversationTableViewCell", for: indexPath) as? ConversationTableViewCell else { return UITableViewCell() }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.pushViewController(ChatViewController(), animated: true)
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
