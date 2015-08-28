//
//  HomeViewController.swift
//  WatchStudyNotes
//
//  Created by Weiran Ye on 8/26/15.
//  Copyright (c) 2015 Weiran Ye. All rights reserved.
//

import UIKit
import Cent

class HomeViewController: BaseViewController {

    @IBOutlet weak var newNoteText: UITextView!
    @IBOutlet weak var frequenceText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newNoteText.layer.borderColor = UIColor.turquoiseColor().CGColor
        newNoteText.layer.borderWidth = 1.0;
        newNoteText.layer.cornerRadius = 8;
        
        if Util.stringUserDefault(UserDefaultKey.FrequenceInMinutes) == nil {
            Util.setUserDefault(UserDefaultKey.FrequenceInMinutes, value: "1000")
            updateFrequence(1000)
        }
        frequenceText.text = Util.stringUserDefault(UserDefaultKey.FrequenceInMinutes)!
        frequenceText.layer.borderColor = UIColor.turquoiseColor().CGColor
        frequenceText.layer.borderWidth = 1.0;
        frequenceText.layer.cornerRadius = 8;
        
        updateSchedule()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func saveClicked(sender: AnyObject) {
        if var text = newNoteText.text {
            text = text.strip()
            let newNote = NoteItem(text: text)
            NoteList.sharedInstance.addItem(newNote)
            updateSchedule()
            
            // clear up
            newNoteText.text = ""
            self.showMessageBox("Done", message: "Save successfully! ")
        }
    }
    
    @IBAction func clearClicked(sender: AnyObject) {
        newNoteText.text = ""
    }
    
    func updateSchedule() {
        // remove all scheduled notifications
        UIApplication.sharedApplication().scheduledLocalNotifications.removeAll(keepCapacity: true)
        var items = NoteList.sharedInstance.allAvailableItems()
        if items.count == 0 { return }
        let frequencInMinutes = Util.stringUserDefault(UserDefaultKey.FrequenceInMinutes)!.toInt()!
        for i in 1...Constants.MaxLocalNotifications {
            let randomIndex = Util.randInRange(0, upperExclude: items.count)
            addNotification(items[randomIndex], minutesFromNow: frequencInMinutes * i)
        }
    }
    
    func addNotification(item: NoteItem, minutesFromNow: Int) {
        var notification = UILocalNotification()
        notification.alertBody = item.text
        notification.alertAction = "read"
        notification.fireDate = minutesFromNow.minute.fromNow
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["UUID": item.id, ]
        notification.category = "myCategory"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    @IBAction func frequenceChanged(sender: AnyObject) {
        let frequenceStr = (sender as! UITextField).text
        if frequenceStr.strip() == "" || frequenceStr.toInt() <= 0 {
            frequenceText.text = Util.stringUserDefault(UserDefaultKey.FrequenceInMinutes)
            self.showMessageBox("Error", message: "Not a valid frequence.")
        }
        else {
            let freq = frequenceStr.toInt()!
            updateFrequence(freq)
        }
    }
    
    func updateFrequence(newFrequenceInMinutes: Int) {
        Util.setUserDefault(UserDefaultKey.FrequenceInMinutes, value: String(newFrequenceInMinutes))
        updateSchedule()
    }
}
