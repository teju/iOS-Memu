//
//  RestDataSource.swift
//  Memu
//
//  Created by Akash Arun Jambhulkar (Digital) on 4/30/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SwiftyJSON
import Alamofire
import RxAlamofire

/// Errors
enum ErrorMessages: String {
    case resourceNotFound = "Resource not found"
    case sessionExpired = "Your session has expired, please log in again"
    case unknown = "Unknown error"
    
    /// localized text
    var text: String {
        return NSLocalizedString(rawValue, comment: rawValue)
    }
}

/// default limit
let kDefaultLimit = 99

/**
 * REST data source implementation
 *
 * - author: TCCODER
 * - version: 1.0
 */
public class RestDataSource {
    
    // MARK: - private

    /// API configuration
    static internal let appBaseUrl = Configuration.appBaseUrl.hasSuffix("/") ? Configuration.appBaseUrl : Configuration.appBaseUrl+"/"
    static private var accessToken: String? {
        return TokenUtil.accessToken
    }
    
    /// session manager
    public static let `default`: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = Configuration.timeoutInterval
        return SessionManager(configuration: configuration)
    }()
    
    /// loads json
    ///
    /// - Parameter name: json name
    /// - Returns: json as observable
    static func load(json name: String) -> Observable<JSON> {
        if let json = JSON.resource(named: name) {
            return Observable.just(json).restSend()
        } else {
            return Observable.error(NSLocalizedString("No such resource", comment: "No such resource"))
        }
    }

    

    ///V3 for common use :  json call shortcut
    ///
    /// - Parameters:
    ///   - method: request method
    ///   - url: relative url
    ///   - parameters: parameters
    ///   - encoding: parameters encoding
    ///   - headers: additional headers
    /// - Returns: request observable
    static func json(_ method: Alamofire.HTTPMethod, _ url: URLConvertible, parameters: [String: Any]? = nil, encoding: ParameterEncoding = JSONEncoding.default, headers: [String: String]? = nil, addAuthHeader: Bool = true) -> Observable<JSON> {
        var headers = headers ?? [:]
        if let token = accessToken, addAuthHeader {
            headers["Authorization"] = "\(token)"
        }
        var encoding = encoding
        if method == .get {
            encoding = URLEncoding.default
        }
        
        return RestDataSource.default.rx
            .request(method, "\(appBaseUrl)\(url)", parameters: parameters, encoding: encoding, headers: headers)
            .observeOn(ConcurrentDispatchQueueScheduler.init(qos: .default)) // process everything in background
            .responseData()
            .flatMap { (result: DataResponse<Data>) -> Observable<Data> in
                #if DEBUG
                if let request = result.request {
                    logRequest(request: request, true)
                    if let response = result.response {
                        logResponse(result.value as AnyObject, forRequest: request, response: response)
                    }
                }
                #endif
                if result.response?.statusCode == 401 && addAuthHeader {
                    TokenUtil.cleanup()
                    AuthenticationUtil.sharedInstance.cleanUp()
                    
                    // notify
                    if let viewController = UIApplication.shared.delegate?.window??.rootViewController {
//                        UserDefaults.eventId = ""
//                        UserDefaults.eventImageUrl = ""
//                        UserDefaults.isEventRegistered = false
//                        Switcher.updateRootVC(nil)
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                            viewController.showAlert("", ErrorMessages.sessionExpired.text)
//                        }
                    }

                    // do not trigger regular UI alert
                    return Observable<Data>.empty()
                }
                    // response value received
                else if let value = result.value {

                    // guard from error messages
                    guard let statusCode = result.response?.statusCode, 200...205 ~= statusCode else {
                        let errorText = JSON(value)["message"].string?.components(separatedBy: ":").last
                        let message: Error? = errorText
                        return Observable.error(message ?? result.error ?? ErrorMessages.resourceNotFound.text)
                    }
                    // successful response
                    return Observable.just(value)
                }
                // no value even
                return Observable.error(result.error ?? ErrorMessages.resourceNotFound.text)
        }
        .map { data in
            let json = (try? JSON(data: data)) ?? JSON.null
            return json
        }
    }
    
    /// json call shortcut
    ///
    /// - Parameters:
    ///   - method: request method
    ///   - url: relative url
    ///   - parameters: parameters
    ///   - encoding: parameters encoding
    ///   - headers: additional headers
    /// - Returns: request observable
    static func string(_ method: Alamofire.HTTPMethod, _ url: URLConvertible, parameters: [String: Any]? = nil, encoding: ParameterEncoding = JSONEncoding.default, headers: [String: String]? = nil, addAuthHeader: Bool = true) -> Observable<String> {
        var headers = headers ?? [:]
        if let token = accessToken, addAuthHeader {
            headers["Authorization"] = "\(token)"
        }
        var encoding = encoding
        if method == .get {
            encoding = URLEncoding.default
        }
        
        return RestDataSource.default.rx
            .request(method, "\(appBaseUrl)\(url)", parameters: parameters, encoding: encoding, headers: headers)
            .string()
    }

    
    
    /**
     Notifies with given request URL, Method and body

     - parameter request:       NSURLRequest to log
     - parameter needToLogBody: flag used to decide either to log body or not
     */
    public static func logRequest(request: URLRequest, _ needToLogBody: Bool) {
        // Log request URL
        var info = "url"
        if let method = request.httpMethod { info = method }
        let hash = "[H\(request.hashValue)]"
        var logMessage = "\(Date())"
        logMessage += "[REQUEST]\(hash)\n curl -X \(info) \"\(request.url!.absoluteString)\""

        if needToLogBody {
            // log body if set
            if let body = request.httpBody {
                if let bodyAsString = String(data: body, encoding: .utf8) {
                    logMessage += "\\\n\t -d '\(bodyAsString.replace("\n", withString: "\\\n"))'"
                }
            }
        }
        for (key,value) in request.allHTTPHeaderFields ?? [:] {
            logMessage += "\\\n\t -H \"\(key): \(value.replace("\"", withString: "\\\""))\""
        }
        print(logMessage)
    }

    /**
     Notifies with given response object.

     - parameter object: response object
     */
    private static func logResponse(_ object: AnyObject?, forRequest request: URLRequest, response: URLResponse?) {
        let hash = "[H\(request.hashValue)]"
        var info: String = "\(Date())<----------------------------------------------------------[RESPONSE]\(hash):\n"
        if let response = response as? HTTPURLResponse {
            info += "HTTP \(response.statusCode); headers:\n"
            for (key,value) in response.allHeaderFields {
                info += "\t\(key): \(value)\n"
            }
        } else {
            info += "<no response> "
        }
        if let obj: AnyObject = object {
            if let data = obj as? Data {
                let json = try? JSON(data: data, options: JSONSerialization.ReadingOptions.allowFragments)
                if let json = json {
                    info += "\(json)"
                } else {
                    info += "Data[length=\(data.count)]"
                    if data.count < 10000 {
                        info += "\n" + (String(data: data, encoding: .utf8) ?? "")
                    }
                }
            } else {
                info += String(describing: obj)
            }
        } else {
            info += "<null response>"
        }
        print(info)
    }
    
}

// MARK: - shortcut for REST service
extension Observable {
    
    /// wrap remote call in shareReplay & observe on main thread
    func restSend() -> Observable<Element> {
        return self.observeOn(MainScheduler.instance)
            .share(replay: 1)
    }
    
    /// discard result type
    func toVoid() -> Observable<Void> {
        return self.map { _ in }
    }
}


// MARK: - shortcut for observable chain
extension ObservableType where E == DataRequest {
    /// shortcut for observable chain
    public func responseData() -> Observable<DataResponse<Data>> {
        return self.flatMap { $0.rx.responseData() }
    }
}

// MARK: - data request reactive extension
extension Reactive where Base: DataRequest {

    /// shortcut for data response wrap
    public func responseData() -> Observable<DataResponse<Data>> {
        return Observable.create { observer in
            let request = self.base
            
            #if DEBUG
            print("\(request.request?.httpMethod ?? "GET") \(request.request?.url?.absoluteString ?? "")")
            if let data = request.request?.httpBody,
                let json = try? JSON(data: data) {

                print("\(json)")
            }
            #endif

            request.responseData { response in
                if let error = response.result.error {
                    observer.on(.error(error))
                } else {
                    observer.on(.next(response))
                    observer.on(.completed)
                }
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
