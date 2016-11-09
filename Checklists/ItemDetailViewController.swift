//
//  ItemDetailViewController.swift
//  Checklists
//
//  Created by Garrett Crawford on 1/1/16.
//  Copyright © 2016 Noox. All rights reserved.
//

import Foundation
import UIKit

// delegates go hand in hand with protocols
// this defines the ItemDetailViewControllerDelegate protocol
// this is essentially a contract between this view controller and any other 
// view controller that wishes to use it

// a protocol doesn't implement any methods that it declares
// any object that conforms to this protocol must implement the declared methods
protocol ItemDetailViewControllerDelegate: class
{
    func itemDetailViewControllerDidCancel(controller: ItemDetailViewController)
    func itemDetailViewController(controller: ItemDetailViewController, didFinishAddingItem item: ChecklistItem)
    func itemDetailViewController(controller: ItemDetailViewController, didFinishEditingItem item: ChecklistItem)
}

// UITextFieldDelegate makes this View Controller a delegate for the text field
class ItemDetailViewController: UITableViewController, UITextFieldDelegate
{
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerCell: UITableViewCell!
    
   
    var dueDate = NSDate()
    
    var datePickerVisible = false
    
    // this property allows the view controller to refer to its delegate
    weak var delegate: ItemDetailViewControllerDelegate?
    
    // contains the existing item the user will edit
    // when adding a new item, this will be nil
    // that is how the view controller will make the distinction between adding and editing
    // which is why the variable must be declared as an optional, '?'
    var itemToEdit: ChecklistItem?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // you cannot use optionals like regular variables
        // in order to use it you must unwrap the optional with the following syntax:
        // if let temporaryConstant = optionalVariable
        // if we don't unwrap the optional and use the variable directly, the compiler will complain
        if let item = itemToEdit
        {
            title = "Edit Item"
            textField.text = item.text
            doneBarButton.enabled = true
            shouldRemindSwitch.on = item.shouldRemind
            dueDate = item.dueDate
        }
        
