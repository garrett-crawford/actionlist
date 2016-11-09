//
//  ListDetailViewController.swift
//  Checklists
//
//  Created by Garrett Crawford on 1/5/16.
//  Copyright © 2016 Noox. All rights reserved.
//

import UIKit

protocol ListDetailViewControllerDelegate: class
{
    func listDetailViewControllerDidCancel(controller: ListDetailViewController)
    func listDetailViewController(controller: ListDetailViewController, didFinishAddingChecklist checklist: Checklist)
    func listDetailViewController(controller: ListDetailViewController, didFinishEditingChecklist checklist: Checklist)
}

class ListDetailViewController: UITableViewController, UITextFieldDelegate, IconPickerViewControllerDelegate
{
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var iconImageView: UIImageView!
    
    weak var delegate: ListDetailViewControllerDelegate?
    
    var checklistToEdit: Checklist?
    
    // this variable keeps track of the chosen icon name
    var iconName = "Folder"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if let checklist = checklistToEdit
        {
            title = "Edit Checklist"
            textField.text = checklist.name
            doneBarButton.enabled = true
            iconName = checklist.iconName
        }
        
        iconImageView.image = UIImage(named: iconName)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    @IBAction func cancel()
    {
        delegate?.listDetailViewControllerDidCancel(self)
    }
    
    // previously this method returned nil, which meant that tapping on rows was not possible
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath?
    {
        // this is necessary otherwise you cannot tap the "Icon" cell to trigger the segue
        if indexPath.section == 1
        {
            return indexPath
        }
        
        else
        {
            return nil
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "PickIcon"
        {
            let controller = segue.destinationViewController as! IconPickerViewController
            controller.delegate = self
        }
    }
    
    @IBAction func done()
    {
        if let checklist = checklistToEdit
        {
            checklist.name = textField.text!
            checklist.iconName = iconName
            delegate?.listDetailViewController(self, didFinishEditingChecklist: checklist)
        }
        else
        {
            let checklist = Checklist(name: textField.text!, iconName: iconName)
            delegate?.listDetailViewController(self, didFinishAddingChecklist: checklist)
        }
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        let oldText: NSString = textField.text!
        let newText: NSString = oldText.stringByReplacingCharactersInRange(range, withString: string)
        
        doneBarButton.enabled = (newText.length > 0)
        return true
    }
    
    // delegate method
    func iconPicker(picker: IconPickerViewController, didPickIcon iconName: String)
    {
        self.iconName = iconName
        iconImageView.image = UIImage(named: iconName)
        
        // we call 'popViewControllerAnimated' because the IconPickerViewController is on the navigation stack
        // only call dismissViewController when presenting a view controller modally
        navigationController?.popViewControllerAnimated(true)
    }
}
