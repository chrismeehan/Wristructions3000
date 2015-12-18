//
//  InstructionsTVC.swift
//  Wriststructions
//
//  Created by Chris Meehan on 8/26/15.
//  Copyright (c) 2015 Christopher Meehan. All rights reserved.
//
// This class is a uitableview that holds all the task names.

import UIKit
import CoreData
import CoreDataAccessFramework

class InstructionsTVC: UITableViewController {
    
    var arrayOfInstTitles:Array<String>! = []
    var arrayOfAllObjects:Array<AnyObject>!
    
    override func viewWillAppear(animated: Bool) {
        // Every time this screen appears, we will refresh its data from the moc.
        if let tempMoc = CoreDataAccess.sharedInstance.managedObjectContext{
            let moc:NSManagedObjectContext = tempMoc
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Instruction")
            arrayOfAllObjects = try! moc.executeFetchRequest(fetchRequest)
            loadTitleArray() // Now that we have the most current task items, lets load the array to display.
            tableView.reloadData()
        }
    }
    
    func loadTitleArray(){
        arrayOfInstTitles = []
        for (_, value) in arrayOfAllObjects.enumerate() {
            arrayOfInstTitles.append((value.valueForKey("title") as? String)!)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfInstTitles.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("InstructionCellid", forIndexPath: indexPath) 
        cell.textLabel?.text = arrayOfInstTitles[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            // remove the deleted item from the model
            if let moc = CoreDataAccess.sharedInstance.managedObjectContext{
                moc.deleteObject(arrayOfAllObjects[indexPath.row] as! NSManagedObject)
                arrayOfAllObjects.removeAtIndex(indexPath.row)
                try! moc.save()
                // remove the deleted item from the `UITableView`
                loadTitleArray()
                tableView.reloadData()
            }
        default:
            return
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "createNewInstSegue") { // This is a segue to a pre-existing task.
            // Grab the instance of the VC were going to.
            if let cNOMTVC: CreateNewOrModify = segue.destinationViewController as? CreateNewOrModify {
                let obj:NSManagedObject! = arrayOfAllObjects[tableView.indexPathForSelectedRow!.row] as! NSManagedObject
                cNOMTVC.existingIntruction = obj //
                cNOMTVC.title = obj.valueForKey("title") as? String
            }
        }
        else{ // This is a segue to create a brand new task.
            if let cNOMTVC: CreateNewOrModify = segue.destinationViewController as? CreateNewOrModify {
                cNOMTVC.title = "Create New Task"
            }
        }
    }
}
