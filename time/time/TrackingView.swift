//
//  TrackingView.swift
//  time
//
//  Created by Andrew Finke on 9/22/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import AppKit

class TrackingView: NSView {

    // MARK: - Properties -

    var mouseEntered: (() -> Void)?
    var mouseExited: (() -> Void)?

    private var trackingArea: NSTrackingArea?

    // MARK: - Overrides -

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        if let trackingArea = self.trackingArea {
            removeTrackingArea(trackingArea)
        }

        let options: NSTrackingArea.Options = [
            .mouseEnteredAndExited,
            .activeAlways
        ]
        let trackingArea = NSTrackingArea(rect: bounds,
                                          options: options,
                                          owner: self,
                                          userInfo: nil)
        addTrackingArea(trackingArea)
    }

    override func mouseEntered(with event: NSEvent) {
        mouseEntered?()
    }

    override func mouseExited(with event: NSEvent) {
        mouseExited?()
    }
}
