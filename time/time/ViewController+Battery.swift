//
//  ViewController+Battery.swift
//  time
//
//  Created by Andrew Finke on 9/22/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import Cocoa
import IOKit.ps

extension ViewController {
    func batteryState() -> (level: Float, isCharging: Bool) {
        let powerInfo = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        guard let powerList = IOPSCopyPowerSourcesList(powerInfo).takeRetainedValue() as? [[String: Any]],
            let battery = powerList.first else {
                fatalError()
        }
        guard let currentCapactiy = battery[kIOPSCurrentCapacityKey] as? Double,
            let maxCapactiy = battery[kIOPSMaxCapacityKey] as? Double,
            let isCharging = battery[kIOPSIsChargingKey] as? Bool else {
                fatalError()
        }
        let charge = NSNumber(value: currentCapactiy / maxCapactiy)
        return (charge.floatValue, isCharging)
    }

}
