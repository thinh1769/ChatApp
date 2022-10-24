//
//  UserDefaults+Ext.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 21/10/2022.
//

import Foundation

extension UserDefaults {
    private enum Key : String {
        case languageCode = "LanguageCode"
        case theme = "Theme"
        case primaryColor = "PrimaryColor"
        case userRole = "UserRole"
        case userInfo = "UserInfo"
        case deviceToken = "DeviceToken"
        case phoneNumber = "PhoneNumber"
    }
    
    private static let defs = UserDefaults.standard

    static var languageCode: String? {
        get {
            return defs.string(forKey: Key.languageCode.rawValue)
        }
        set(value) {
            if let value = value {
                defs.set(value, forKey: Key.languageCode.rawValue)
                return
            }
            defs.removeObject(forKey: Key.languageCode.rawValue)
        }
    }
    
    static var theme: Int {
        get {
            return defs.integer(forKey: Key.theme.rawValue)
        }
        
        set {
            defs.set(newValue, forKey: Key.theme.rawValue)
        }
    }
    
    static var primaryColor: String? {
        get {
            return defs.string(forKey: Key.primaryColor.rawValue)
        }
        
        set {
            guard let value = newValue else {
                defs.removeObject(forKey: Key.primaryColor.rawValue)
                return
            }
            defs.set(value, forKey: Key.primaryColor.rawValue)
        }
    }
    
    static var userRole: Int? {
        get {
            return defs.integer(forKey: Key.userRole.rawValue)
        }
        
        set {
            guard let value = newValue else {
                defs.removeObject(forKey: Key.userRole.rawValue)
                return
            }
            defs.set(value, forKey: Key.userRole.rawValue)
        }
    }

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
    
    static func getInfo(key: KeyAuth) -> String? {
        return defs.string(forKey: key.rawValue)
    }
    
    static func setInfo(key: KeyAuth, value: String) {
        defs.set(value, forKey: key.rawValue)
    }
    
    static var deviceToken: String? {
        get {
            return defs.string(forKey: Key.deviceToken.rawValue)
        }
        
        set {
            guard let value = newValue else {
                defs.removeObject(forKey: Key.deviceToken.rawValue)
                return
            }
            defs.set(value, forKey: Key.deviceToken.rawValue)
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

