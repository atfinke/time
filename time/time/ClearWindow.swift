//
//  ClearWindow.swift
//  time
//
//  Created by Andrew Finke on 11/3/19.
//  Copyright © 2019 Andrew Finke. All rights reserved.
//

import Cocoa

class ClearWindow: NSWindow {

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {

        super.init(contentRect: contentRect, styleMask: .borderless, backing: .buffered, defer: false)

        isOpaque = false
        backgroundColor = NSColor.clear
        isMovableByWindowBackground = false
        level = .floating
        hasShadow = false

        collectionBehavior = .canJoinAllSpaces

    }

}
