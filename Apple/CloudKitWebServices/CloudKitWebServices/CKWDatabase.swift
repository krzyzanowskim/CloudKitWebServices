//
//  CKWDatabase.swift
//  CloudKitWebServices
//
//  Created by Marcin Krzyzanowski on 07/11/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

import CloudKit

class CKWDatabase: NSObject {

    enum AccessType: String {
        case Public = "public"
        case Private = "private"
    }

    // MARK: - Properties

    var containerIdentifier: String {
        return container.containerIdentifier
    }

    private let type: AccessType
    private let container: CKWContainer
    var sessionToken: String?

    private var urlSession: NSURLSession = {
        let sessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        sessionConfiguration.HTTPAdditionalHeaders = ["Content-Type": "application/json; charset=UTF-8"]
        return NSURLSession(configuration: sessionConfiguration)
    }()

    private var apiURL: NSURL {
        guard let webToken = container.config?.webTokenAuth.webToken, let environment = container.config?.environment.rawValue else {
            fatalError("Can't read web token")
        }

        let validQueryCharacterSet = NSCharacterSet(charactersInString: "+/=").invertedSet
        let safeAPIToken = webToken.stringByAddingPercentEncodingWithAllowedCharacters(validQueryCharacterSet)!

        var urlString = "https://api.apple-cloudkit.com/database/1/\(container.containerIdentifier)/\(environment)/\(type.rawValue)?ckAPIToken=\(safeAPIToken)"
        if let sessionToken = self.sessionToken {
            let safeSessionToken = sessionToken.stringByAddingPercentEncodingWithAllowedCharacters(validQueryCharacterSet) ?? ""
            urlString.appendContentsOf("&ckSession=\(safeSessionToken)")
        }
        let components = NSURLComponents(string: urlString)!
        return components.URL!
    }

    // MARK: - Functions

    init(container: CKWContainer, type: AccessType = .Public) {
        self.type = type
        self.container = container
    }

    func performQuery(query: CKWQuery, inZoneWithID zoneID: CKRecordZoneID = CKRecordZoneID(zoneName: CKRecordZoneDefaultName, ownerName: CKOwnerDefaultName), continuation: (marker: String, records: [CKWRecord])? = nil, completionHandler: ([CKWRecord], CloudKit.ServerErrorCode?) -> Void) {
        guard let components = NSURLComponents(URL: apiURL, resolvingAgainstBaseURL: false), let path = components.path else {
            completionHandler([], .UNKNOWN_ERROR)
            return
        }

        components.path = "\(path)/records/query"

        let parameters:[String: AnyObject] = ["zoneID": ["zoneName": zoneID.zoneName], "query": query.toCKQueryDictionary()]
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions.PrettyPrinted)
        let requestTask = urlSession.uploadTaskWithRequest(postRequest(components.URL), fromData: jsonData) { (data, response, error) -> Void in
            var dstRecords = continuation?.records ?? [CKWRecord]()

            guard let data = data else {
                completionHandler(dstRecords, .UNKNOWN_ERROR)
                return
            }

            if let jsonObject = try? NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject] {
                guard let recordObjects = jsonObject?["records"] as? [AnyObject] else {
                    if let serverErrorCodeString = jsonObject?["serverErrorCode"] as? String {
                        completionHandler(dstRecords, CloudKit.ServerErrorCode(rawValue: serverErrorCodeString))
                    } else {
                        completionHandler(dstRecords, .UNKNOWN_ERROR)
                    }
                    return
                }

                for recordObject in recordObjects {
                    let recordName = recordObject["recordName"] as! String
                    let recordType = recordObject["recordType"] as! String

                    let dstRecord = CKWRecord(recordType: recordType, recordID: CKRecordID(recordName: recordName, zoneID: zoneID))
                    dstRecord.fromCKRecordFieldsDictionary(recordObject["fields"] as? [String: AnyObject] ?? [:])
                    dstRecords.append(dstRecord)
                }

                if let receivedContinuationMarkerString = jsonObject?["continuationMarker"] as? String {
                    self.performQuery(query, inZoneWithID: zoneID, continuation: (marker: receivedContinuationMarkerString, records: dstRecords), completionHandler: completionHandler)
                } else {
                    completionHandler(dstRecords, nil)
                }
            }
        }
        requestTask.resume()
    }

    // MAKR: Private

    private func postRequest(url: NSURL?) -> NSURLRequest {
        guard let url = url else {
            fatalError("missing URL")
        }

        let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringCacheData, timeoutInterval: NSTimeInterval(60))
        request.HTTPMethod = "POST"
        return request
    }
}
