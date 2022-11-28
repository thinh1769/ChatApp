//
//  UserInfoViewController.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 28/11/2022.
//

import UIKit
import PhotosUI

class UserInfoViewController: UIViewController {
    
    @IBOutlet private weak var avatarImage: UIImageView!
    @IBOutlet private weak var nameTextField: UITextField!
    
    let viewModel = UserInfoViewModel()
    let imagePicked = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        avatarImage.layer.cornerRadius = avatarImage.bounds.width / 2
        avatarImage.isUserInteractionEnabled = true
        avatarImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showMediaSheet)))
        nameTextField.text = viewModel.name
        nameTextField.isUserInteractionEnabled = true
        
        imagePicked.delegate = self
        imagePicked.allowsEditing = false
    }
    
    @IBAction func onClickedBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func showMediaSheet() {
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
    
    private func showImagePickerView() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 2
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
}

extension UserInfoViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        for item in results {
            item.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                if let image = image {
                    self.viewModel.imageSelected = (image as! UIImage).rotate()
                    self.viewModel.updateUserInfo().subscribe { userInfo in
//                        guard let self = self else { return }
                        UserDefaults.userInfo = userInfo
                    }.disposed(by: self.viewModel.bag)
                    DispatchQueue.main.async {
                        self.avatarImage.image = self.viewModel.imageSelected
                    }
                    self.viewModel.uploadImage {
                        DispatchQueue.main.async {
                            self.avatarImage.image = self.viewModel.imageSelected
                            //self.messageTableView.reloadData()
                        }
                    }
                }
            }
        }
    }
}


extension UserInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            self.viewModel.imageSelected = userPickedImage.rotate()
            self.viewModel.uploadImage {
                DispatchQueue.main.async {
                    self.avatarImage.image = self.viewModel.imageSelected
                    //self.messageTableView.reloadData()
                }
            }
        }
        imagePicked.dismiss(animated: true, completion: nil)
    }
}
