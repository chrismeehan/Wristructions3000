//
//  ChecklistUITV.swift
//  Wristructions
//
//  Created by Chris Meehan on 9/6/15.
//  Copyright (c) 2015 Christopher Meehan. All rights reserved.
//

import UIKit
import CoreData
import CoreDataAccessFramework

class ChecklistUITV: UITableViewController {

    var arrayOfChecklistObjects:Array<Array<AnyObject>>! = [] // ["some checklist item" , 0]
    var instructionTitle:String!
    var existingIntruction:NSManagedObject!
    
    @IBAction func checkAllClicked(sender: AnyObject) {
        for(index,context) in arrayOfChecklistObjects.enumerate(){
            var checklistObject:Array<AnyObject> = context
            arrayOfChecklistObjects[index] = [checklistObject[0],Int(1)]
        }
        saveAnyChanges()
        tableView.reloadData()
    }
    
    @IBAction func uncheckAllClicked(sender: AnyObject) {
        for(index,context) in arrayOfChecklistObjects.enumerate(){
            var checklistObject:Array<AnyObject> = context
            arrayOfChecklistObjects[index] = [checklistObject[0],Int(0)]
        }
        saveAnyChanges()
        tableView.reloadData()
    }
    
    
    func saveAnyChanges(){
        existingIntruction.setValue(arrayOfChecklistObjects, forKey: "arrayOfChecklistItems")
        CoreDataAccess.sharedInstance.saveContext()
    }
    
    override func viewWillAppear(animated: Bool) {
        arrayOfChecklistObjects = existingIntruction.valueForKeyPath("arrayOfChecklistItems") as! Array<Array<AnyObject>>!
        tableView.reloadData()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return arrayOfChecklistObjects.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChecklistUITVCid", forIndexPath: indexPath) as! ChecklistUITVC
        var checklistItemObject:Array<AnyObject>! = arrayOfChecklistObjects[indexPath.row]
        cell.label.text = checklistItemObject[0] as? String
        cell.indexNum = indexPath.row
        cell.parentVC = self
        if checklistItemObject[1] as! Int == Int(1){
            cell.buttonCheck.backgroundColor = UIColor.grayColor()
            cell.backgroundColor = UIColor.lightGrayColor()
            let attributes = [NSStrikethroughStyleAttributeName : 1]
            let title = NSAttributedString(string: (checklistItemObject[0] as? String)!, attributes: attributes) //1
            cell.label.attributedText = title
        }
        else{
            cell.buttonCheck.backgroundColor = UIColor.greenColor()
            cell.backgroundColor = UIColor.whiteColor()
        }
        return cell
    }
    
    func aCellHadItsBoxChecked(cellNum:Int){
        var theChecklistObject:Array<AnyObject> = arrayOfChecklistObjects[cellNum]
        var checkedOrNot:Int = theChecklistObject[1] as! Int
        if checkedOrNot == Int(0){
           checkedOrNot = Int(1)
        }
        else{
           checkedOrNot = Int(0)
        }
        let theNewChecklistObject:Array<AnyObject> = [theChecklistObject[0],checkedOrNot]
        arrayOfChecklistObjects[cellNum] = theNewChecklistObject
        existingIntruction.setValue(arrayOfChecklistObjects, forKey: "arrayOfChecklistItems")
        CoreDataAccess.sharedInstance.saveContext()

        tableView.reloadData()
    }


    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            // remove the deleted item from the model
            if let _ = CoreDataAccess.sharedInstance.managedObjectContext{
                arrayOfChecklistObjects.removeAtIndex(indexPath.row)
                existingIntruction.setValue(arrayOfChecklistObjects, forKey: "arrayOfChecklistItems")
                CoreDataAccess.sharedInstance.saveContext()
                tableView.reloadData()
            }
        default:
            return
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "OneStepChecklistSegue"{
            if let eOSVC: EditOneStepVC = segue.destinationViewController as? EditOneStepVC {
                eOSVC.textForThisStep = ""
                eOSVC.existingIntruction = existingIntruction as NSManagedObject
           //     eOSVC.indexOfStep = tableView.indexPathForSelectedRow()!.row
                eOSVC.arrayOfSteps = arrayOfChecklistObjects
                eOSVC.isThisAChecklistItem = true
                eOSVC.thisVCIsAnInsert = false
                eOSVC.thisVCIsAnEdit = false
                eOSVC.tVCToPopBackTo = self
   
            }
        }
    }

}
