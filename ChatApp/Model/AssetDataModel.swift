//
//  AssetDataModel.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 21/11/2022.
//

import UIKit

class AssetDataModel: NSObject, Asset {
    var pathFile: String?
    var data = Data()
    var thumbnail = UIImage()
    var url: String?
    var remoteName: String = ""
    var contentType: String = ""
    var compressed: Bool = false
    override init() {
        
    }
    
    
    init(data: Data) {
        self.data = data
        if !data.isEmpty {
            self.contentType = AssetDataModel.mimeType(data)
        }
    }

    init(data: Data, pathFile: String, thumbnail: UIImage) {
        self.data = data
        self.pathFile = pathFile
        self.thumbnail = thumbnail
        if !data.isEmpty {
            self.contentType = AssetDataModel.mimeType(data)
        }
    }
    
    class func mimeType(_ data: Data) -> String {
        var header: UInt8 = 0
        data.copyBytes(to: &header, count: 1)
        switch header {
            case 0xFF:
                return "image/jpeg"
            case 0x89:
                return "image/png"
            case 0x47:
                return "image/gif"
            case 0x4D, 0x49:
                return "image/tiff"
            case 0:
                return "video"
            default:
                return "image/png"
            }
    }
    
    func compressData() {
        if !compressed {
            let maxWidth = CGFloat(480)
            let image = UIImage(data: self.data)!
            let scale = maxWidth/image.size.width
            let newHeight = image.size.height * scale
            let newSize = CGSize(width: maxWidth, height: newHeight)
            let renderer = UIGraphicsImageRenderer(size: newSize)
            let newImage = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: newSize))
            }
            compressed = true
            self.data = newImage.jpegData(compressionQuality: 0.5) ?? Data()
        }
    }
}

