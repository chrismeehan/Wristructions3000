// This class acts as the middlemain between the UIPageViewController, and the individual UIViewControllers it displays.

import UIKit

class uIPVC: UIViewController, UIPageViewControllerDataSource {
    
    var arrayOfMessages:NSArray = ["Everyone performs tasks (cooking, doing taxes, work, etc.) and it would sometimes be nice to have a simple, step by step reminder on how to do it exactly the same every time, and without missing any steps or timer alerts.\n\nThat’s what Wristructions does.\n\nIt's the simplest and quickest way for you to perform tasks that you would otherwise have to memorize." , "After you create a new Wristruction, you will add steps to it, and you have the option to add a checklist of items to prepare before beginning your task.\n\nThe steps within a task you will add one by one. It can either be an instruction step, or it can be a preset timer.","To set a timer, make sure you begin your step with \"Set a timer for\" and then include the length of time you want the timer.\n\nYou can also include a message you want the user to receive once the timer is completed. Here is an example of a task with 3 steps:\n\nPut the ingredients on the sheet.\nPut the sheet in the oven.\nSet a timer for 10 minutes that says cake is done cooking.","-Helpful Hints-\n\nTo ensure that any timers you set go off on the Watch and not the iPhone, you should force kill the app on the iPhone before beginning your task.\n\nAlso, for quickest results, during a task, you probably want the app to be presented every time you lift your wrist. So it is recommended that you go to your Apple Watch and:\n\ngo to the Settings app\n\nthen 'General'\n\nthen Enable Wake Screen\n\nthen 'Last Used App' or 'Previous Activity'.\n\n\nEnjoy!"]
    var pageViewController:UIPageViewController!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TheMainPageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        
        // This just grabs us the next UIViewController to display, we havent displayed it yet.
        let initialContenViewController = self.pageTutorialAtIndex(0) as IndividualTutorialPageVC
        let viewControllers = [initialContenViewController]
        
        
        self.pageViewController.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
    }
    
    
    
    // This method just sets up and returns a UIViewController to display
    func pageTutorialAtIndex(index: Int) ->IndividualTutorialPageVC{
        let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("IndividualTutorialPageVC") as! IndividualTutorialPageVC
        pageContentViewController.pageIndex = index
        pageContentViewController.labelString = arrayOfMessages[index] as? String
        return pageContentViewController
    }
    
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?{
        let viewController = viewController as! IndividualTutorialPageVC
        var index = viewController.pageIndex as Int
        if(index == 0 || index == NSNotFound) {
            return nil
        }
        index--
        return self.pageTutorialAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?{
        let viewController = viewController as! IndividualTutorialPageVC
        var index = viewController.pageIndex as Int
        if((index == NSNotFound)){
            return nil
        }
        index++
        if(index == arrayOfMessages.count){
            return nil
        }
        return self.pageTutorialAtIndex(index)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int{
        return arrayOfMessages.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int{
        return 0
    }
}