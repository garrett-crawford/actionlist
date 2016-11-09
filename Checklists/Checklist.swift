//
//  Checklist.swift
//  Checklists
//
//  Created by Garrett Crawford on 1/4/16.
//  Copyright © 2016 Noox. All rights reserved.
//

import UIKit

// if you wish to use the NSCoder system on an object (saving data),
// the object needs to implement the NSCoding protocol
// protocol requires two methods
// 'init?(coder), and encodeWithCoder()'
class Checklist: NSObject, NSCoding
{
    var name = ""
    var iconName: String
    var items = [ChecklistItem]()
    
    // farms out work to another init method, it's a convenience initializer
    convenience init(name: String)
    {
        self.init(name: name, iconName: "No Icon")
    }
    
    // desginated initializer
    init(name: String, iconName: String)
    {
        self.name = name
        self.iconName = iconName
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        name = aDecoder.decodeObjectForKey("Name") as! String
        items = aDecoder.decodeObjectForKey("Items") as! [ChecklistItem]
        iconName = aDecoder.decodeObjectForKey("IconName") as! String
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(name, forKey: "Name")
        aCoder.encodeObject(items, forKey: "Items")
        aCoder.encodeObject(iconName, forKey: "IconName")
    }
    
    // this method checks to see how many items in the checklist are not checked
    func countUncheckedItems() -> Int
    {
        var count = 0
        for item in items where !item.checked
        {
            count += 1
        }
        
        return count
    }
}
