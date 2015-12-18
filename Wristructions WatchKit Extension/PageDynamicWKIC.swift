//
//  PageDynamicWKIC.swift
//  Wristructions
//
//  Created by Chris Meehan on 8/29/15.
//  Copyright (c) 2015 Christopher Meehan. All rights reserved.
//

import WatchKit
import Foundation
import CoreData
import CoreDataAccessFramework


class PageDynamicWKIC: WKInterfaceController,UIScrollViewDelegate {


    @IBOutlet weak var timerImage: WKInterfaceGroup!
    @IBOutlet weak var buttonLabel: WKInterfaceLabel!
    @IBOutlet weak var previousButton: WKInterfaceButton!
    var testDate = NSDate()
    @IBOutlet weak var WKTimer: WKInterfaceTimer!
    var timerIndeciesWithABool:Array<Array<Int>>! // index number, then hasTimerBeenSetBefore
    @IBOutlet weak var skipTimerButton: WKInterfaceButton!
    @IBOutlet weak var stepLabel: WKInterfaceLabel!
    @IBOutlet weak var button: WKInterfaceButton!
    var currentStepNum:Int!
    var arrayOfSteps:Array<String>!
    var numberAsString:String!
    var weAreCurrentlyReadingANumber = false   // We haven't seen one yet of course
    var weAreTryingToFindADigitAndNotAUnitOfTime = true    //  At first we are looking for: 8,4,5,     not   "minutes", "hours", "seconds".
    var isItADecimalValue = false
    var numOfSecondsForTimer:Int!
    var firstTimeSeeingInstructions:Int = Int(1)
    var isThisATimerTriggerStep = false
    var hasThisTimerBeenTriggered = false
    var theTitle:String!
    var wasAnyTimerEverSet:Bool = false
    
    
    func loadAllTimerIndeciesWithABool(){
        timerIndeciesWithABool = Array()
        for (index, _) in arrayOfSteps.enumerate() {
            let stepString:String = arrayOfSteps[index]
            // alternative: not case sensitive
            let range:Range<String.Index>? = stepString.lowercaseString.rangeOfString("a timer for")
            if  range != nil {   // This is a timer start button then, we are only presenting it.
                timerIndeciesWithABool.append([index,Int(0)])
            }
        }
    }
    
    func loadScreenNumber(indexNum:Int){
        if wasAnyTimerEverSet {
            WKTimer.setHidden(false)
        }
        else{
            WKTimer.setHidden(true)
        }
        stepLabel.setHidden(false)
        hasThisTimerBeenTriggered = false
        currentStepNum = indexNum
        // Is this step a timer trigger?                                                                 [context,index]
        isThisATimerTriggerStep = false // Assume no, until we are told otherwise.
        for(_,context) in timerIndeciesWithABool.enumerate(){ // There may be 3 items in the timerArray, = [ [row3,0], [row14,0],[row20,0] ]
            if indexNum == context[0] as Int{
                isThisATimerTriggerStep = true
                if Int(1) == context[1]{ // It is a timer trigger, but has it been set?
                    hasThisTimerBeenTriggered = true
                }
            }
        }
        
        if isThisATimerTriggerStep {
            timerImage.setHidden(false)
            if hasThisTimerBeenTriggered{ // It has been triggered before
                buttonLabel.setTextColor(UIColor.lightGrayColor())
                buttonLabel.setText("This timer has already been set.")
                //button.setTitle("This timer has already been set.")
                skipTimerButton.setHidden(true)
            }
            else{ // This timer has never been triggered.
                numOfSecondsForTimer = turnThisStringIntoANumberOfSeconds(arrayOfSteps[indexNum] as String)
                let formated:String = convertSecondsIntoHMS(numOfSecondsForTimer)
                buttonLabel.setTextColor(UIColor.greenColor())
                buttonLabel.setText("Tap to start the timer of " + formated)
                // Give them the option to skip the timer, but only if it's not the last step.
                skipTimerButton.setHidden(false)
            }
        }
        else{ // This is a normal, non-timer step.
            timerImage.setHidden(true)
            skipTimerButton.setHidden(true)
            buttonLabel.setTextColor(UIColor.whiteColor())
            buttonLabel.setText(arrayOfSteps[indexNum])
        }
        
        stepLabel.setText("step \(currentStepNum+Int(1)) of \(arrayOfSteps.count)")
        currentStepNum = indexNum
        if indexNum == 0 {
            previousButton.setTitle("")
            previousButton.setEnabled(false)
        }
        else{
            previousButton.setEnabled(true)
            previousButton.setTitle("previous")
        }
    }
    
