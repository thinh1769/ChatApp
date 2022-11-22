//
//  ImageCache.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 22/11/2022.
//

import Foundation

class ImageCache {
    static let MAX_IMAGE = 50
    
    static private var fileManager = FileManager.default
    
    static func getImageCache(title: String) -> Data? {
        let path = fileManager.temporaryDirectory.appendingPathComponent(title)
        let data = try? Data(contentsOf: path)
        return data
    }
    
    static func cacheImage(title: String, data: Data) {
        if !data.isEmpty {
            let path = fileManager.temporaryDirectory.appendingPathComponent(title)
            do {
                try? data.write(to: path)
            }
        }
    }
    
    static func isCached(title: String) -> Bool {
        let path = fileManager.temporaryDirectory.appendingPathComponent(title)
        return FileManager.default.fileExists(atPath: path.relativePath)
    }
    
    static func removeCache(title: String) {
        if isCached(title: title) {
            let path = fileManager.temporaryDirectory.appendingPathComponent(title)
            try? FileManager.default.removeItem(at: path)
        }
    }
    
    static func clearAll() {
        fileManager.clearTmpDirectory()
    }
}

extension FileManager {
    func clearTmpDirectory() {
        do {
            let tmpDirectory = try contentsOfDirectory(atPath: NSTemporaryDirectory())
            try tmpDirectory.forEach {[unowned self] file in
                let path = String.init(format: "%@%@", NSTemporaryDirectory(), file)
                try self.removeItem(atPath: path)
            }
        } catch {
            print(error)
        }
    }
}
