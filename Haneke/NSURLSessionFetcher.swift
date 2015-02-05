//
//  NSURLSessionFetcher.swift
//  Pods
//
//  Created by Jun Seki on 04/02/2015.
//
//


import UIKit

extension HanekeGlobals {
    
    // It'd be better to define this in the NetworkFetcher class but Swift doesn't allow to declare an enum in a generic type
    public struct NSURLSessionFetcher {
        
        public enum ErrorCode : Int {
            case InvalidData = -400
            case MissingData = -401
            case InvalidStatusCode = -402
        }
        
    }
    
}

//protocol NSURLSessionFetcherDelegate{
//    func downloadComplete(url : NSURL!, response: NSURLResponse!, error : NSError!)
//}

public class NSURLSessionFetcher<T : DataConvertible> : Fetcher<T> {
    
    let URL : NSURL
    
    public init(URL : NSURL) {
        self.URL = URL
        
        let key =  URL.absoluteString!
        super.init(key: key)
    }
    
     var delegate = DownloadSessionDelegate.sharedInstance
    
    var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    
    public var session : NSURLSession { return NSURLSession(configuration: configuration, delegate: self.delegate, delegateQueue: NSOperationQueue()) }
    
    var task : NSURLSessionDownloadTask? = nil
    
    var cancelled = false
    
    public func downloadComplete(url : NSURL!, response : NSURLResponse!, error : NSError!){
        if let goodUrl = url{
            var data = NSData(contentsOfURL: goodUrl)
            println("got data")
            //self.onReceiveData(data, response: response, error: error, failure: fail, success: succeed)
        }
    }
    // MARK: Fetcher
    
    public override func fetch(failure fail : ((NSError?) -> ()), success succeed : (T.Result) -> ()) {
        self.cancelled = false
        
        let request = NSMutableURLRequest(URL: self.URL)
        request.timeoutInterval = 20.0
        self.task = session.downloadTaskWithRequest(request){[weak self] (url : NSURL!, response : NSURLResponse!, error : NSError!) -> Void in
            if let strongSelf = self {
                if let goodUrl = url{
                    var data = NSData(contentsOfURL: goodUrl)
                        strongSelf.onReceiveData(data, response: response, error: error, failure: fail, success: succeed)
                }
            }
        }
        self.task?.resume()
        
//        self.task = self.session.dataTaskWithURL(self.URL) {[weak self] (data : NSData!, response : NSURLResponse!, error : NSError!) -> Void in
//            if let strongSelf = self {
//                strongSelf.onReceiveData(data, response: response, error: error, failure: fail, success: succeed)
//            }
//        }
//        self.task?.resume()
    }
    
    public override func cancelFetch() {
        self.task?.cancel()
        self.cancelled = true
    }
    
    // MARK: Private
    
    public func onReceiveData(data : NSData!, response : NSURLResponse!, error : NSError!, failure fail : ((NSError?) -> ()), success succeed : (T.Result) -> ()) {
        
        if cancelled { return }
        
        let URL = self.URL
        
        if let error = error {
            if (error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled) { return }
            
            Log.error("Request \(URL.absoluteString!) failed", error)
            dispatch_async(dispatch_get_main_queue(), { fail(error) })
            return
        }
        
        // Intentionally avoiding `if let` to continue in golden path style.
        let httpResponse : NSHTTPURLResponse! = response as? NSHTTPURLResponse
        if httpResponse == nil {
            Log.error("Request \(URL.absoluteString!) received unknown response \(response)")
            return
        }
        
        if httpResponse?.statusCode != 200 {
            let description = NSHTTPURLResponse.localizedStringForStatusCode(httpResponse.statusCode)
            self.failWithCode(.InvalidStatusCode, localizedDescription: description, failure: fail)
            return
        }
        
        if !httpResponse.hnk_validateLengthOfData(data) {
            let localizedFormat = NSLocalizedString("Request expected %ld bytes and received %ld bytes", comment: "Error description")
            let description = String(format:localizedFormat, response.expectedContentLength, data.length)
            self.failWithCode(.MissingData, localizedDescription: description, failure: fail)
            return
        }
        
        let value : T.Result? = T.convertFromData(data)
        if value == nil {
            let localizedFormat = NSLocalizedString("Failed to convert value from data at URL %@", comment: "Error description")
            let description = String(format:localizedFormat, URL.absoluteString!)
            self.failWithCode(.InvalidData, localizedDescription: description, failure: fail)
            return
        }
        
        dispatch_async(dispatch_get_main_queue()) { succeed(value!) }
        
    }
    
    private func failWithCode(code : HanekeGlobals.NetworkFetcher.ErrorCode, localizedDescription : String, failure fail : ((NSError?) -> ())) {
        // TODO: Log error in debug mode
        let error = errorWithCode(code.rawValue, description: localizedDescription)
        dispatch_async(dispatch_get_main_queue()) { fail(error) }
    }
    

    

    
}