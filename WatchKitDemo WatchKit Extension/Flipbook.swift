//
//  Flipbook.swift
//  Flipbook
//
//  Created by James Frost on 21/11/2014.
//  Copyright (c) 2014 James Frost. All rights reserved.
//

import Foundation
import UIKit

class Flipbook: NSObject {
    
    private lazy var displayLink: CADisplayLink = CADisplayLink(target: self, selector: "displayLinkTick:")
    
    // The view to capture
    private var targetView: UIView?
    private var duration: NSTimeInterval?
    private var startTime: CFTimeInterval?
    private var imagePrefix: String!
    private var imageCounter = 0
    
    var writeToFiles:Bool = true;
    
    lazy var frames:Array<UIImage> = Array<UIImage>();
    
    override init() {
        
    }
    
    init(writeToFiles: Bool) {
        self.writeToFiles = writeToFiles;
    }
    
    // Render the target view to images for the specified duration
    func renderTargetView(view: UIView, duration: NSTimeInterval, imagePrefix: String, frameInterval: Int = 1) {
        assert(frameInterval >= 1)
        self.targetView = view
        self.duration = duration
        self.imagePrefix = imagePrefix
        
        imageCounter = 0
        displayLink.frameInterval = frameInterval
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        
        println("[Flipbook] Starting capture...")
    }
    
    func renderTargetView(view: UIView, imagePrefix: String, frameCount: Int, updateBlock: (view: UIView, frame: Int) -> Void) {
        self.imagePrefix = imagePrefix
        
        for frame in 0..<frameCount {
            updateBlock(view: view, frame: frame)
            renderViewToImage(view)
        }
        
        println("[Flipbook] Images exported to: \(documentsDirectory()!)")
    }

    func renderDrawing(size: CGSize, scale: Float, duration: NSTimeInterval, drawBlock: (context: CGContextRef, frame: Int, progress: Double) -> Void) {
        let frameCount = lrint(duration * 60.0);//always @60 fps
        
        renderDrawing(size, scale: scale, frameCount: frameCount, drawBlock: drawBlock);
    }
    
    func renderDrawing(size: CGSize, scale: Float, frameCount: Int, drawBlock: (context: CGContextRef, frame: Int, progress: Double) -> Void) {
        UIGraphicsBeginImageContextWithOptions(size, false, CGFloat(scale));
        
        let context = UIGraphicsGetCurrentContext();
        
        for frame in 0..<frameCount {
            CGContextSaveGState(context);
            
            let progress = Double(frame) / Double(frameCount);
            drawBlock(context: context, frame: frame, progress: progress);
            
            let snapshot = UIGraphicsGetImageFromCurrentImageContext();
            
            self.frames.append(snapshot);
            
            CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
            CGContextFlush(context);
            
            CGContextRestoreGState(context);
        }
        
        UIGraphicsEndImageContext();
    }
    
    func displayLinkTick(sender: CADisplayLink) {
        if startTime == nil {
            startTime = sender.timestamp
        }
        
        renderViewToImage(self.targetView)
        
        if sender.timestamp - startTime! > duration {
            sender.invalidate()
            sender.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            
            println("[Flipbook] Images exported to: \(documentsDirectory()!)")
            println("[Flipbook] Capture complete!")
        }
    }
    
    private func newImagePath() -> String? {
        if let documentsDirectory = documentsDirectory() {
            let imagePath = documentsDirectory.stringByAppendingPathComponent(NSString(format: "%@-%d@2x.png", imagePrefix, imageCounter++))
            return imagePath
        }
        
        return nil
    }
    
    private func renderViewToImage(view: UIView?) {
        if let snapshot = view?.snapshotImage() {
            self.frames.append(snapshot);
            
            if (self.writeToFiles == true) {
                if let imagePath = self.newImagePath() {
                    UIImagePNGRepresentation(snapshot).writeToFile(imagePath, atomically: true)
                }
            }
        }
    }
    
    private func documentsDirectory() -> String? {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths.last as? String
    }
}

extension UIView {
    func snapshotImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, opaque, 2.0)

        if (!CGAffineTransformIsIdentity(self.transform)) {
            let rect = self.bounds;
            
            CGContextConcatCTM(UIGraphicsGetCurrentContext(), transform);
        }
    
        let layer: CALayer = self.layer.presentationLayer() as? CALayer ?? self.layer
        layer.renderInContext(UIGraphicsGetCurrentContext())
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image
    }
}
