//
//  BaseViewController.swift
//  WatchStudyNotes
//
//  Created by Weiran Ye on 8/26/15.
//  Copyright (c) 2015 Weiran Ye. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import JGProgressHUD

class BaseViewController: UIViewController, ApiDelegate, UIGestureRecognizerDelegate {
    
    private let api = Api()
    private var diabledViewsDuringAPICall: [UIView] = []
    private var timer: NSTimer!
    private var hud: JGProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        api.delegate = self
        
        // dismiss keyboard
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        hud = JGProgressHUD(style: JGProgressHUDStyle.Dark)
        hud.textLabel.text = "Loading"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func didReturnError(router: URLRequestConvertible, error: NSError?) {
        enableViews()
        self.showNetworkIssueTryAgainAlert()
    }
    
    func didReturn401(router: URLRequestConvertible) {
        enableViews()
        Util.showLoginUI(self)
    }
    
    func didReturn400(router: URLRequestConvertible, json: JSON) {
        enableViews()
    }
    
    func didReturn406(router: URLRequestConvertible, json: JSON) {
        enableViews()
    }
    
    func didReturnOK(router: APIRouter, json: JSON) {
        enableViews()
    }
    
    func markResumeToPage(page: ResumeToPage) {
        Util.setUserDefault(UserDefaultKey.ResumeToPage, value: page.rawValue)
    }
    
    func getResumeToPage()-> ResumeToPage {
        return ResumeToPage(rawValue: Util.stringUserDefault(UserDefaultKey.ResumeToPage, ifNilThenReturn: ResumeToPage.Home.rawValue))!
    }
    
    func presentStoryboard(storyboardName: String, animated: Bool) {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let viewcontroller = storyboard.instantiateInitialViewController() as! UIViewController
        self.presentViewController(viewcontroller, animated: animated, completion: nil)
    }
    
    func pushViewControllerFromOtherStoryboard(storyboardName: String, viewControllerIdentifier: String, animated: Bool) {
        let vc = UIStoryboard(name: storyboardName, bundle: nil).instantiateViewControllerWithIdentifier(viewControllerIdentifier) as! UIViewController
        self.navigationController?.pushViewController(vc, animated: animated)
    }
    
    func timerFired() {
        hud.showInView(self.view!)
    }
    
    func callAPI(router: APIRouter, viewsToDisable: [UIView]) {
        diabledViewsDuringAPICall = viewsToDisable
        disableViews()
        if timer == nil || !timer.valid {
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerFired", userInfo: nil, repeats: false)
        }
        api.call(router)
    }
    
    private func cancelTimer() {
        if timer.valid {
            timer.invalidate()
        }
    }
    
    private func disableViews() {
        for view in diabledViewsDuringAPICall {
            if view.isKindOfClass(UIButton) {
                let v = view as! UIButton
                v.enabled = false
            }
            else {
                println("Unkown kind of view. Don't know how to handle it.")
            }
        }
    }
    
    private func enableViews() {
        cancelTimer()
        hud.dismiss()
        for view in diabledViewsDuringAPICall {
            if view.isKindOfClass(UIButton) {
                let v = view as! UIButton
                v.enabled = true
            }
            else {
                println("Unkown kind of view. Don't know how to handle it.")
            }
        }
        diabledViewsDuringAPICall = []
    }
    
    // shake handling. refer to http://stackoverflow.com/a/10154991/346676
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.becomeFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.resignFirstResponder()
        super.viewWillAppear(animated)
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        super.motionEnded(motion, withEvent: event)
    }
    
    func showMessageBox(title: String, message: String, buttonTitle: String, handler: (UIAlertAction!) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okButton = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: handler)
        alert.addAction(okButton)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showMessageBox(title: String, message: String) {
        self.showMessageBox(title, message: message, buttonTitle: "OK", handler: {(_) in})
    }
    
    func showComingSoon() {
        self.showMessageBox("Coming Soon", message: "Feature is under construction.", buttonTitle: "OK", handler: {(_) in})
    }
    
    func showNetworkIssueTryAgainAlert() {
        self.showMessageBox("Network Issue", message: "Make sure you are online and try again later. ", buttonTitle: "OK", handler: {(_) in})
    }
}
