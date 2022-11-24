//
//  String+Ext.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 18/11/2022.
//

import Foundation
extension String {
    func getSecondsFromPresent() -> Double {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DefaultConstants.dateFormat
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC+00")
        let currentDate = Date()
        guard let time = dateFormatter.date(from: self) else { return 0 }
        let elapsedSecond = currentDate.timeIntervalSince(time)
        let seconds = floor(elapsedSecond)
        return seconds
    }
}
