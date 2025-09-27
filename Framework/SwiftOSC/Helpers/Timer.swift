//
//  Timer.swift
//  SwiftOSC
//
//  Created by Devin Roth on 7/10/16.
//  Copyright © 2016 Devin Roth Music. All rights reserved.
//

import Foundation

public final class Timer: @unchecked Sendable {
    public static let sharedTime = Timer()

    private let startMachTime: UInt64
    private let startNTP: UInt64
    private let numer: UInt64
    private let denom: UInt64

    public var timetag: UInt64 {
        let time = ((mach_absolute_time() - startMachTime) * numer) / denom
        let seconds = time / 0x1_0000_0000
        let nano = time % 0x1_0000_0000
        var tag = startNTP + ((nano * 0x1_0000_0000) / 1_000_000_000)
        tag += seconds * 0x1_0000_0000
        return tag
    }

    private init() {
        startMachTime = mach_absolute_time()

        var info = mach_timebase_info_data_t()
        mach_timebase_info(&info)
        numer = UInt64(info.numer)
        denom = UInt64(info.denom)

        let calendar = Calendar.current
        let dateComponents = DateComponents(timeZone: TimeZone(secondsFromGMT: 0), year: 1990)
        let date = calendar.date(from: dateComponents)!
        let timeInterval = Date().timeIntervalSince(date)
        startNTP = UInt64(timeInterval * 0x1_0000_0000)
    }
}
