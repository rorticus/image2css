//
//  AppDelegate.swift
//  Image2CSS
//
//  Created by Rory Mulligan on 2/21/17.
//  Copyright © 2017 Rory Mulligan. All rights reserved.
//

import Cocoa

enum ImageType {
    case PNG
    case JPG
    case GIF
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, DragViewDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var outlineView: OutlinedView!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        self.window.titleVisibility = .hidden
        self.window.titlebarAppearsTransparent = true
        self.window.isMovableByWindowBackground = true
        self.window.backgroundColor = NSColor.black
        
        if let view = self.window.contentView as? DragView {
            view.delegate = self
        }
        
        setUIForAcceptingDrag()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func setUIForAcceptingDrag() {
        label.stringValue = "Drag a file or \npaste into this box"
        outlineView.outlineColor = NSColor.white
    }
    
    func setUIForAcceptingDrop() {
        label.stringValue = "Now drop it!"
        outlineView.outlineColor = NSColor.green
    }
    
    func dragEntered(_ dragView: DragView) {
        setUIForAcceptingDrop()
    }
    
    func dragLeft(_ dragView: DragView) {
        setUIForAcceptingDrag()
    }
    
    func dragHappened(_ dragView: DragView, imageType: String, fileUrl: URL) {
        var type:ImageType = .PNG
        
        if imageType == "public.jpeg" {
            type = .JPG
        }
        else if imageType == "public.gif" {
            type = .GIF
        }
        
        do {
            try processImage(imageType: type, imageData: NSData(contentsOf: fileUrl))
        } catch {
        }
        
        // read the file and process it
        setUIForAcceptingDrag()
    }
    
    func paste(_ sender: AnyObject) {
        let pasteboard = NSPasteboard.general()
        
        let images = pasteboard.readObjects(forClasses: [NSImage.self], options: nil) as! [NSImage]
        
        if images.count > 0 {
            let image = images[0]
            
            let rep = NSBitmapImageRep(cgImage: image.cgImage(forProposedRect: nil, context: nil, hints: nil)!)
            let imageData = rep.representation(using: NSBitmapImageFileType.PNG, properties: [:])
            
            processImage(imageType: .PNG, imageData: NSData.init(data: imageData!))
        }
    }
    
    func processImage(imageType: ImageType, imageData: NSData) {
        var contentType = ""
        
        if imageType == .PNG {
            contentType = "image/png"
        } else if imageType == .JPG {
            contentType = "image/jpg"
        } else if imageType == .GIF {
            contentType = "image/gif"
        }
        
        let css = "url(data:\(contentType);base64,\(imageData.base64EncodedString(options: .init(rawValue: 0))))"
        let pasteboard = NSPasteboard.general()
        pasteboard.clearContents()
        pasteboard.setString(css, forType: NSPasteboardTypeString)
        
        let notification = NSUserNotification()
        notification.title = "CSS Ready!"
        notification.informativeText = "A CSS data url was copied to your clipboard."
        
        NSUserNotificationCenter.default.deliver(notification)
    }
}

