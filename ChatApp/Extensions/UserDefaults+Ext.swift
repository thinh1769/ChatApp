//
//  UserDefaults+Ext.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 21/10/2022.
//

import Foundation

extension UserDefaults {
    private enum Key : String {
        case userInfo = "UserInfo"
        case token = "Token"
        case phoneNumber = "PhoneNumber"
    }
    
    private static let defs = UserDefaults.standard

    static var userInfo: UserInfo? {
        get {
            let data = defs.object(forKey: Key.userInfo.rawValue) as? Data
            guard data != nil else { return nil }
            let info = try? JSONDecoder().decode(UserInfo.self, from: data!)
            return info
        }
        
        set {
            guard let value = newValue else {
                defs.removeObject(forKey: Key.userInfo.rawValue)
                return
            }
            
            let data = try? JSONEncoder().encode(value)
            if data != nil {
                defs.set(data, forKey: Key.userInfo.rawValue)
            }
        }
    }
    
    static var token: String? {
        get {
            return defs.string(forKey: Key.token.rawValue)
        }
        
        set {
            guard let value = newValue else {
                defs.removeObject(forKey: Key.token.rawValue)
                return
            }
            defs.set(value, forKey: Key.token.rawValue)
        }
    }
    
    static var phoneNumber: String? {
        get {
            return defs.string(forKey: Key.phoneNumber.rawValue)
        }
        
        set {
            guard let value = newValue else {
                defs.removeObject(forKey: Key.phoneNumber.rawValue)
                return
            }
            defs.set(value, forKey: Key.phoneNumber.rawValue)
        }
    }
}

