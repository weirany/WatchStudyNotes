import Foundation
import Alamofire

enum APIRouter: URLRequestConvertible {
    static let baseURLString =  Config.APIBaseUrl
    static var OAuthToken: String?
    
    // GET
    case GetIncome()
    case GetExpenses()
    case GetBankAccounts()
    case GetCreditCards()
    case GetSummary()
    case GetChartDailyBalanceForecastNoGoal(String)
    case StartTracking()
    // POST
    case PostIncome([String: AnyObject])
    case PostExpense([String: AnyObject])
    case PostBankAccount([String: AnyObject])
    case PostCreditCard([String: AnyObject])
    case PostSpend([String: AnyObject])
    case PostRegister([String: AnyObject])
    case PostRegisterPermanent([String: AnyObject])
    case PostGoal([String: AnyObject])
    // PUT
    case PutGoal([String: AnyObject])
    case PutDailyAllowance(AnyObject)
    // DELETE
    case DeleteIncome(String)
    case DeleteExpense(String)
    case DeleteAccount(String)
    
    var method: Alamofire.Method {
        switch self {
        case .GetIncome, .GetExpenses, .GetBankAccounts, .GetCreditCards, .GetSummary, .GetChartDailyBalanceForecastNoGoal, .StartTracking:
            return .GET
        case .PostIncome, .PostExpense, .PostBankAccount, .PostCreditCard, .PostSpend, .PostRegister, .PostRegisterPermanent, .PostGoal:
            return .POST
        case .PutGoal, .PutDailyAllowance:
            return .PUT
        case .DeleteIncome, .DeleteExpense, .DeleteAccount:
            return .DELETE
        }
    }
    
    var path: String {
        switch self {
        case .PostIncome, .GetIncome:
            return "/api/Income/"
        case .PostExpense, .GetExpenses:
            return "/api/Expenses/"
        case .GetBankAccounts:
            return "/api/Accounts/BankAccounts/"
        case .PostBankAccount:
            return "/api/Accounts/BankAccount/"
        case .GetCreditCards:
            return "/api/Accounts/CreditCards/"
        case .PostCreditCard:
            return "/api/Accounts/CreditCard/"
        case .PostSpend:
            return "/api/Transactions/Spend/"
        case .PostRegister:
            return "/api/Account/Register/"
        case .PostRegisterPermanent:
            return "/api/Account/RegisterPermanent/"
        case .GetSummary:
            return "/Summary/"
        case .DeleteIncome(let incomeId):
            return "/api/Income/\(incomeId)/"
        case .DeleteExpense(let expenseId):
            return "/api/Expenses/\(expenseId)/"
        case .DeleteAccount(let accountId):
            return "/api/Accounts/\(accountId)/"
        case .PostGoal, .PutGoal:
            return "/api/Goal/"
        case .GetChartDailyBalanceForecastNoGoal(let numOfMonth):
            return "/charts/dailyBalanceForecast/nogoal/\(numOfMonth)/"
        case .PutDailyAllowance:
            return "/DailyAllowance/"
        case .StartTracking:
            return "/StartTracking/"
        }
    }
    
    var parameters: [String: AnyObject]? {
        switch self {
        case .PostIncome(let parameters): return parameters
        case .PostExpense(let parameters): return parameters
        case .PostBankAccount(let parameters): return parameters
        case .PostCreditCard(let parameters): return parameters
        case .PostSpend(let parameters): return parameters
        case .PostRegister(let parameters): return parameters
        case .PostRegisterPermanent(let parameters): return parameters
        case .PostGoal(let parameters): return parameters
        case .PutGoal(let parameters): return parameters
        case .PutDailyAllowance(_): return [String: AnyObject]()
        default: return nil
        }
    }
    
    var valueParam: AnyObject? {
        switch self {
        case .PutDailyAllowance(let value): return value
        default: return nil
        }
    }

    var URLRequest: NSURLRequest {
        let URL = NSURL(string: APIRouter.baseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        // if OAuthToken is missing from the user defaults, then the request will get 401. (except Register)
        APIRouter.OAuthToken = Util.stringKeychain(KeychainKey.AccessToken)
        if let token = APIRouter.OAuthToken {
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // encode param
        if self.parameters != nil && self.parameters?.count > 0 {
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        }
        else if self.valueParam != nil {
            var JSONValue = { (urlRequest: URLRequestConvertible, parameters: [String : AnyObject]?) -> (NSURLRequest, NSError?) in
                var error: NSError?
                var mutableURLRequest: NSMutableURLRequest! = urlRequest.URLRequest.mutableCopy() as! NSMutableURLRequest
                mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                mutableURLRequest.HTTPBody = ("\(self.valueParam!)" as NSString).dataUsingEncoding(NSUTF8StringEncoding)
                return (mutableURLRequest, error)
            }
            return Alamofire.ParameterEncoding.Custom(JSONValue).encode(mutableURLRequest, parameters: parameters).0
        }
        return mutableURLRequest
    }
}

enum UserDefaultKey: String {
    case Username = "username"
    case ResumeToPage = "ResumeToPage"
    case NoteItems = "NoteItems"
    case FrequenceInMinutes = "FrequenceInMinutes"
}

enum KeychainKey: String {
    case AccessToken = "accessToken"
    case Password = "password"
}

enum ResumeToPage: String {
    case Home = "Home"
}
