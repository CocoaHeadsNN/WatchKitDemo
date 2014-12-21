//
//  InterfaceController.swift
//  WatchKitDemo WatchKit Extension
//
//  Created by iOS Developer on 15.12.14.
//  Copyright (c) 2014 CocoaHeads NN. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet var animatedImageView:WKInterfaceImage?;
    let duration = 1.0;

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        let flipbook = Flipbook(writeToFiles: false);
        
        let drawingSize = CGSizeMake(156, 195);
        
        let image = UIImage(named: "test_image")!;
        
        let text = "cocoaheads" as NSString;
        
        let paragraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as NSMutableParagraphStyle;
        paragraphStyle.alignment = NSTextAlignment.Center;
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByTruncatingMiddle;
        
        let font = UIFont.systemFontOfSize(22);
        
        let textAttributes = [ NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.blackColor(), NSParagraphStyleAttributeName : paragraphStyle ];
        
        flipbook.renderDrawing(drawingSize, scale: 2.0, duration: self.duration) { (context, frame, progress) -> Void in
            let currentWidth = image.size.width * CGFloat(progress);
            let currentHeight = image.size.height * CGFloat(progress);
            
            let rect = CGRectMake(drawingSize.width / 2.0 - currentWidth / 2.0, 50, currentWidth, currentHeight);
            
            image.drawInRect(rect);
            
            let textRect = CGRectMake(0, rect.origin.y + rect.size.height, drawingSize.width, font.lineHeight);
            
            text.drawInRect(textRect, withAttributes: textAttributes);
        };
        
        var imageFrames = Array<UIImage>(flipbook.frames);
        imageFrames += flipbook.frames.reverse();
        
        var animatedImage = UIImage.animatedImageWithImages(imageFrames, duration: self.duration * 2);
        self.animatedImageView?.setImage(animatedImage);
        
        // Configure interface objects here.
        NSLog("%@ awakeWithContext", self)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        NSLog("%@ will activate", self)
        
        let frameCount = lrint(self.duration * 2 * 60.0);

        self.animatedImageView?.startAnimatingWithImagesInRange(NSMakeRange(0, frameCount), duration: self.duration * 2, repeatCount: 0);
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        NSLog("%@ did deactivate", self)
        super.didDeactivate()
    }

}
