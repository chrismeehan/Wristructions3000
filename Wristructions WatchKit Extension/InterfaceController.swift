
//  Created by Chris Meehan on 8/26/15.
//  Copyright (c) 2015 Christopher Meehan. All rights reserved.
//

import WatchKit
import Foundation
import CoreData
import CoreDataAccessFramework

class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var theTable: WKInterfaceTable!
    var arrayOfInstTitles:Array<String>!
    var arrayOfAllObjects:Array<AnyObject>!
    
    func loadTitleArray(){
        arrayOfInstTitles = []
        if let moc = CoreDataAccess.sharedInstance.managedObjectContext{
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Instruction")
            do{
                arrayOfAllObjects = try moc.executeFetchRequest(fetchRequest)
                for (_, value) in arrayOfAllObjects.enumerate() {
                    moc.refreshObject((value as! NSManagedObject), mergeChanges: true)
                    arrayOfInstTitles.append((value.valueForKey("title") as? String)!)
                }
            }
            catch{
                
            }
        }
    }
    
    func loadTableWithTitles(){
        if arrayOfInstTitles.count == Int(0){
            setTitle("You have no tasks")
        }
        else{
            setTitle("tasks")
        }
        theTable.setNumberOfRows(arrayOfInstTitles.count, withRowType: "RowIdentifier")
        for(index,context) in arrayOfInstTitles.enumerate(){
            let row = theTable.rowControllerAtIndex(index) as! myTableRowController
            row.rowLabel.setText(context)
        }
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String,
        inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        return [arrayOfAllObjects[rowIndex],rowIndex]
    }
  
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        loadTitleArray()
        loadTableWithTitles()
    }
}
