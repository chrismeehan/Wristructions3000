//
//  CreateNewOrModify.swift
//  Wriststructions
//
//  Created by Chris Meehan on 8/26/15.
//  Copyright (c) 2015 Christopher Meehan. All rights reserved.
//
// THis class is where you modify the title of an existing task, or create a new title/task.

import UIKit
import CoreData
import CoreDataAccessFramework

class CreateNewOrModify: UIViewController {
    @IBOutlet weak var importButton: UIButton! // Incase you want to import a task from an outside source.
    @IBOutlet weak var exportButton: UIButton! // Incase you want to export your tasks to give to someone else.
    @IBOutlet weak var viewChecklistButton: UIButton!
    @IBOutlet weak var notifCountLabel: UILabel!
    var instructionTitle:String!
    var existingIntruction:NSManagedObject!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var viewSteps: UIButton!
    @IBOutlet weak var save: UIButton!
    
    @IBAction func save(sender: AnyObject) {
        if titleTextField.text != "" && titleTextField.text != nil{
            if existingIntruction == nil{
                let moc = CoreDataAccess.sharedInstance.managedObjectContext
                let instructionObject:NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName("Instruction", inManagedObjectContext: moc!) 
                instructionObject.setValue(titleTextField.text, forKey: "title")
                instructionObject.setValue([], forKey: "arrayOfSteps")
                instructionObject.setValue([], forKey: "arrayOfChecklistItems")
            }
            else{ // This is a pre-existing object, so just update it.
                existingIntruction.setValue(titleTextField.text, forKey: "title")
            }
            CoreDataAccess.sharedInstance.saveContext()
        }
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (existingIntruction != nil){
            instructionTitle = existingIntruction.valueForKey("title") as! String
        }
    }
    
    func keyboardWasShown(){
        save.hidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        if (existingIntruction != nil){ // If this is an existing item, lets not let them save until they changed something.
            save.hidden = true
            titleTextField.text = instructionTitle
            // Lets listen for if the user taps the keyboard.
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWasShown"), name: UIKeyboardDidShowNotification, object: nil)
            importButton.hidden = true
            exportButton.hidden = false
        }
        else{ // This is a brand new task we're creating.
            viewSteps.hidden = true
            viewChecklistButton.hidden = true
            titleTextField.becomeFirstResponder()
            importButton.hidden = false
            exportButton.hidden = true
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self) // We know longer want to me notified if the keyboard appears.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showStepsSeque") {
            if let stepsVC: StepsTVC = segue.destinationViewController as? StepsTVC {
                stepsVC.instructionTitle = instructionTitle
                stepsVC.existingIntruction = existingIntruction
            }
        }
        else if (segue.identifier == "GoingToChecklistSegue") {
             let cLUITV:ChecklistUITV = segue.destinationViewController as! ChecklistUITV
                cLUITV.instructionTitle = instructionTitle
                cLUITV.existingIntruction = existingIntruction
        }
        else if(segue.identifier == "exportSegue"){
            let eVC: ExportVC! = segue.destinationViewController as! ExportVC
            eVC.arrayOfChecklistItems = existingIntruction.valueForKey("arrayOfChecklistItems") as! Array<AnyObject>
            eVC.arrayOfSteps = existingIntruction.valueForKey("arrayOfSteps") as! Array<String>
            eVC.instructionTitle = instructionTitle
        }
    }
}
