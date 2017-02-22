//
//  DragView.swift
//  Image2CSS
//
//  Created by Rory Mulligan on 2/21/17.
//  Copyright © 2017 Rory Mulligan. All rights reserved.
//

import Cocoa

@objc protocol DragViewDelegate {
    @objc optional func dragEntered(_ dragView: DragView)
    @objc optional func dragLeft(_ dragView: DragView)
    @objc optional func dragHappened(_ dragView: DragView, imageType: String, fileUrl: URL)
}

extension URL {
    var typeIdentifier: String? {
        guard isFileURL else { return nil }
        do {
            return try resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier
        } catch let error as NSError {
            print(error.code)
            print(error.domain)
            return nil
        }
    }
}

class DragView: NSView {
    @IBOutlet weak var delegate: DragViewDelegate?
    private var _isDragging = false
    let filteringOptions = [NSPasteboardURLReadingContentsConformToTypesKey:["public.jpeg", "public.gif", "public.png"]]
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        register(forDraggedTypes:  [NSURLPboardType])
    }
    
    func shouldAllowDrag(_ draggingInfo: NSDraggingInfo) -> Bool {
        let pasteBoard = draggingInfo.draggingPasteboard()
        var canAccept = false

        if pasteBoard.canReadObject(forClasses: [NSURL.self], options: filteringOptions) {
            canAccept = true
        }
        
        return canAccept
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if self.shouldAllowDrag(sender) {
            self._isDragging = true
            self.delegate?.dragEntered?(self)
            return .generic
        }
        
        return .every
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        if self._isDragging {
            self._isDragging = false
            self.delegate?.dragLeft?(self)
        }
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if self.shouldAllowDrag(sender) {
            return true
        }
        
        return false
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteBoard = sender.draggingPasteboard()
        
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options:filteringOptions) as? [URL], urls.count == 1 {
            self._isDragging = false
            delegate?.dragHappened?(self, imageType: urls[0].typeIdentifier!, fileUrl: urls[0])
            return true
        }
        
        return false
    }
}
