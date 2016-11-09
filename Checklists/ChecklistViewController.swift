//
//  ViewController.swift
//  Checklists
//
//  Created by Garrett Crawford on 12/28/15.
//  Copyright © 2015 Noox. All rights reserved.
//

import UIKit

class ChecklistViewController: UITableViewController, ItemDetailViewControllerDelegate {
    
    // '!' turns 'checklist' into a special kind of optional
    // similar to the '?' optional, but you don't have to write
    // 'if let' to unwrap it
    var checklist: Checklist!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = checklist.name
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // the UITableView object asks its data source (View Controller), how may rows
    // are in the table
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return checklist.items.count
    }
    
    // once the UITableView object knows how many rows to display, it calls this method to
    // obtain cells for those rows
    // it grabs a copy of the prototype cell and gives that back to the table view 
    // prototype cell designed in storyboard
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        // makes a new copy of the prototype cell if necessary or recycles an existing cell that is
        // no longer in use
        // prototype cell designed in storyboard
        let cell = tableView.dequeueReusableCellWithIdentifier("ChecklistItem", forIndexPath: indexPath)
        
        let item = checklist.items[indexPath.row]
        
        configureTextForCell(cell, withChecklistItem: item)
        configureCheckmarkForCell(cell, withChecklistItem: item)
        
        return cell
    }
    
    // called when user taps on a cell in the UITableView
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if let cell = tableView.cellForRowAtIndexPath(indexPath)
        {
            let item = checklist.items[indexPath.row]
            item.toggleChecked()
            
            configureCheckmarkForCell(cell, withChecklistItem: item)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // deleting an item from the table view
    // automatically enables swipe-to-delete
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        // remove item from data model
        checklist.items.removeAtIndex(indexPath.row)
        
        // remove from the table view
        let indexPaths = [indexPath]
        tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
    }
    
    // invoked by UIKit when a segue from one screen to another is about to be performed
    // this allows you to give data to the new view controller before it will
    // be displayed
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        // because there may be more than one segue for a view controller, give each one
        // a unique identifier to make sure you're handling the correct segue
        if segue.identifier == "AddItem"
        {
            // the new view controller can be found in segue.destinationViewController
            // the storyboard shows that the segue does not go directly from ItemDetailViewController
            // but to the navigation controller that embeds it
            let navigationController = segue.destinationViewController as! UINavigationController
            
            // find the ItemDetailViewController by looking at the navigation controller's
            // 'topViewController' property
            // this property refers to the screen that is currently active inside the
            // navigation controller
            let controller = navigationController.topViewController as! ItemDetailViewController
            
            // once a reference is obtained to the ItemDetailViewController object, set its
            // delegate property to self and the connection is complete
            // this tells the ItemDetailViewController that the object known as self
            // is its delegate
            controller.delegate = self
        }
        
        else if segue.identifier == "EditItem"
        {
            let navigationController = segue.destinationViewController as! UINavigationController
            
            let controller = navigationController.topViewController as! ItemDetailViewController
            
            controller.delegate = self
            
            // 'sender' is a reference to the object that calls the 'prepareForSegue' method
            // in this case it is a table view cell whose disclosure button was tapped
            // because it is an optional, it can be nil, so we define a constant to hold the value
            // we use the UITableViewCell object to find the row number by looking up the
            // corresponding index-path using tableView.indexPathForCell
            // the return type is NSIndexPath? (an optional), so we unwrap it using if let
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
            {
                controller.itemToEdit = checklist.items[indexPath.row]
            }
        }
    }
    
    func configureCheckmarkForCell(cell: UITableViewCell, withChecklistItem item: ChecklistItem)
    {
        let label = cell.viewWithTag(1001) as! UILabel
        label.textColor = view.tintColor
        
        if item.checked
        {
            label.text = "√"
        }
        else
        {
            label.text = ""
        }
        
    }
    
    func configureTextForCell(cell: UITableViewCell, withChecklistItem item: ChecklistItem)
    {
        // viewWithTag(Int) grabs the tag value that has been assigned to a view in storyboard
        // using tags is a good substitute for getting references to UI elements without
        // making an @IBOutlet variable for it
        let label = cell.viewWithTag(1000) as! UILabel
        //label.text = item.text
        label.text = "\(item.text)"
    }
    
    // ItemDetailViewControllerProtocol delegation methods
    func itemDetailViewControllerDidCancel(controller: ItemDetailViewController)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func itemDetailViewController(controller: ItemDetailViewController, didFinishAddingItem item: ChecklistItem)
    {
        // add data to model
        let newRowIndex = checklist.items.count
        
        checklist.items.append(item)
        
        // add new cell to row
        let indexPath = NSIndexPath(forRow: newRowIndex, inSection: 0)
        let indexPaths = [indexPath]
        
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // look for the cell that corresponds to the ChecklistItem object and, using
    // configureTextForCell(withChecklistItem), update the label
    func itemDetailViewController(controller: ItemDetailViewController, didFinishEditingItem item: ChecklistItem)
    {
        // must unwrap an optional because the object we are looking for in the array may not exist
        // here we find the row number for the item we are editing in order to make the NSIndexPath
        // that we need to retrieve the cell
        if let index = checklist.items.indexOf(item)
        {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            if let cell = tableView.cellForRowAtIndexPath(indexPath)
            {
                configureTextForCell(cell, withChecklistItem: item)
            }
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}

