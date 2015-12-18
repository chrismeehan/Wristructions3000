//
//  ListOfStepsWKIC is actuall a list of checklist items, and a "click to begin" button.


import WatchKit
import Foundation
import CoreData
import CoreDataAccessFramework


class ListOfStepsWKIC: WKInterfaceController {
    @IBOutlet weak var prechecklistLabel: WKInterfaceLabel!
    @IBOutlet weak var theTable: WKInterfaceTable!
    var theTitle:String!
    var arrayOfChecklistItems:Array<AnyObject>!
    var indexNum:Int!
    var currentIntructionObject:NSManagedObject!
    
    func loadTableWithChecklist(){
        if let moc = CoreDataAccess.sharedInstance.managedObjectContext{
            let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Instruction")
            moc.refreshObject((currentIntructionObject as NSManagedObject), mergeChanges: true)
            var arrayOfAllObjects:Array<AnyObject>! = try! moc.executeFetchRequest(fetchRequest)
            currentIntructionObject = arrayOfAllObjects[indexNum] as! NSManagedObject
            arrayOfChecklistItems = currentIntructionObject.valueForKey("arrayOfChecklistItems") as! Array<AnyObject>!
            
            if Int(0) < arrayOfChecklistItems.count {
                theTable.setNumberOfRows(arrayOfChecklistItems.count, withRowType: "StepIndentifier")
                for(index,_) in arrayOfChecklistItems.enumerate(){
                    let row = theTable.rowControllerAtIndex(index) as! myTableRowController
                    var checklistItem:Array<AnyObject> = arrayOfChecklistItems[index] as! Array<AnyObject>
                    row.rowLabel.setText(checklistItem[0] as? String)
                }
            }
            else{
                theTable.setNumberOfRows(1, withRowType: "StepIndentifier")
                let row = theTable.rowControllerAtIndex(0) as! myTableRowController
                row.rowLabel.setText("no items")
            }
            
            
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        var array:Array<AnyObject>! = context as! Array<AnyObject>!
        currentIntructionObject = array[0] as! NSManagedObject
        theTitle = (currentIntructionObject.valueForKey("title") as! String)
        indexNum = array[1] as! Int
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        setTitle(theTitle)
        loadTableWithChecklist()
        
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String) -> AnyObject? {
        let arrayOfSteps:Array<AnyObject> = currentIntructionObject.valueForKey("arrayOfSteps") as! Array<AnyObject>
        return [arrayOfSteps,theTitle]
    }

}
