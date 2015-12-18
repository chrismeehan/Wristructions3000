//
//  ExportVC.swift
//  Wristructions
//
//  Created by Chris Meehan on 9/7/15.
//  Copyright (c) 2015 Christopher Meehan. All rights reserved.
//

import UIKit
import CoreData
import CoreDataAccessFramework

class ExportVC: UIViewController {

    var instructionTitle:String!
    var arrayOfChecklistItems:Array<AnyObject>!
    var arrayOfSteps:Array<String>!
    var growingString:NSString = ""
 
    
    @IBAction func copyWasHit(sender: AnyObject) {
        turnWristructionIntoAChunckOfTextAndCopyItToClipboard()
    }
    
    func turnWristructionIntoAChunckOfTextAndCopyItToClipboard(){
        
        addThisStringToGrowingString(beforeTheTitle) // Get the title ready to add.
        addThisStringToGrowingString(instructionTitle) // Then add the title.
        // For each checklist item, add it to the string
        for(_,context) in arrayOfChecklistItems.enumerate(){
            addThisStringToGrowingString(theBeginningOfAChecklistItem) // Add a signal that this is the beginning of a checklist item.
            addThisStringToGrowingString( context[0] as! String ) // Then add that item.
        }

        // For each checklist item, add it to the string
        for(_,context) in arrayOfSteps.enumerate(){
            addThisStringToGrowingString(theBeginningOfAStep) // Add a signal that this is the beginning of a checklist item.
            addThisStringToGrowingString( context as String ) // Then add that item.
        }
        addThisStringToGrowingString( theEndOfAll ) // Then add that item.
        
        // Copy it to the clipboard
        UIPasteboard.generalPasteboard().string = growingString as String
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func addThisStringToGrowingString(stringToAdd:String){
        growingString = (growingString as String) + stringToAdd
    }
}
