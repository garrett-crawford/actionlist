//
//  ChecklistItem.swift
//  Checklists
//
//  Created by Garrett Crawford on 12/29/15.
//  Copyright © 2015 Noox. All rights reserved.
//

import Foundation
import UIKit

// here we declare this as a subclass of 'NSObject' so that 
// we can compare ChecklistItem objects to objects we
// are looking for in the items array in ChecklistViewController

class ChecklistItem: NSObject, NSCoding
{
    var text = ""
    var checked = false
    var dueDate = NSDate()
    var shouldRemind = false
    var itemID: Int
    
    // use this when creating a ChecklistItem object
    override init()
    {
        // asks the DataModel for a new item ID when a new ChecklistItem is created
        itemID = DataModel.nextChecklistItemID()
        super.init()
    }
    
    // this is the method required from unfreezing the objects from the file
    // objects that have been saved to the file
    // use this when restoring ChecklistItems that were saved to disk
    required init?(coder aDecoder: NSCoder)
    {
        text = aDecoder.decodeObjectForKey("Text") as! String
        checked = aDecoder.decodeBoolForKey("Checked")
        dueDate = aDecoder.decodeObjectForKey("DueDate") as! NSDate
        shouldRemind = aDecoder.decodeBoolForKey("ShouldRemind")
        itemID = aDecoder.decodeIntegerForKey("ItemID")
        super.init()
    }
    
    // called right before an object is to be deleted 
    // simply cancels the local notification associated with the item, if it has one
    deinit
    {
        if let notification = notificationForThisItem()
        {
            print("Removing exisiting notification \(notification)")
            UIApplication.sharedApplication().cancelLocalNotification(notification)
        }
    }
    
    // when NSKeyedArchiver tries to encode the ChecklistItem object,
    // it will send an encodeWithCoder(coder) message
    // this is for saving ChecklistItem objects to the disk
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(text, forKey: "Text")
        aCoder.encodeBool(checked, forKey: "Checked")
        aCoder.encodeObject(dueDate, forKey: "DueDate")
        aCoder.encodeBool(shouldRemind, forKey: "ShouldRemind")
        aCoder.encodeInteger(itemID, forKey: "ItemID")
    }
    
    func toggleChecked()
    {
        checked = !checked
    }
    
    func scheduleNotification()
    {
        let existingNotification = notificationForThisItem()
        if let notification = existingNotification
        {
            print("Found an exisiting notification \(notification)")
            UIApplication.sharedApplication().cancelLocalNotification(notification)
        }
        
        // this compares the due date on the item with the current date
        // a new instance of NSDate contains the current date
        // dueDate.compare(NSDate()) compares the two dates and returns a value from
        // the NSComparisonResult enum
        // .OrderAscending: dueDate comes before the current date and time
        if shouldRemind && dueDate.compare(NSDate()) != .OrderedAscending
        {
            let localNotification = UILocalNotification()
            localNotification.fireDate = dueDate
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            localNotification.alertBody = text
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.userInfo = ["ItemID": itemID]
            
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            
            print("Scheduled notification \(localNotification) for itemID \(itemID)")
            
        }
    }
    
    // this asks UIApplication for a list of all scheduled notifications
    // then it loops through that list and looks at each notification one-by-one
    // the notification should have an "ItemID" value inside the userInfo dictionary
    // if that value exists and equals the itemID property, then you've found the notification
    // that belongs to this ChecklistItem
    func notificationForThisItem() -> UILocalNotification?
    {
        let allNotifications = UIApplication.sharedApplication().scheduledLocalNotifications!
        
        for notification in allNotifications
        {
            if let number = notification.userInfo?["ItemID"] as? Int where number == itemID
            {
                return notification
            }
        }
        
        return nil
    }
}