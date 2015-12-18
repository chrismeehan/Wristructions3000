//
//  Instruction.swift
//  Wristructions
//
//  Created by Chris Meehan on 8/27/15.
//  Copyright (c) 2015 Christopher Meehan. All rights reserved.
//
// This represents a task. The moc uses it, and so do we in code.

import Foundation
import CoreData

@objc(Instruction) // If you don't put this, then your xcdatamodelid won't recognize this class.
class Instruction: NSManagedObject {
    @NSManaged var title: String
    @NSManaged var arrayOfSteps: Array<AnyObject>
    @NSManaged var arrayOfChecklistItems: Array<AnyObject>
}
