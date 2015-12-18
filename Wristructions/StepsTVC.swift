
//  Created by Chris Meehan on 8/26/15.
//  Copyright (c) 2015 Christopher Meehan. All rights reserved.
//

import UIKit
import CoreData
import CoreDataAccessFramework

class StepsTVC: UITableViewController {
    
    var instructionTitle:String!
    var existingIntruction:AnyObject!
    var arrayOfSteps:Array<String>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arrayOfSteps = existingIntruction.valueForKeyPath("arrayOfSteps") as! Array<String>!
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        arrayOfSteps = existingIntruction.valueForKeyPath("arrayOfSteps") as! Array<String>!
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
        return arrayOfSteps.count+1
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("StepsCellid", forIndexPath: indexPath) as! CustomTableViewCell
        if indexPath.row == arrayOfSteps.count{
            cell.stepLabel?.text = "( add another step)"
            cell.stepNumberLabel.text = " "
            cell.clockImage.hidden = true
        }
        else{
            let step:String = arrayOfSteps[indexPath.row] as String
            let range:Range<String.Index>? = step.lowercaseString.rangeOfString("a timer for")
            if  range != nil {   // This is a timer start button then, we are only presenting it.
                cell.clockImage.hidden = false
            }
            else{
                cell.clockImage.hidden = true
            }
            cell.stepLabel?.text = " " + arrayOfSteps[indexPath.row] as String
            cell.stepNumberLabel.text = "\(indexPath.row + Int(1))"
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            if indexPath.row != arrayOfSteps.count{   // Dont let them delete the last "message" cell.
                arrayOfSteps.removeAtIndex(indexPath.row)
                existingIntruction.setValue(arrayOfSteps, forKey: "arrayOfSteps")
                CoreDataAccess.sharedInstance.saveContext()
                tableView.reloadData()
            }
        default:
            return
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "OneStepSegue"{
            if let eOSVC: EditOneStepVC = segue.destinationViewController as? EditOneStepVC {
                if tableView.indexPathForSelectedRow!.row == arrayOfSteps.count{ // Then we are adding a new one.
                    eOSVC.textForThisStep = ""
                    eOSVC.existingIntruction = existingIntruction as! NSManagedObject
                    eOSVC.indexOfStep = tableView.indexPathForSelectedRow!.row
                    eOSVC.arrayOfSteps = arrayOfSteps
                    eOSVC.tVCToPopBackTo = self
                }
                else{ // Then we are editing an existing one.
                    eOSVC.textForThisStep = arrayOfSteps[tableView.indexPathForSelectedRow!.row] as String
                    eOSVC.existingIntruction = existingIntruction as! NSManagedObject
                    eOSVC.indexOfStep = tableView.indexPathForSelectedRow!.row
                    eOSVC.arrayOfSteps = arrayOfSteps
                    eOSVC.thisVCIsAnEdit = true
                    eOSVC.tVCToPopBackTo = self
                }
            }
        }
    }
}
