//
//  Extensions.swift
//  SwiftOSC
//
//  Created by Devin Roth on 7/5/16.
//  Copyright © 2016 Devin Roth Music. All rights reserved.
//

import Foundation

extension Data {
    func toInt32() -> Int32 {
        // Controleer of de data voldoende bytes bevat
        guard self.count >= MemoryLayout<Int32>.size else {
            // Je kunt hier een default waarde retourneren of een fout afhandelen
            return 0
        }
        // Gebruik withUnsafeBytes om veilig de bytes te lezen
        return self.withUnsafeBytes { ptr in
            // Laad de bytes als Int32 en voer byteSwap uit indien nodig
            ptr.load(as: Int32.self).byteSwapped
        }
    }
}

extension Data {
    func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }
}

extension Date {
    // Initialiseert tijd vanuit een string zoals "1990-01-01T00:00:00-00:00"
    init?(_ string: String) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let date = formatter.date(from: string) {
            self = date
        } else {
            return nil
        }
    }
}

extension Date {
    var oscTimetag: Timetag {
        return Timetag(self.timeIntervalSince(Date("1900-01-01T00:00:00-00:00")!) * 0x1_0000_0000)
    }
}

extension Int32 {
    func toData() -> Data {
        var int = self.bigEndian
        return withUnsafeBytes(of: &int) { Data($0) }
    }
}

extension UInt32 {
    func toData() -> Data {
        var int = self.bigEndian
        return withUnsafeBytes(of: &int) { Data($0) }
    }
}

extension Int64 {
    func toData() -> Data {
        var int = self.bigEndian
        return withUnsafeBytes(of: &int) { Data($0) }
    }
}

extension String {
    func toData() -> Data {
        return self.data(using: .utf8)!
    }
    
    // Voeg padding toe aan string om een lengte te bereiken die een veelvoud van 4 is
    func toDataBase32() -> Data {
        var data = self.data(using: .utf8)!
        var value: UInt8 = 0
        let padding = (4 - data.count % 4) % 4
        for _ in 0..<padding {
            data.append(&value, count: 1)
        }
        return data
    }
}

extension String {
    func dataFromHexString() -> Data {
        var data = Data()
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) { match, _, _ in
            if let matchRange = match?.range {
                let byteString = (self as NSString).substring(with: matchRange)
                if let num = UInt8(byteString, radix: 16) {
                    data.append(num)
                }
            }
        }
        return data
    }
}

extension String {
    // Retourneert substring op de opgegeven karakterindex
    subscript(index: Int) -> String? {
        if index < 0 || index >= self.count {
            return nil
        }
        let charIndex = self.index(self.startIndex, offsetBy: index)
        return String(self[charIndex])
    }
}

extension Array {
    public subscript(safe index: UInt) -> Element? {
        return Int(index) < count ? self[Int(index)] : nil
    }
}
