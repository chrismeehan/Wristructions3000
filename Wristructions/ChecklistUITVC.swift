//
//  ChecklistUITVC.swift
//  Wristructions
//
//  Created by Chris Meehan on 9/6/15.
//  Copyright (c) 2015 Christopher Meehan. All rights reserved.
//

// This class represent your Pre-Checklist for a task, for iPhone.

import UIKit

class ChecklistUITVC: UITableViewCell {

    @IBOutlet weak var buttonCheck: UIButton! // Check\Uncheck button
    @IBOutlet weak var label: UILabel!
    var parentVC:ChecklistUITV! // The cell will hold the uitableview it is contained within, so it can notify it of clicks.
    var indexNum:Int! // index num of the task object.
    
    @IBAction func buttonCheckSelected(sender: AnyObject) {
        parentVC.aCellHadItsBoxChecked(indexNum) // Tell the uitableview what cell was just checked/unchecked.
    }
    
}