    func ifThisIsATimerPressThenSetATimer(){
        if isThisATimerTriggerStep && !hasThisTimerBeenTriggered{
            setATimerOfSeconds(numOfSecondsForTimer)
            for(index,context) in timerIndeciesWithABool.enumerate(){ // There may be 3 items in the timerArray, = [ [row3,0], [row14,0],[row20,0] ]
                if currentStepNum == context[0] as Int{ // If this timer we have, matches the row we are on....Then this is our timer object.
                    timerIndeciesWithABool[index] = [context[0] as Int,Int(1)]
                }
            }
        }
    }


    @IBAction func previousWasHit() {
        loadScreenNumber(currentStepNum - Int(1))
        stepLabel.setTextColor(UIColor.whiteColor()) // Only when you go backward, do you run the risk of having a blackened out stepLabel.
    }
    
    @IBAction func buttonPressed() {   // This gets called whenever you click the largest button on the screen.
        if arrayOfSteps.count == currentStepNum { // Make sure we bail out now if were reading out of bounds.
            popToRootController()
        }
        else{
            ifThisIsATimerPressThenSetATimer()
            if arrayOfSteps.count == currentStepNum+1{ // If we are going to right out of bounds, were done.
                currentStepNum = currentStepNum + Int(1) // If this number ever gets used at this point, then out of bounds
                if wasAnyTimerEverSet{
                    buttonLabel.setText("As long as all your timers have completed, you are done!")
                }
                else{
                    buttonLabel.setText("You are done! \n Click to finish.")
                }
                buttonLabel.setTextColor(UIColor.cyanColor())
                stepLabel.setTextColor(UIColor.blackColor())
                timerImage.setHidden(true)
                skipTimerButton.setHidden(true)
            }
            else{
                loadScreenNumber(currentStepNum + Int(1))
            }
        }
    }
    

