//
//  ListOfStepsWKIC.swift
//  Wristructions
//
//  Created by Chris Meehan on 8/29/15.
//  Copyright (c) 2015 Christopher Meehan. All rights reserved.
//



import WatchKit
import Foundation
import CoreData
import CoreDataAccessFramework


class OneStepWKIC: WKInterfaceController {
    
    @IBOutlet weak var Button: WKInterfaceButton!
    @IBOutlet weak var oneStepLabel2: WKInterfaceLabel!
    var theTitle:String!
    var arrayOfSteps:Array<String>!
    var currentStepNum:Int!
    var currentIntructionObject:NSManagedObject!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        currentStepNum=0
        
        if let context2: AnyObject = context{
        currentIntructionObject = context2 as! NSManagedObject
        }
        arrayOfSteps = currentIntructionObject.valueForKey("arrayOfSteps") as! Array<String>!
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        if let stepArray2: Array<String>! = currentIntructionObject.valueForKey("arrayOfSteps") as! Array<String>!{
            let str:String =  stepArray2[currentStepNum]
            Button.setTitle(str)
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    override func contextForSegueWithIdentifier(segueIdentifier: String,
        inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        let array:Array<AnyObject> = [arrayOfSteps,1]  //   [currentInstObject, currentIndex]
        return array
    }
}
