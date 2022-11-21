//
//  Asset.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 21/11/2022.
//

import UIKit

protocol Asset {
    var pathFile: String? { get set }
    var thumbnail: UIImage { get set }
    var url: String? { get set }
}
