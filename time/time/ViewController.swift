//
//  ViewController.swift
//  time
//
//  Created by Andrew Finke on 3/2/18.
//  Copyright © 2018 Andrew Finke. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    // MARK: - Properties

    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var effectView: NSVisualEffectView! {
        didSet {
            effectView.wantsLayer = true
        }
    }

    let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
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
    }

    // MARK: - Interface Updates

    func firstInterfaceUpdate() {
        updateInterface()

        let comp =  Calendar.current.dateComponents([.second], from: Date())
        Timer.scheduledTimer(withTimeInterval: TimeInterval(60 - (comp.second ?? 0)), repeats: false) { [weak self] _ in

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
            self.textField.stringValue = self.timeFormatter.string(from: Date())
        }
    }

}

