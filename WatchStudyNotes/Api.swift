import Foundation
import Alamofire
import SwiftyJSON

class Api {
    
    var delegate: ApiDelegate?
    
    func call(router: URLRequestConvertible) {
        Alamofire.request(router)
            .responseJSON { (req, res, json, error) in
                if(error != nil) {
                    self.delegate?.didReturnError(router, error: error)
                }
                else {
                    if res?.statusCode == 400 {
                        var jsonObj = SwiftyJSON.JSON(json!)
                        self.delegate?.didReturn400(router as! APIRouter, json: jsonObj)
                        log.error("req: \(req) | res: \(res) | json: \(json)")
                    }
                    else if res?.statusCode == 401 {
                        // try to recover by auto logging in again
                        // stored username/password has to be found in order to do auto login (without login UI)
                        if let username = Util.stringUserDefault(UserDefaultKey.Username) {
                                let password = Util.stringKeychain(KeychainKey.Password)
                                let url = Config.APIBaseUrl + "/Token"
                                let parameters = [
                                    "grant_type":"password",
                                    "username":username,
                                    "password":password]
                                
                                Alamofire.request(.POST, url, parameters: parameters, encoding: ParameterEncoding.URL)
                                    .responseJSON { (req, res, json, error) in
                                        if(error != nil) {
                                            self.cleanUpAfterFailedAutoLogin(router)
                                        }
                                        else {
                                            if res?.statusCode != 200 {
                                                self.cleanUpAfterFailedAutoLogin(router)
                                            }
                                            else {
                                                // login successfully, save user credential
                                                var json = SwiftyJSON.JSON(json!)
                                                Util.setKeychain(KeychainKey.AccessToken, value: json["access_token"].string!)
                                                // now logged in, try the same api call again
                                                self.call(router)
                                            }
                                        }
                                }
                        }
                        else {
                            self.cleanUpAfterFailedAutoLogin(router)
                        }
                    }
                    else if res?.statusCode == 406 {
                        var jsonObj = SwiftyJSON.JSON(json!)
                        self.delegate?.didReturn406(router as! APIRouter, json: jsonObj)
                        log.error("req: \(req) | res: \(res) | json: \(json)")
                    }
                    else if res?.statusCode >= 300 {
                        // successful response, but bad request. Shouldn't happen on non-dev environment
                        // todo: think of the best way to react just in case user did get this.
                        log.error("req: \(req) | res: \(res) | json: \(json)")
                    }
                    else {
                        if json == nil {
                            self.delegate?.didReturnOK(router as! APIRouter, json: JSON(""))
                        }
                        else {
                            var jsonObj = SwiftyJSON.JSON(json!)
                            self.delegate?.didReturnOK(router as! APIRouter, json: jsonObj)
                        }
                    }
                }
        }
    }
    
    func cleanUpAfterFailedAutoLogin(router: URLRequestConvertible) {
        // wrong username/password, clean up
        Util.clearUserDefault(UserDefaultKey.Username)
        Util.clearKeychain(KeychainKey.Password)
        self.delegate?.didReturn401(router)
    }
}
