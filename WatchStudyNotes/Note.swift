//
//  Note.swift
//  WatchStudyNotes
//
//  Created by Weiran Ye on 8/26/15.
//  Copyright (c) 2015 Weiran Ye. All rights reserved.
//

import Foundation
import Cent

struct NoteItem {
    var id: String
    var text: String
    var hideUntil: NSDate
    var isDeleted: Bool
    var createdDate: NSDate
    var lastModifiedDate: NSDate
    
    init(text: String) {
        id = NSUUID().UUIDString
        self.text = text
        hideUntil = 1.day.ago!
        isDeleted = false
        let now = NSDate()
        createdDate = now
        lastModifiedDate = now
    }
    
    init(id: String, text: String, hideUntil: NSDate, isDeleted: Bool, createdDate: NSDate, lastModifiedDate: NSDate) {
        self.id = id
        self.text = text
        self.hideUntil = hideUntil
        self.isDeleted = isDeleted
        self.createdDate = createdDate
        self.lastModifiedDate = lastModifiedDate
    }
    
    var isAvailable: Bool {
        return !isDeleted && hideUntil < NSDate()
    }
}

class NoteList {
    static let sharedInstance = NoteList()
    
    func addItem(item: NoteItem) {
        var noteDict = NSUserDefaults.standardUserDefaults().dictionaryForKey(UserDefaultKey.NoteItems.rawValue) ?? Dictionary()
        noteDict[item.id] = [
            "id": item.id,
            "text": item.text,
            "hideUntil": item.hideUntil,
            "isDeleted": item.isDeleted,
            "createdDate": item.createdDate,
            "lastModifiedDate": item.lastModifiedDate]
        NSUserDefaults.standardUserDefaults().setObject(noteDict, forKey: UserDefaultKey.NoteItems.rawValue)
    }
    
    func hideNote(noteId: String, forNumOfDays: Int) {
        var noteDict = NSUserDefaults.standardUserDefaults().dictionaryForKey(UserDefaultKey.NoteItems.rawValue) ?? Dictionary()
        if var item: AnyObject = noteDict[noteId] {
            noteDict[noteId] = [
                "id": item["id"] as! String,
                "text": item["text"] as! String,
                "hideUntil": forNumOfDays.days.fromNow!,
                "isDeleted": item["isDeleted"] as! Bool,
                "createdDate": item["createdDate"] as! NSDate,
                "lastModifiedDate": NSDate()
            ]
        }
        NSUserDefaults.standardUserDefaults().setObject(noteDict, forKey: UserDefaultKey.NoteItems.rawValue)
    }
    
    func allAvailableItems() -> [NoteItem] {
        var noteDict = NSUserDefaults.standardUserDefaults().dictionaryForKey(UserDefaultKey.NoteItems.rawValue) ?? [:]
        let items = Array(noteDict.values)
        var avaliableItems = [NoteItem]()
        for item in items {
            let i = NoteItem(
                id: item["id"] as! String,
                text: item["text"] as! String,
                hideUntil: item["hideUntil"] as! NSDate,
                isDeleted: item["isDeleted"] as! Bool,
                createdDate: item["createdDate"] as! NSDate,
                lastModifiedDate: item["lastModifiedDate"] as! NSDate)
            if i.isAvailable {
                avaliableItems.append(i)
            }
        }
        return avaliableItems
    }
}
