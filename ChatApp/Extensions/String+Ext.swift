//
//  String+Ext.swift
//  ChatApp
//
//  Created by Nguyễn Thịnh on 18/11/2022.
//

import Foundation
extension String {
    func getMinutesFromPresent() -> Double {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DefaultConstants.dateFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC+00")
        let currentDate = Date()
        guard let time = dateFormatter.date(from: self) else { return 0 }
        let elapsedMinute = currentDate.timeIntervalSince(time)
        let minutes = floor(elapsedMinute / 60)
        return minutes
    }
}