        updateDueDateLabel()
    }
    
    // this method is called just before the view controller becomes visible
    // this method will pop up the keyboard
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 1 && datePickerVisible
        {
            return 3
        }
        
        else
        {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    // this method is only necessary for the UIDatePicker object to be displayed on this screen
    // because we are using static cells, we don't need to call this for any other cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if indexPath.section == 1 && indexPath.row == 2
        {
            return datePickerCell
        }
        
        // for any index-paths that are not the date picker cell, this block will be executed
        // this is the trick that makes sure the other static cells still work
        else
        {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    // each static cell has its own height of 44 points
    // by adding this method you can give each cell its own height
    // the UIDatePicker is 216 points tall, plus 1 point for the separator line,
    // so we return 217 points from this
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if indexPath.section == 1 && indexPath.row == 2
        {
            return 217
        }
        
        else
        {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    // calls showDatePicker() when the index-path indicates that the due date row was tapped
    // also hides the on-screen keyboard if it's visible
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        textField.resignFirstResponder()
        
        if indexPath.section == 1 && indexPath.row == 1
        {
            if !datePickerVisible
            {
                showDatePicker()
            }
            
            else
            {
                hideDatePicker()
            }
        }
    }
    
    // the '?' after 'NSIndexPath' in the return type allows for the method to return a nil instance
    // you can only return nil if '?' or '!' is specified after the return type
    // now the due date row responds to taps, but the other rows don't
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        if indexPath.section == 1 && indexPath.row == 1
        {
            return indexPath
        }
        
        else
        {
            return nil
        }
    }
    
    // when overriding the data source for a static table view cell, you also need to provide this method
    // the standard data source doesn't know anything about the cell at row 2 in section 1
    // (the cell with the date picker), because that cell isn't part of the table view's design in storyboard
    // adding this tricks the data source into thinking there really are three rows in that section
    // when the date picker is visible
    override func tableView(tableView: UITableView, var indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int
    {
        if indexPath.section == 1 && indexPath.row == 2
        {
            indexPath = NSIndexPath(forRow: 0, inSection: indexPath.section)
        }
        
        return super.tableView(tableView, indentationLevelForRowAtIndexPath: indexPath)
    }
    
    @IBAction func cancel()
    {
        // optionals ('?' or '!')
        // here we send the delegate a message to perform an action
        // the '?' is an optional and basically checks to see if 'delegate' is nil
        // if it is not, then it will send the message
        delegate?.itemDetailViewControllerDidCancel(self)
    }
    
    @IBAction func done()
    {
        if let item = itemToEdit
        {
            item.text = textField.text!
            item.shouldRemind = shouldRemindSwitch.on
            item.dueDate = dueDate
            item.scheduleNotification()
            delegate?.itemDetailViewController(self, didFinishEditingItem: item)
        }
        else
        {
            let item = ChecklistItem()
            item.text = textField.text!
            item.checked = false
            item.shouldRemind = shouldRemindSwitch.on
            item.dueDate = dueDate
            item.scheduleNotification()
            delegate?.itemDetailViewController(self, didFinishAddingItem: item)
        }
    }
    
    // UITextField delegate method
    // this method is invoked every time the user changes the text
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        // first figure out what the new text will be
        // take the old text from the text field and store it in 'oldText'
        // then create a new string in 'newText' that takes the old string value from 'oldText',
        // and essentially replaces it with the new characters added into the text field,
        // by calling 'stringByReplacingCharactersInRange(withString)'
        let oldText: NSString = textField.text!
        let newText: NSString = oldText.stringByReplacingCharactersInRange(range, withString: string)
        
        doneBarButton.enabled = (newText.length > 0)
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        hideDatePicker()
    }
    
    func updateDueDateLabel()
    {
        // we use an 'NSDateFormatter' object to to convert the NSDate value to text
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        dueDateLabel.text = formatter.stringFromDate(dueDate)
    }
    
    // inserts a new row below the due date cell
    // the new row will contain the UIDatePicker
    func showDatePicker()
    {
        datePickerVisible = true
        
        let indexPathDateRow = NSIndexPath(forRow: 1, inSection: 1)
        let indexPathDatePicker = NSIndexPath(forRow: 2, inSection: 1)
        
        // sets the textColor of the detailTextLabel to the tint color
        if let dateCell = tableView.cellForRowAtIndexPath(indexPathDateRow)
        {
            dateCell.detailTextLabel!.textColor = dateCell.detailTextLabel!.tintColor
        }
        
        // tells the table view to reload the due date row
        // because I am doing two operations on the table view at the same time -
        // inserting a new row and reloading another - you need to put this in between calls
        // to beginUpdates() and endUpdates(), so that the table view can animate
        // everything at the same time
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([indexPathDatePicker], withRowAnimation: .Fade)
        
        tableView.reloadRowsAtIndexPaths([indexPathDateRow], withRowAnimation: .None)
        tableView.endUpdates()
        
        // this gives the proper date to the UIDatePicker component
        datePicker.setDate(dueDate, animated: false)
    }
    
    // does the opposite of showDatePicker()
    // it deletes the date picker cell from the table view and restores the color of the date label
    // to medium gray
    func hideDatePicker()
    {
        if datePickerVisible
        {
            datePickerVisible = false
        
            let indexPathDateRow = NSIndexPath(forRow: 1, inSection: 1)
            let indexPathDatePicker = NSIndexPath(forRow: 2, inSection: 1)
            
            if let cell = tableView.cellForRowAtIndexPath(indexPathDateRow)
            {
                cell.detailTextLabel!.textColor = UIColor(white: 0, alpha: 0.5)
            }
            
            tableView.beginUpdates()
            tableView.reloadRowsAtIndexPaths([indexPathDateRow], withRowAnimation: .None)
            tableView.deleteRowsAtIndexPaths([indexPathDatePicker], withRowAnimation: .Fade)
            tableView.endUpdates()
        }
    }
    
    // updates the dueDate instance variable with the new date
    // and updates the text in the due date label
    @IBAction func dateChanged(datePicker: UIDatePicker)
    {
        dueDate = datePicker.date
        updateDueDateLabel()
    }
    
    // when the switch is toggled to on, this prompts the user for permission to send local notifications
    @IBAction func shouldRemindToggled(switchControl: UISwitch)
    {
        textField.resignFirstResponder()
        
        if switchControl.on
        {
            let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        }
    }
}