    @IBAction func skipTimerHit() {
        if arrayOfSteps.count == currentStepNum+1{ // If we are going to right out of bounds, were done.
            currentStepNum = currentStepNum + Int(1) // If this number ever gets used at this point, then out of bounds
            if wasAnyTimerEverSet{
                buttonLabel.setText("As long as all your timers have completed, you are done! \n Click to finish.")
            }
            else{
                buttonLabel.setText("You are done! \n Click to finish.")
            }
            buttonLabel.setTextColor(UIColor.cyanColor())
            stepLabel.setTextColor(UIColor.blackColor())
            timerImage.setHidden(true)
            skipTimerButton.setHidden(true)
        }
        else{
            loadScreenNumber(currentStepNum + Int(1))
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        var array:Array<AnyObject> = context as! Array<AnyObject>  //   [arrayOfSteps, currentIndex]
        arrayOfSteps = array[0] as! Array<String>
        theTitle = array[1] as! String
        if arrayOfSteps.count == Int(0){
            arrayOfSteps = ["You have not added any steps for this task."]
        }
        loadAllTimerIndeciesWithABool()
    }

    override func willActivate() { // This will only get called once.
        super.willActivate()
        setTitle(theTitle)
        if firstTimeSeeingInstructions == Int(1){
            currentStepNum = Int(0)
            loadAllTimerIndeciesWithABool()
            firstTimeSeeingInstructions = Int(0)
            loadScreenNumber(0)
        }
    }

    
    // I think returning nil should mean the format is bad.
    func turnThisStringIntoANumberOfSeconds(theString:String) -> Int!{
        var stringy = theString
        let range:Range<String.Index>! = stringy.lowercaseString.rangeOfString("that says ")
        let range2:Range<String.Index>! = stringy.lowercaseString.rangeOfString("saying ")
        
        if range != nil{
            let endIndex2 = range.startIndex
            stringy = stringy.substringWithRange(Range<String.Index>(start: stringy.startIndex, end: endIndex2))
        }
        else if range2 != nil{
            let endIndex2 = range2.startIndex
            stringy = stringy.substringWithRange(Range<String.Index>(start: stringy.startIndex, end: endIndex2))
        }
        var totalNumOfSeconds:Int = 0
        //Create a temp to concatinate numbers to
        numberAsString = ""
        isItADecimalValue = false
        weAreTryingToFindADigitAndNotAUnitOfTime = true
        weAreCurrentlyReadingANumber = false
        //Find the 1st number
        for tempChar in stringy.characters {
            if weAreTryingToFindADigitAndNotAUnitOfTime{ // Looking to see a digit
                if weAreCurrentlyReadingANumber{ // We have already been reading numbers, so we are looking for more.
                    switch tempChar {
                    case "0","1","2","3","4","5","6","7","8","9": // Add another digit to our growing digitString!
                        numberAsString.append(tempChar)
                    case ".":
                        numberAsString.append(tempChar) // Add a dot to our digitString.
                        isItADecimalValue = true
                    default:
                        // This is a char, so the digitString is over, lets find a unit of time now.
                        weAreTryingToFindADigitAndNotAUnitOfTime = false
                    }
                }
                else{   // We have not read a digit yet, but we are looking for one to start us.
                    switch tempChar {
                    case "0","1","2","3","4","5","6","7","8","9":   // Found our first digit!
                        weAreCurrentlyReadingANumber = true
                        numberAsString = ""
                        numberAsString.append(tempChar)
                    case ".":                                       // Found our first digit, and its a dot!
                        weAreCurrentlyReadingANumber = true
                        isItADecimalValue = true
                        numberAsString = "0."
                    default:
                        weAreTryingToFindADigitAndNotAUnitOfTime = true   // I am doing this to relax the compiler
                        //Otherwise its a char, and I don't care about that right now.
                    }
                }
            }
            else{ // We are looking for a unit of time, not a digit.
                switch tempChar {
                case "0","1","2","3","4","5","6","7","8","9":
                    // There is a digit?  But we are looking for a unit of time. Return nil.
                    return nil
                default:
                    // We got a char, lets see if it's a s,m,or h
                    if tempChar == "s"{
                        // We got an "s" for seconds, lets add calculate it all up and add it to our timeInterval.
                        if isItADecimalValue{
                            totalNumOfSeconds = totalNumOfSeconds + Int((numberAsString as NSString).doubleValue)
                        }
                        else{
                            totalNumOfSeconds = totalNumOfSeconds + Int(numberAsString)!
                        }
                        resetDigitFinder()
                    }
                    else if tempChar == "m"{
                        // We got an "m" for minutes, lets add calculate it all up and add it to our timeInterval.
                        if isItADecimalValue{
                            totalNumOfSeconds = totalNumOfSeconds + Int(60 * (numberAsString as NSString).doubleValue)
                        }
                        else{
                            totalNumOfSeconds = totalNumOfSeconds + Int( 60 * Int(numberAsString)!)
                        }
                        resetDigitFinder()
                    }
                    else if tempChar == "h"{
                        // We got an "h" for hours, lets add calculate it all up and add it to our timeInterval.
                        if isItADecimalValue{
                            totalNumOfSeconds = totalNumOfSeconds + Int( 3600 * (numberAsString as NSString).doubleValue)
                        }
                        else{
                            totalNumOfSeconds = totalNumOfSeconds + Int( 3600 * Int(numberAsString)!)
                        }
                        resetDigitFinder()
                    }
                    else{
                        // Otherwise, ignore any char I'm seeing.
                    }
                }
            }
        }
        return totalNumOfSeconds
    }
    

    
    func resetDigitFinder(){
        isItADecimalValue = false
        weAreTryingToFindADigitAndNotAUnitOfTime = true
        weAreCurrentlyReadingANumber = false
        numberAsString = ""
    }

    func setATimerOfSeconds(numOfSecs:Int){
        scheduleNotification(numOfSecs)
        WKTimer.setDate(NSDate(timeIntervalSinceNow: NSTimeInterval(numOfSecs)))
        WKTimer.start()
        WKTimer.setHidden(false)
        wasAnyTimerEverSet = true
    }
    
    func getTimerMessage() -> String{
        let thisRowsString:String = arrayOfSteps[currentStepNum]
        let range:Range<String.Index>! = thisRowsString.lowercaseString.rangeOfString("that says ")
        let range2:Range<String.Index>! = thisRowsString.lowercaseString.rangeOfString("saying ")
        if range != nil{
            let endIndex2 = range.endIndex
            let someString = thisRowsString.substringWithRange(Range<String.Index>(start: endIndex2, end: thisRowsString.endIndex))
            return someString
        }
        else if range2 != nil{
            let endIndex2 = range2.endIndex
            let someString = thisRowsString.substringWithRange(Range<String.Index>(start: endIndex2, end: thisRowsString.endIndex))
            return someString
        }
        return ""
    }
    
    func scheduleNotification(seconds: Int) {
        let message:String = getTimerMessage()
        let userInfo = [
            "scheduleLocalNotification": true,
            "category": "someCategory2",
            "alertBody": message,
            "fireDate": NSDate(timeIntervalSinceNow: NSTimeInterval(seconds)),
            "numOfSeconds": Int(seconds),
            "applicationIconBadgeNumber": 0,
            "soundName": UILocalNotificationDefaultSoundName
        ]
        // Register notifications in iOS
        WKInterfaceController.openParentApplication(userInfo) {
            (replyInfo, error) -> Void in
            // Callback here if needed
        }
    }
 
    func convertSecondsIntoHMS(totalSeconds:Int) -> String{
        let seconds = totalSeconds % 60;
        let minutes = (totalSeconds / 60) % 60;
        let hours = totalSeconds / 3600;
        var stringToAddTo = ""
        var theAndComesBeforeThe:String = ""
        if 0 < seconds {
            if 0 < minutes || 0 < hours {
                theAndComesBeforeThe = "seconds"
            }
        }
        else if 0 < minutes {
            if 0 < hours {
                theAndComesBeforeThe = "minutes"
            }
        }
        if hours==0{
            // Do nothing.
        }
        else if hours==1{
            stringToAddTo = stringToAddTo + "\(hours) " + "hour "
        }
        else{
            stringToAddTo = stringToAddTo + "\(hours) " + "hours "
        }
        if minutes==0{
            // Do nothing.
        }
        else if minutes==1{
            if theAndComesBeforeThe == "minutes" {
                stringToAddTo = stringToAddTo + "and "
            }
            stringToAddTo = stringToAddTo + "\(minutes) " + "minute "
        }
        else{
            if theAndComesBeforeThe == "minutes" {
                stringToAddTo = stringToAddTo + "and "
            }
            stringToAddTo = stringToAddTo + "\(minutes) " + "minutes "
        }
        if seconds==0{
            // Do nothing.
        }
        else if seconds==1{
            if theAndComesBeforeThe == "seconds" {
                stringToAddTo = stringToAddTo + "and "
            }
            stringToAddTo = stringToAddTo + "\(seconds) " + "second "
        }
        else{
            if theAndComesBeforeThe == "seconds" {
                stringToAddTo = stringToAddTo + "and "
            }
            stringToAddTo = stringToAddTo + "\(seconds) " + "seconds "
        }
        return stringToAddTo
    }
}
