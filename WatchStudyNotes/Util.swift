import Foundation
import UIKit
import Alamofire
import KeychainAccess

class Util {
    
    class func clearUserDefault(key: UserDefaultKey) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.stringForKey(key.rawValue) != nil {
            defaults.removeObjectForKey(key.rawValue)
        }
    }
    
    class func stringUserDefault(key: UserDefaultKey) -> String? {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.stringForKey(key.rawValue)
    }
    
    class func stringUserDefault(key: UserDefaultKey, ifNilThenReturn: String) -> String {
        let result = stringUserDefault(key)
        if result == nil { return ifNilThenReturn }
        else { return result! }
    }
    
    class func boolUserDefault(key: UserDefaultKey) -> Bool {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.boolForKey(key.rawValue)
    }
    
    class func arrayUserDefault(key: UserDefaultKey) -> [AnyObject]? {
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.arrayForKey(key.rawValue)
    }
    
    class func setUserDefault(key: UserDefaultKey, value: AnyObject!) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(value, forKey: key.rawValue)
    }
    
    class func setKeychain(key: KeychainKey, value: String) {
        let keychain = Keychain(service: Constants.KeychainService)
        keychain[key.rawValue] = value
    }
    
    class func stringKeychain(key: KeychainKey) -> String {
        let keychain = Keychain(service: Constants.KeychainService)
        if let value = keychain[key.rawValue] {
            return value
        }
        else {
            return ""
        }
    }
    
    class func clearKeychain(key: KeychainKey) {
        let keychain = Keychain(service: Constants.KeychainService)
        keychain.remove(key.rawValue)
    }
    
    class func showLoginUI(controller: UIViewController) {
        let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let loginViewController = loginStoryboard.instantiateInitialViewController() as! UIViewController
        controller.presentViewController(loginViewController, animated: true, completion: nil)
    }
    
    class func formatCurrencyFromStringWithoutDecimalPoint(string: String)-> String {
        let amount = (NSString(string: string).doubleValue)/100
        return formatCurrency(amount)
    }
    
    class func formatCurrencyFromStringWithDecimalPoint(string: String)-> String {
        let amount = (NSString(string: string).doubleValue)
        return formatCurrency(amount)
    }
    
    class func formatCurrency(amount: Double, withoutCents: Bool = false)-> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        if withoutCents {
            formatter.maximumFractionDigits = 0
        }
        return formatter.stringFromNumber(amount)!
    }
    
    class func handleMoneyTextboxChange(inout currentString: String, stringChanged: String)-> String {
        switch stringChanged {
        case "0","1","2","3","4","5","6","7","8","9":
            currentString += stringChanged
            return formatCurrencyFromStringWithoutDecimalPoint(currentString)
        default:
            var array = Array(stringChanged)
            var currentStringArray = Array(currentString)
            if array.count == 0 && currentStringArray.count != 0 {
                currentStringArray.removeLast()
                currentString = ""
                for character in currentStringArray {
                    currentString += String(character)
                }
            }
            return Util.formatCurrencyFromStringWithoutDecimalPoint(currentString)
        }
    }
    
    class func daysBetweenDates(date1: NSDate, date2: NSDate)-> Int {
        var startDate = date1
        var endDate = date2
        if startDate > endDate {
            startDate = date2
            endDate = date1
        }
        
        let cal = NSCalendar.currentCalendar()
        let unit:NSCalendarUnit = .CalendarUnitDay
        let components = cal.components(unit, fromDate: startDate, toDate: endDate, options: nil)
        return components.day
    }
}

// refer to: http://stackoverflow.com/a/9274863/346676
extension UITableView {
    func indexPathForView (view : UIView) -> NSIndexPath? {
        let location = view.convertPoint(CGPointZero, toView:self)
        return indexPathForRowAtPoint(location)
    }
}

// refer to: http://stackoverflow.com/a/28016692/346676
extension NSDate {
    var ISOFormatted: String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return formatter.stringFromDate(self)
    }
    
    var MonthDateFormatted: String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM-dd"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return formatter.stringFromDate(self)
    }
    
    var beginningOfThisWeek: NSDate {
        let cal = NSCalendar.currentCalendar()
        var beginningOfWeek: NSDate?
        var weekDuration = NSTimeInterval()
        cal.rangeOfUnit(.CalendarUnitWeekOfYear, startDate: &beginningOfWeek, interval: &weekDuration, forDate: self)
        return beginningOfWeek!
    }
}

extension String {
    var ISOFormattedStringToDate: NSDate {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let date = formatter.dateFromString(self)
        return date!
    }
    
    var ISOFormattedWithTimezoneStringToDate: NSDate {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let date = formatter.dateFromString(self)
        return date!
    }
}

extension UIColor {
    convenience init(r: Int, g:Int , b:Int) {
        self.init(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: 1.0)
    }
    
    class func turquoiseColor()->UIColor {
        return UIColor(r: 26, g: 188, b: 156)
    }
    
    class func greenSeaColor()->UIColor {
        return UIColor(r: 22, g: 160, b: 133)
    }
    
    class func emeraldColor()->UIColor {
        return UIColor(r: 46, g: 204, b: 113)
    }
    
    class func nephritisColor()->UIColor {
        return UIColor(r: 39, g: 174, b: 96)
    }
    
    class func peterRiverColor()->UIColor {
        return UIColor(r: 52, g: 152, b: 219)
    }
    
    class func belizeHoleColor()->UIColor {
        return UIColor(r: 41, g: 128, b: 185)
    }
    
    class func amethystColor()->UIColor {
        return UIColor(r:155, g:89, b:182)
    }
    
    class func wisteriaColor()->UIColor {
        return UIColor(r:142, g:68, b:173)
    }
    
    class func wetAsphaltColor()->UIColor {
        return UIColor(r:52, g:73, b:94)
    }
    
    class func midnightBlueColor()->UIColor {
        return UIColor(r:44, g:62, b:80)
    }
    
    class func sunflowerColor()->UIColor {
        return UIColor(r:241, g:196, b:15)
    }
    
    class func carrotColor()->UIColor {
        return UIColor(r:230, g:126, b:34)
    }
    
    class func pumpkinColor()->UIColor {
        return UIColor(r:211, g:84, b:0)
    }
    
    class func alizarinColor()->UIColor {
        return UIColor(r:231, g:76, b:60)
    }
    
    class func pomergranateColor()->UIColor {
        return UIColor(r:192, g:57, b:43)
    }
    
    class func cloudsColor()->UIColor {
        return UIColor(r:236, g:240, b:241)
    }
    
    class func silverColor()->UIColor {
        return UIColor(r:189, g:195, b:199)
    }
    
    class func concreteColor()->UIColor {
        return UIColor(r:149, g:165, b:166)
    }
    
    class func asbestosColor()->UIColor {
        return UIColor(r:127, g:140, b:141)
    }
    
}

func ==(left: APIRouter, right: APIRouter) -> Bool {
    if left.URLRequest == right.URLRequest {
        return true
    }
    else {
        return false
    }
}

// http://stackoverflow.com/a/28109990/346676
public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .OrderedSame
}
public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.compare(rhs) == .OrderedAscending
}
extension NSDate: Comparable, Equatable { }
