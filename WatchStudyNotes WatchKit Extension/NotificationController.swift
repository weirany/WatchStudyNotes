//
//  NotificationController.swift
//  WatchStudyNotes WatchKit Extension
//
//  Created by Weiran Ye on 8/29/15.
//  Copyright (c) 2015 Weiran Ye. All rights reserved.
//

import WatchKit
import Foundation


class NotificationController: WKUserNotificationInterfaceController {

    @IBOutlet weak var noteLabel: WKInterfaceLabel!
    
    override init() {
        // Initialize variables here.
        super.init()
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    override func didReceiveLocalNotification(localNotification: UILocalNotification, withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        let text = localNotification.alertBody!
        let numOfChar = count(text)
        // this is the formular to get the best scale.
        let fontSize = numOfChar < 10 ? 32 : CGFloat(32 / log10(Double(numOfChar)))
        let adaptiveFont = UIFont.systemFontOfSize(fontSize)
        var fontAttrs = [NSFontAttributeName : adaptiveFont]
        var attrString = NSAttributedString(string: text, attributes: fontAttrs)
        noteLabel.setAttributedText(attrString)
        completionHandler(.Custom)
    }
    
    /*
    override func didReceiveRemoteNotification(remoteNotification: [NSObject : AnyObject], withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        // This method is called when a remote notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        //
        // After populating your dynamic notification interface call the completion block.
        completionHandler(.Custom)
    }
    */
}
