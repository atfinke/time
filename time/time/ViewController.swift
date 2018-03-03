//
//  ViewController.swift
//  time
//
//  Created by Andrew Finke on 3/2/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import Cocoa
import IOKit.ps

class ViewController: NSViewController {

    // MARK: - Properties

    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var effectView: NSVisualEffectView! {
        didSet {
            effectView.wantsLayer = true
        }
    }

    var timer: Timer?

    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    let percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    // MARK: - View Life Cycle

    override func viewWillAppear() {
        super.viewWillAppear()

        firstInterfaceUpdate()

        effectView.layer?.masksToBounds = true
        effectView.layer?.cornerRadius = 5.0

        guard let window = NSApplication.shared.windows.first, let screen = window.screen else {
            fatalError()
        }

        let windowWidth = window.frame.size.width
        let windowHeight = window.frame.size.height

        let x = screen.frame.size.width - windowWidth - 5
        let y = screen.frame.size.height - windowHeight - 5
        let rect = NSMakeRect(x, y, windowWidth, windowHeight)
        window.setFrame(rect, display: true)

        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(firstInterfaceUpdate), name: NSWorkspace.didWakeNotification, object: nil)
    }

    // MARK: - Interface Updates

    @objc func firstInterfaceUpdate() {
        updateInterface()

        let comp =  Calendar.current.dateComponents([.second], from: Date())
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(61 - (comp.second ?? 0)), repeats: false) { [weak self] _ in

            self?.updateInterface()
            Timer.scheduledTimer(timeInterval: 60,
                                 target: self as Any,
                                 selector: #selector(self?.updateInterface),
                                 userInfo: nil,
                                 repeats: true)

        }
    }

    @objc func updateInterface() {
        DispatchQueue.main.async {
            let battery = self.batteyLevel()
            if battery <= 0.20,
                let batteryPercent = self.percentFormatter.string(from: NSNumber(value: battery)) {
                self.textField.stringValue = self.timeFormatter.string(from: Date()).components(separatedBy: " ")[0] + " (" + batteryPercent + ")"
                self.textField.font = NSFont.systemFont(ofSize: 16, weight: .medium)
                self.textField.frame = NSRect(x: 0, y: -11, width: 100, height: 50)
                self.effectView.frame = NSRect(x: 0, y: 10, width: 100, height: 40)
            } else {
                self.textField.stringValue = self.timeFormatter.string(from: Date()).components(separatedBy: " ")[0]
                self.textField.font = NSFont.systemFont(ofSize: 30, weight: .medium)
                self.textField.frame = NSRect(x: 0, y: -7, width: 100, height: 50)
                self.effectView.frame = NSRect(x: 0, y: 0, width: 100, height: 50)
            }
        }
    }

    func batteyLevel() -> Double {
        let powerInfo = IOPSCopyPowerSourcesInfo().takeUnretainedValue()
        guard let powerList = IOPSCopyPowerSourcesList(powerInfo).takeUnretainedValue() as? [[String: Any]],
            let battery = powerList.first else {
                fatalError()
        }
        guard let currentCapactiy = battery[kIOPSCurrentCapacityKey] as? Double,
            let maxCapactiy = battery[kIOPSMaxCapacityKey] as? Double else {
                fatalError()
        }
        return currentCapactiy / maxCapactiy
    }

}

