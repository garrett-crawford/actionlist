//
//  AllListsViewController.swift
//  Checklists
//
//  Created by Garrett Crawford on 1/4/16.
//  Copyright © 2016 Noox. All rights reserved.
//

import UIKit

// to recognize when the user presses the back button on the navigation bar,
// you have to become a delegate of the navigation controller
// being the delegate means that the navigation controller tells you when 
// it pushes or pops view controllers on the navigation stack
class AllListsViewController: UITableViewController, ListDetailViewControllerDelegate, UINavigationControllerDelegate
{
    // the '!' is necessary because 'dataModel' will be temporarily nil when the app starts up
    // doesn't have to be a true optional ('?') because once 'dataModel' has a value,
    // it will never become nil again
    var dataModel: DataModel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    // 'viewWillAppear()' is called before 'viewDidAppear()'
    // this tells the table view to reload its entire contents
    // this will cause 'tableView(cellForRowAtIndexPath)' to be called for every visible row
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // UIKit automatically calls this method after the view controller becomes visible
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        // the view controller makes itself the delegate for the navigation controller
        navigationController?.delegate = self
        
        let index = dataModel.indexOfSelectedChecklist
        
        if index >= 0 && index < dataModel.lists.count
        {
            let checklist = dataModel.lists[index]
            performSegueWithIdentifier("ShowChecklist", sender: checklist)
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dataModel.lists.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = cellForTableView(tableView)
        
        let checkList = dataModel.lists[indexPath.row]
        cell.textLabel!.text = checkList.name
        cell.accessoryType = .DetailDisclosureButton
        
        let count = checkList.countUncheckedItems()

        if checkList.items.count == 0
        {
            cell.detailTextLabel!.text = "(No Items)"
        }
        
        else if count == 0
        {
            cell.detailTextLabel!.text = "All Done!"
        }
        
        else
        {
            cell.detailTextLabel!.text = "\(checkList.countUncheckedItems()) Remaining"
        }
        
        // cells using the '.Subtitle' cell style come with a built in UIImageView on the left
        // here we add the icon to the cell image view
        cell.imageView!.image = UIImage(named: checkList.iconName)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        dataModel.indexOfSelectedChecklist = indexPath.row
        
        let checklist = dataModel.lists[indexPath.row]
        
        // when the user selects a row to go to the specified to do list,
        // this method will be called to pass the checklist object
        // so that the to do list screen can have title name be the name of the checklist
        // this method also brings up the next view controller shown in storyboard
        performSegueWithIdentifier("ShowChecklist", sender: checklist)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "ShowChecklist"
        {
            
            // segue's destinationViewController property refers to the view controller
            // on the receiving end of the segue
            let controller = segue.destinationViewController as! ChecklistViewController
            
            // here we provide the optional the CheckList object to fill in the title
            // 'as! something' is known as a type cast
            // a type cast tells swift to interpret a value as having a different data type
            controller.checklist = sender as! Checklist
        }
        
        else if segue.identifier == "AddChecklist"
        {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! ListDetailViewController
            
            controller.delegate = self
            controller.checklistToEdit = nil
        }
    }
    
    // presents the 'ListDetailViewController' after the accessory button has been tapped
    // this is the way to present the next view controller in code rather than storyboard
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath)
    {
        let navigationController =
        storyboard!.instantiateViewControllerWithIdentifier("ListDetailNavigationController") as! UINavigationController
        
        let controller = navigationController.topViewController as! ListDetailViewController
        controller.delegate = self
        
        let checklist = dataModel.lists[indexPath.row]
        controller.checklistToEdit = checklist
        
        presentViewController(navigationController, animated: true, completion: nil)
        
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        dataModel.lists.removeAtIndex(indexPath.row)
        let indexPaths = [indexPath]
        tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
    }
    
    func cellForTableView(tableView: UITableView) -> UITableViewCell
    {
        let cellIdentifier = "Cell"
        
        // if this returns nil, there is no cell that can be recycled and you can
        // construct a new one with UITableViewCell(reuseIdentifier)
        if let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        {
            return cell
        }
        else
        {
            // '.Subtitle' adds a second, smaller label below the main label
            // can use the cell's 'detailTextLabel' property to modify the subtitle label
            return UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
        }
    }
    
    func listDetailViewControllerDidCancel(controller: ListDetailViewController)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func listDetailViewController(controller: ListDetailViewController, didFinishAddingChecklist checklist: Checklist)
    {
        dataModel.lists.append(checklist)
        dataModel.sortChecklists()
        
        // it is not necessary to insert the new row manually
        // calling the table view's 'reloadData()' refreshes the entire table's contents
        // we can get away with this because the table will only have a handful of rows
        // if the table held many many rows (ie > 100000 rows), a more advanced approach
        // would be necessary (could figure out where the new or renamed Checklist object
        // should be inserted and just update that row)
        tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func listDetailViewController(controller: ListDetailViewController, didFinishEditingChecklist checklist: Checklist)
    {
        dataModel.sortChecklists()
        tableView.reloadData()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // called whenever the navigation controller will slide to a new screen
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool)
    {
        // when using '===', you check to see if two variables refer to the same object
        if viewController === self
        {
            dataModel.indexOfSelectedChecklist = -1
        }
    }
}
