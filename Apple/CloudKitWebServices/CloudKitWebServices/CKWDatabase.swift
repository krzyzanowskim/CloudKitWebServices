//
//  CKWDatabase.swift
//  CloudKitWebServices
//
//  Created by Marcin Krzyzanowski on 07/11/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//
//  TODO:
//  .UNKNOWN_ERROR for general NSError is not the most optimal way to deal with error. It is unknown because don't have CloudKit description, but it may be simply network error and atm it's not possible to figure out what it is.
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

    var urlSession: NSURLSession = {
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

        let parameters = ["zoneID": ["zoneName": zoneID.zoneName], "query": query.toCKDictionary()]
        let jsonData = try! NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions.PrettyPrinted)
        let requestTask = self.urlSession.uploadTaskWithRequest(postRequest(components.URL), fromData: jsonData) { (data, response, error) -> Void in
            var dstRecords = continuation?.records ?? []

            guard let data = data,
                  let jsonObject = try? NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
            else {
                completionHandler(dstRecords, .UNKNOWN_ERROR)
                return
            }

            guard let recordObjects = jsonObject?["records"] as? [AnyObject] else {
                if let serverErrorCodeString = jsonObject?["serverErrorCode"] as? String {
                    completionHandler(dstRecords, CloudKit.ServerErrorCode(rawValue: serverErrorCodeString))
                } else {
                    completionHandler(dstRecords, .UNKNOWN_ERROR)
                }
                return
            }

            for recordObject in recordObjects as? [[String: AnyObject]] ?? [] {
                let dstRecord = CKWRecord(dictionary: recordObject, zoneID: zoneID)
                dstRecords.append(dstRecord)
            }

            if let receivedContinuationMarkerString = jsonObject?["continuationMarker"] as? String {
                self.performQuery(query, inZoneWithID: zoneID, continuation: (marker: receivedContinuationMarkerString, records: dstRecords), completionHandler: completionHandler)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(dstRecords, nil)
                }
            }
        }
        requestTask.resume()
    }

    func modify(operationType: ModifyOperationType = .forceUpdate, inZoneWithID zoneID: CKRecordZoneID = CKRecordZoneID(zoneName: CKRecordZoneDefaultName, ownerName: CKOwnerDefaultName), records recordsToSave: [CKWRecord], completionHandler: (error: CloudKit.ServerErrorCode?) -> Void) {
        guard let components = NSURLComponents(URL: apiURL, resolvingAgainstBaseURL: false), let path = components.path else {
            completionHandler(error: .UNKNOWN_ERROR)
            return
        }

        precondition(recordsToSave.count <= CloudKit.maximumNumberOfOperationsInRequest, "Array<CKWRecord> length is greater than max size")

        components.path = "\(path)/records/modify"

        // 1. upload assets
        let assetUploadGroup = dispatch_group_create()

        if [.create, .update, .forceUpdate, .replace, .forceUpdate].contains(operationType) {
            for record in recordsToSave {
                for key in record.allKeys() where record[key] is CKAsset || record[key] is CKWAsset {
                    let ckwAsset = CKWAsset(record[key] as! CKAsset)
                    dispatch_group_enter(assetUploadGroup)
                    //TODO: upload
                    assetUpload(inZoneWithID: zoneID, asset: ckwAsset, recordType: record.recordType, fieldName: key, completionHandler: { (asset, error) -> Void in
                        record[key] = asset
                        dispatch_group_leave(assetUploadGroup)
                    })
                }
            }
        }

        //2. create/update records
        dispatch_group_notify(assetUploadGroup, dispatch_get_main_queue()) {
            let operations = recordsToSave.map { ckRecord -> [String: AnyObject] in
                var operation: [String: AnyObject] = ["operationType": operationType.rawValue]
                operation["record"] = [.delete, .forceDelete].contains(operationType) ? ["recordName": ckRecord.recordID.recordName] : ckRecord.toCKDictionary()
                return operation
            }

            let parameters = ["zoneID": ["zoneName": zoneID.zoneName], "operations": operations, "atomic": "false"]
            let jsonData = try! NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions.PrettyPrinted)
            let requestTask = self.urlSession.uploadTaskWithRequest(self.postRequest(components.URL), fromData: jsonData) { (data, response, error) -> Void in
//                do {
//                    try self.checkError(data)
//                } catch {
//                    completion(error: error)
//                    print(operations)
//                    return
//                }
                completionHandler(error: nil)
            }
            requestTask.resume()
        }
    }

    func assetUpload(inZoneWithID zoneID: CKRecordZoneID = CKRecordZoneID(zoneName: CKRecordZoneDefaultName, ownerName: CKOwnerDefaultName), asset: CKWAsset, recordType: String, fieldName: String, completionHandler: (asset: CKWAsset?, error: ErrorType?) -> Void) {
        guard let components = NSURLComponents(URL: apiURL, resolvingAgainstBaseURL: false), let path = components.path else {
            completionHandler(asset: nil, error: CloudKit.ServerErrorCode.UNKNOWN_ERROR as ErrorType)
            return
        }

        components.path = "\(path)/assets/upload"

        let tokens = [["recordType": recordType, "fieldName": fieldName]] as [[String:AnyObject]]
        let parameters = ["zoneID": ["zoneName": zoneID.zoneName], "tokens": tokens]

        let jsonData = try! NSJSONSerialization.dataWithJSONObject(parameters, options: NSJSONWritingOptions.PrettyPrinted)
        let requestTask = self.urlSession.uploadTaskWithRequest(self.postRequest(components.URL), fromData: jsonData) { (data, response, error) -> Void in
            guard let data = data, let jsonObject = try? NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject] else {
                completionHandler(asset: nil, error: CloudKit.ServerErrorCode.UNKNOWN_ERROR as ErrorType)
                return
            }
            
            if let tokens = jsonObject?["tokens"] as? [Dictionary<String, String>] {
                for tokenDictionary in tokens {
                    if let urlString = tokenDictionary["url"],
                       let uploadURL = NSURL(string: urlString)
                    {
                        let uploadTask = self.urlSession.uploadTaskWithRequest(self.postRequest(uploadURL), fromFile: asset.fileURL, completionHandler: { (data, response, error) in
                            guard let data = data, let jsonResponseObject = try? NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject] else {
                                completionHandler(asset: nil, error: error)
                                return
                            }

                            if let singleFileDictionary = jsonResponseObject?["singleFile"] as? [String: AnyObject] {
                                /*
                                {
                                    "singleFile" :{
                                        "wrappingKey" : [WRAPPING_KEY],
                                        "fileChecksum" : [SIGNATURE],
                                        "receipt" : [RECEIPT],
                                        "referenceChecksum" : [REFERENCE_CHECKSUM],
                                        "size" : [SIZE]
                                    }
                                }
                                */
                                if let receipt = singleFileDictionary["receipt"] as? String,
                                   let size = singleFileDictionary["size"] as? NSNumber,
                                   let fileChecksum = singleFileDictionary["fileChecksum"] as? String
                                {
                                    let wrappingKey = singleFileDictionary["wrappingKey"] as? String ?? ""
                                    let referenceChecksum = singleFileDictionary["referenceChecksum"] as? String ?? ""

                                    asset.info = CKWAsset.Info(fileChecksum: fileChecksum,
                                                                     size: size,
                                                                     receipt: receipt,
                                                                     wrappingKey: wrappingKey,
                                                                     referenceChecksum: referenceChecksum,
                                                                     downloadURL: nil)

                                    completionHandler(asset: asset, error: nil)
                                }
                            }
                        })
                        uploadTask.resume()
                    }
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
