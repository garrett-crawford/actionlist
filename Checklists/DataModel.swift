//
//  DataModel.swift
//  Checklists
//
//  Created by Garrett Crawford on 1/9/16.
//  Copyright © 2016 Noox. All rights reserved.
//

import Foundation

// saving and loading should be in its own data model
// an instance of this class will contain the array of Checklist objects
class DataModel
{
    var lists = [Checklist]()
    
    // computed property
    // when the app tries to read the value of 'indexOfSelectedChecklist', the code
    // in the get block is performed
    // when the app tries to put a new value into 'indexOfSelectedChecklist', the code
    // in the set block is performed
    var indexOfSelectedChecklist: Int
    {
        get
        {
            return NSUserDefaults.standardUserDefaults().integerForKey("ChecklistIndex")
        }
        set
        {
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: "ChecklistIndex")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    // when an instance is made, it will load the the data from the file
    init()
    {
        loadChecklists()
        registerDefaults()
        handleFirstTime()
    }
    
    // method of convenience
    // there is no standard method you can call to get the full path to the documents folder
    // so this is a custom way of getting to it
    func documentsDirectory() -> String
    {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        // print(paths[0])
        return paths[0]
    }
    
    // this uses the custom method 'documentsDirectory()' to construct the full path
    // to the file that will store the checklist items (the apps data)
    // this file is named 'Checklists.plist', and lives inside the Documents directory
    func dataFilePath() -> String
    {
        // cast 'documentsDirectory' to an 'NSString' and call 'stringByAppendingPathComponent'
        // to create a proper file system path to 'Checklists.plist'
        // note that it is important to cast 'documentsDirectory' to an NSString, otherwise
        // it would stay as a String. String != NSString
        return (documentsDirectory() as NSString).stringByAppendingPathComponent("Checklists.plist")
    }
    
    // this method takes the contents of the items array and in two steps converts this
    // into a block of binary data and then writes this data to a file
    func saveChecklists()
    {
        let data = NSMutableData()
        
        // NSKeyedArchiver, a form of NSCoder that creates plist files, encodes
        // the array and all the ChecklistItems in it into some binary data format
        // that can be written to a file
        
        // in order to encode custom objects, you must have the class of the object
        // implement the NSCoding protocol in order to be encoded by NSKeyedArchiver
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(lists, forKey: "Checklists")
        archiver.finishEncoding()
        
        // the data is placed in an NSMutableData object, which will write itself
        // to the file specified by 'dataFilePath()'
        data.writeToFile(dataFilePath(), atomically: true)
    }
    
    func loadChecklists()
    {
        // put the 'dataFilePath()' in the constant 'path'
        let path = dataFilePath()
        
        // check to see if the file exists
        // if there is no Checklists.plist then there are no ChecklistItem objects to load
        if NSFileManager.defaultManager().fileExistsAtPath(path)
        {
            // when the app finds a Checklists.plist file, you load the entire array
            // and its contents fom the file
            if let data = NSData(contentsOfFile: path)
            {
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                
                // NSKeyedUnarchiver decodes the object frozen under the key "ChecklistItems"
                // into an array, but you need to specify to swift that this is an array
                // containing ChecklistItem objects
                lists = unarchiver.decodeObjectForKey("Checklists") as! [Checklist]
                
                unarchiver.finishDecoding()
                sortChecklists()
            }
        }
    }
    
    func registerDefaults()
    {
        // creates a new Dictionary instance and adds some values to store in NSUserDefaults
        let dictionary = [ "ChecklistIndex": -1, "FirstTime": true, "ChecklistItemID": 0 ]
        NSUserDefaults.standardUserDefaults().registerDefaults(dictionary)
    }
    
    // check NSUserDefaults for the value of "FirstTime"
    // if the value for "FirstTime" is true, then this is the first time the app is being run
    // in that case, create a new Checklist object and add it to the lists array
    func handleFirstTime()
    {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let firstTime = userDefaults.boolForKey("FirstTime")
        
        if firstTime
        {
            let checklist = Checklist(name: "List")
            lists.append(checklist)
            
            // set this to 0 so that the app will automatically segue to the new checklist
            // in 'viewDidAppear()'
            // then set the value for "FirstTime" to false, so this code won't be executed again
            // the next time the app starts up
            indexOfSelectedChecklist = 0
            userDefaults.setBool(false, forKey: "FirstTime")
            userDefaults.synchronize()
        }
    }
    
    // here we tell the lists array that the Checklists should be sorted using some formula
    // that formula is provided in the shape of a 'closure'
    // the { } brackets around the sorting code; they are are what make it into a closure
    func sortChecklists()
    {
        // the purpose of the closure is to determine whether one Checklist object comes before another,
        // based on our rules for sorting 
        // the sort algorithm will repeatedly ask one Checklist object from the list how it compares
        // to the other Checklist objects using the formula from the closure, and then shuffles
        // them around until the array is sorted
        lists.sortInPlace({ checklist1, checklist2 in return
            checklist1.name.localizedStandardCompare(checklist2.name) == .OrderedAscending })
    }
    
    // this method gets the current "ChecklistItemID" value from NSUserDefaults,
    // adds one to it, and writes it back to NSUserDefaults
    // this is also an example of a 'class method', which can be
    // called without a direct reference to an instance of this class
    class func nextChecklistItemID() -> Int
    {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let itemID = userDefaults.integerForKey("ChecklistItemID")
        userDefaults.setInteger(itemID + 1, forKey: "ChecklistItemID")
        userDefaults.synchronize()
        return itemID
    }
}
