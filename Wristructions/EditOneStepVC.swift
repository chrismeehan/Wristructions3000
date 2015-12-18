//
//  EditOneStepVC.swift
//  Wristructions
//
//  Created by Chris Meehan on 8/29/15.
//  Copyright (c) 2015 Christopher Meehan. All rights reserved.
//

import UIKit
import CoreData
import CoreDataAccessFramework


class EditOneStepVC: UIViewController,UITextFieldDelegate {
    var existingIntruction:NSManagedObject!
    var textForThisStep:String!

    @IBOutlet weak var textField: UITextField!
    
    var indexOfStep:Int!
    var arrayOfSteps:Array<AnyObject>!
    var thisVCIsAnInsert = false
    var thisVCIsAnEdit = false
    var tVCToPopBackTo:UIViewController!
    var isThisAChecklistItem:Bool = false
    
    @IBOutlet weak var insertStepButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        
        if isThisAChecklistItem == false{   // Then this is a checklist item.
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
        
        textField.text = textForThisStep
        textField.becomeFirstResponder()
        if isThisAChecklistItem{
            insertStepButton.hidden = true
        }
    }
    
    @IBAction func save(sender: AnyObject) {
        if thisVCIsAnInsert { // Then we are inserting this text within the array.
            arrayOfSteps.insert(textField.text!, atIndex: indexOfStep)
            saveCommon()
            if sender.isMemberOfClass(UIButton) {
                navigationController?.popToViewController(tVCToPopBackTo, animated: true)
            }
        }
        else if thisVCIsAnEdit {
            arrayOfSteps[indexOfStep] = textField.text!
            saveCommon()
            if sender.isMemberOfClass(UIButton) {
                navigationController?.popViewControllerAnimated(true)
            }
        }
        else{
            if isThisAChecklistItem{   // Then this is a checklist item.
                let theText:String = textField.text!
                arrayOfSteps.append([theText,0])
            }
            else{    // THen this is a stepItem from an instruction.
                arrayOfSteps.append(textField.text!)
            }
            saveCommon()
            if sender.isMemberOfClass(UIButton) {
                navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if (range.length + range.location > textField.text?.characters.count){
            return false;
        }
        let newLength = (textField.text?.characters.count)! + string.characters.count - range.length
        return newLength <= 50
    }

    func saveCommon(){
        if isThisAChecklistItem{   // Then this is a checklist item.
            existingIntruction.setValue(arrayOfSteps, forKey: "arrayOfChecklistItems")
        }
        else{    // THen this is a stepItem from an instruction.
            existingIntruction.setValue(arrayOfSteps, forKey: "arrayOfSteps")
        }
        CoreDataAccess.sharedInstance.saveContext()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "InsertAnotherStepSegue"{
            if let eOSVC: EditOneStepVC = segue.destinationViewController as? EditOneStepVC {
                save("next")
                eOSVC.textForThisStep = ""
                eOSVC.existingIntruction = existingIntruction as NSManagedObject
                eOSVC.indexOfStep = indexOfStep+1
                eOSVC.arrayOfSteps = arrayOfSteps
                eOSVC.thisVCIsAnInsert = true
                eOSVC.tVCToPopBackTo = tVCToPopBackTo
            }
        }
    }
}
