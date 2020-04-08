//
//  ViewController.swift
//  time
//
//  Created by Andrew Finke on 3/2/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    // MARK: - Interface Elements -

    var timeTextField: NSTextField = {
        let textField = NSTextField()
        textField.alignment = .center
        textField.textColor = .white
        textField.isBezeled = false
        textField.isEditable = false
        textField.drawsBackground = false
        return textField
    }()

    var batteryTextField: NSTextField = {
        let textField = NSTextField()
        textField.alignment = .center
        textField.textColor = .white
        textField.isBezeled = false
        textField.isEditable = false
        textField.drawsBackground = false
        textField.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .medium)
        return textField
    }()

    var circleTextField: NSTextField = {
        let textField = NSTextField()
        textField.alignment = .center
        textField.textColor = .white
        textField.isBezeled = false
        textField.isEditable = false
        textField.drawsBackground = false
        textField.stringValue = "88"
        textField.font = NSFont.systemFont(ofSize: 10, weight: .medium)
        return textField
    }()
    
    @IBOutlet weak var effectView: NSVisualEffectView! {
        didSet {
            effectView.wantsLayer = true
        }
    }

    // MARK: - Properties -

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

    var screenFrame: NSRect {
        guard let screenFrame = NSScreen.main?.visibleFrame else {
            fatalError()
        }
        return screenFrame
    }

    var isBatteryInfoDisplayed: Bool {
        return batteryState().level <= Design.showBatteryInfoLevel
    }

    var visibleWindowFrame: NSRect {
        let height: CGFloat
        if isBatteryInfoDisplayed {
            height = Design.windowExpandedHeight
        } else {
            height = Design.windowHeight
        }
        return NSRect(x: screenFrame.maxX - Design.windowWidth + Design.windowOffset,
                      y: screenFrame.maxY - height + Design.windowOffset,
                      width: Design.windowWidth,
                      height: height)
    }

    var offScreenWindowFrame: NSRect {
        return NSRect(x: screenFrame.maxX - Design.windowPeek,
                      y: screenFrame.maxY - Design.windowPeek,
                      width: visibleWindowFrame.width,
                      height: visibleWindowFrame.height)
    }

    var isVisible = false
    var isDelayingUpdates = false
    var needsToAlertLowBattery = true
    var minuteAlignmentTimer: Timer?

    // MARK: - View Life Cycle -

    override func viewWillAppear() {
        super.viewWillAppear()

        firstInterfaceUpdate()

        guard let view = self.view as? TrackingView else {
            fatalError()
        }
        view.mouseExited = mouseExited
        view.mouseEntered = mouseEntered

        NSWorkspace.shared.notificationCenter.addObserver(self,
                                                          selector: #selector(firstInterfaceUpdate),
                                                          name: NSWorkspace.didWakeNotification,
                                                          object: nil)
    }

    // MARK: - Interface Updates -

    @objc func firstInterfaceUpdate() {
        effectView.layer?.masksToBounds = true
        effectView.layer?.cornerRadius = 10
 
        view.addSubview(timeTextField)
        view.addSubview(batteryTextField)

        updateInterface()

        let comp = Calendar.current.dateComponents([.second], from: Date())
        minuteAlignmentTimer?.invalidate()
        let nextMinute = TimeInterval(60.1 - Double(comp.second ?? 0))
        minuteAlignmentTimer = Timer.scheduledTimer(withTimeInterval: nextMinute, repeats: false) { [weak self] _ in
            self?.updateInterface()
            Timer.scheduledTimer(timeInterval: 60,
                                 target: self as Any,
                                 selector: #selector(self?.updateInterface),
                                 userInfo: nil,
                                 repeats: true)
        }
    }

    @objc func updateInterface() {
        let battery = batteryState()
        guard let window = NSApplication.shared.windows.first,
            let batteryDisplayPercent = percentFormatter.string(from: NSNumber(value: Double(battery.level))) else {
            fatalError()
        }

        // Show Battery
        if battery.level > Design.showBatteryInfoLevel {
            needsToAlertLowBattery = true
        }
        if needsToAlertLowBattery && battery.level < Design.showBatteryInfoLevel {
            needsToAlertLowBattery = false
            isVisible = true
        }

        // Animating transition
        timeTextField.animator().isHidden = !isVisible
        batteryTextField.animator().isHidden = !isVisible || !isBatteryInfoDisplayed

        let frame = isVisible ? visibleWindowFrame : offScreenWindowFrame
        window.setFrame(frame,
                        display: true,
                        animate: true)
        timeTextField.font = isBatteryInfoDisplayed ? Design.timeExpandedFont : Design.timeFont
        timeTextField.stringValue = timeFormatter.string(from: Date())
        
        let dividers = battery.isCharging ? "++" : "--"
        batteryTextField.stringValue = "\(dividers) \(batteryDisplayPercent) \(dividers)"

        timeTextField.sizeToFit()
        batteryTextField.sizeToFit()

        let availableHeight = window.frame.height - Design.windowOffset
        let timeTextFieldHeight = timeTextField.frame.height
        let timeTextFieldY = availableHeight
            - Design.windowTextFieldOffset
            - timeTextFieldHeight

        timeTextField.frame = NSRect(x: 2,
                                     y: timeTextFieldY,
                                     width: Design.windowWidth - Design.windowOffset,
                                     height: timeTextField.frame.height)

        let batteryTextFieldHeight = batteryTextField.frame.height
        let batteryTextFieldY = timeTextFieldY - batteryTextFieldHeight
        batteryTextField.frame = NSRect(x: 2,
                                        y: batteryTextFieldY,
                                        width: Design.windowWidth - Design.windowOffset,
                                        height: batteryTextField.frame.height)

        }

    // MARK: - TrackingView Updates -

    func mouseExited() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.isDelayingUpdates = false
        }
    }

    func mouseEntered() {
        guard !isDelayingUpdates else { return }
        isDelayingUpdates = true
        isVisible.toggle()
        updateInterface()
    }
}


