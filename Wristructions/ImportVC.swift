//
//  ImportVC.swift
//  Wristructions
//
//  Created by Chris Meehan on 9/7/15.
//  Copyright (c) 2015 Christopher Meehan. All rights reserved.
//

import UIKit
import CoreData
import CoreDataAccessFramework

class ImportVC: UIViewController {

    var instructionTitle:String!
    var arrayOfChecklistItems:Array<AnyObject>! = []
    var arrayOfSteps:Array<String>! = []
    
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // This button actually says: "I have copied from another source"
    //So lets paste what we have and parse it.
    @IBAction func saveWasHit(sender: AnyObject) {
        convertTextIntoANewSavedTask(getFromClipboard())
        navigationController?.popToRootViewControllerAnimated(true)
    }

    func getFromClipboard() -> String!{
        return UIPasteboard.generalPasteboard().string
    }
    
    func convertTextIntoANewSavedTask(theString:String){
        var shrinkingString:String! = theString
        // Get the range of the mark before the title.
        let rangeOfPreTitle:Range<String.Index>? = shrinkingString.rangeOfString(beforeTheTitle)
        let endIndex2 = rangeOfPreTitle!.endIndex
        // Remove that mark from the overall string.
        shrinkingString = shrinkingString.substringWithRange(Range<String.Index>(start: endIndex2, end: theString.endIndex))
        
        // Get the range of the mark after the title. (aka theMarkBeforeAChecklist, or theMarkBeforeAStep, or theEndOfItAllMark)
        var rangeOfFirstChecklistItem:Range<String.Index>? = shrinkingString.rangeOfString(theBeginningOfAChecklistItem)
        var rangeOfFirstStepItem:Range<String.Index>? = shrinkingString.rangeOfString(theBeginningOfAStep)
        
        if  rangeOfFirstChecklistItem != nil { // As long as we found 1 checklist item.
            // Lets grab the title.
            let start = rangeOfFirstChecklistItem?.startIndex
            instructionTitle = shrinkingString.substringWithRange(Range<String.Index>(start: shrinkingString.startIndex, end:start!))
        }
        else if rangeOfFirstStepItem != nil {
            // Lets grab the title.
            let start = rangeOfFirstStepItem?.startIndex
            instructionTitle = shrinkingString.substringWithRange(Range<String.Index>(start: shrinkingString.startIndex, end:start!))
        }
        else{ // There are no checklists or steps, dont save nothin.
            // Back out of this window right now.
        }
        
        // We have the title, and a long string that contains a starter code (either checklistItemStarter or stepItemStarter)
        while rangeOfFirstChecklistItem != nil { // It must start with the checklistItemStarter code.
            // We have a checklist starter code, lets find the one that follows so we know where to stop.
            rangeOfFirstChecklistItem = shrinkingString.rangeOfString(theBeginningOfAChecklistItem)
            let end = rangeOfFirstChecklistItem?.endIndex
            shrinkingString = shrinkingString.substringFromIndex(end!) // Cut this steps beginning code, so we can find more.
            
            let range2 = shrinkingString.rangeOfString(theBeginningOfAChecklistItem)
            let rangeStep = shrinkingString.rangeOfString(theBeginningOfAStep) // Just incase there is not another checklistItem.

            if range2 != nil{ // Then the item following this one, is another checklist item. Lets use it right now as an end marker.
                let start2 = range2?.startIndex
                let checklistItem:String = shrinkingString.substringToIndex(start2!)
                arrayOfChecklistItems.append([checklistItem,Int(0)])
                // As of now, the big long string starts with this checklistItem, no worries, it will get cut out next loop.
            }
            else if rangeStep != nil{
                let start2 = rangeStep?.startIndex// The start of this code, is the end of the string we want.
                let checklistItem:String = shrinkingString.substringToIndex(start2!)
                arrayOfChecklistItems.append([checklistItem,Int(0)])
                // As of now, the big long string starts with this checklistItem, no worries, it will get cut out next loop.
            }
            else{ // This must be the last item we are adding. There must be no steps.
                let rangeOfEnd = shrinkingString.rangeOfString(theEndOfAll)
                let start2 = rangeOfEnd?.startIndex// The start of this code, is the end of the string we want.
                let checklistItem:String = shrinkingString.substringToIndex(start2!)
                arrayOfChecklistItems.append([checklistItem,Int(0)])
            }
            // THe last thing we do is assign the next checklist item. If there is none, the while loop will end now.
            rangeOfFirstChecklistItem = shrinkingString.rangeOfString(theBeginningOfAChecklistItem)
        }
        // Now lets load up all the steps, if there are any.
        while rangeOfFirstStepItem != nil {
            rangeOfFirstStepItem = shrinkingString.rangeOfString(theBeginningOfAStep)
            let end = rangeOfFirstStepItem?.endIndex
            shrinkingString = shrinkingString.substringFromIndex(end!) // Cut this steps beginning code, so we can find more.
            let rangeStep = shrinkingString.rangeOfString(theBeginningOfAStep) // Just incase there is not another checklistItem.
            if rangeStep != nil{
                let start2 = rangeStep?.startIndex // The start of this code, is the end of the string we want.
                let stepItem:String = shrinkingString.substringToIndex(start2!)
                arrayOfSteps.append(stepItem)
                // As of now, the big long string starts with this checklistItem, no worries, it will get cut out next loop.
            }
            else{ // This must be the last item we are adding.
                let rangeOfEnd = shrinkingString.rangeOfString(theEndOfAll)
                if rangeOfEnd != nil {
                    let start2 = rangeOfEnd?.startIndex
                    let stepItem:String = shrinkingString.substringToIndex(start2!)
                    arrayOfSteps.append(stepItem)
                }
            }
            // THe last thing we do is assign the next checklist item. If there is none, the while loop will end now.
            rangeOfFirstStepItem = shrinkingString.rangeOfString(theBeginningOfAStep)
        }
        // Done, as long as there was a finishing code, we will save to CoreData, and exist with success.
        let rangeOfFinalCode = shrinkingString.rangeOfString(theEndOfAll)
        if rangeOfFinalCode != nil && 0 < instructionTitle.characters.count{ // THen lets finish properly
            save()
        }
    }
    
    func save() {
        let moc = CoreDataAccess.sharedInstance.managedObjectContext
        let instructionObject:NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName("Instruction", inManagedObjectContext: moc!) 
        instructionObject.setValue(instructionTitle, forKey: "title")
        instructionObject.setValue(arrayOfSteps, forKey: "arrayOfSteps")
        instructionObject.setValue(arrayOfChecklistItems, forKey: "arrayOfChecklistItems")
        CoreDataAccess.sharedInstance.saveContext()
    }
}
