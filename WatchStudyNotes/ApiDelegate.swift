import Foundation
import Alamofire
import SwiftyJSON

protocol ApiDelegate {
    
    func didReturnError(router: URLRequestConvertible, error: NSError?)
    func didReturn400(router: URLRequestConvertible, json: JSON)
    func didReturn401(router: URLRequestConvertible)
    func didReturn406(router: URLRequestConvertible, json: JSON)
    func didReturnOK(router: APIRouter, json: JSON)
}
