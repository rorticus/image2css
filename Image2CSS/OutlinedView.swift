//
//  OutlinedView.swift
//  Image2CSS
//
//  Created by Rory Mulligan on 2/21/17.
//  Copyright © 2017 Rory Mulligan. All rights reserved.
//

import Cocoa

class OutlinedView: NSView {
    var outlineColor = NSColor.white {
        didSet {
            self.setNeedsDisplay(self.bounds)
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let strokeWidth: CGFloat = 5.0
        
        //// Rectangle Drawing
        let rectanglePath = NSBezierPath(roundedRect: self.bounds.insetBy(dx: strokeWidth / 2, dy: strokeWidth / 2), xRadius: strokeWidth, yRadius: strokeWidth)
        outlineColor.setStroke()
        rectanglePath.lineWidth = strokeWidth
        rectanglePath.setLineDash([strokeWidth * 2, strokeWidth], count: 2, phase: 0)
        rectanglePath.stroke()
    }
    
}
