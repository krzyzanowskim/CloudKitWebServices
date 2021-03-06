//
//  CKWRecord+Helpers.swift
//  CloudKitWebServices
//
//  Created by Marcin Krzyzanowski on 07/11/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//
//  TODO: lists, location
//

import CloudKit

typealias CKWRecord = CKRecord

extension CKWRecord: CKDictionaryRepresentable {
    func toCKDictionary() -> [String: AnyObject] {
        var dict = [String: AnyObject]()

        var fields = [String: AnyObject]()
        for key in self.allKeys() {
            let value = self.valueForKey(key) as? CKRecordValue
            assert(value != nil, "no value")
            fields[key] = value?.toCKDictionary()
        }
        dict["fields"] = fields
        dict["recordType"] = self.recordType
        dict["recordName"] = self.recordID.recordName
        return dict
    }

    convenience init(dictionary: [String : AnyObject], zoneID: CKRecordZoneID) {
        self.init(recordType: dictionary["recordType"] as! String, recordID: CKRecordID(recordName: dictionary["recordName"] as! String, zoneID: zoneID))
        self.loadCKRecordSystemFieldsDictionary(dictionary)
        self.loadCKRecordFieldsDictionary(dictionary)
    }

    //TODO: check this in the wild
    private func loadCKRecordSystemFieldsDictionary(recordObject: [String: AnyObject]) {
        if let modificationDateValue = recordObject["modified"]?["timestamp"] as? NSTimeInterval {
            self[CloudKit.SystemKeys.modificationDate.rawValue] = NSDate(timeIntervalSince1970: modificationDateValue / 1000)
        }

        if let creationDateValue = recordObject["created"]?["timestamp"] as? NSTimeInterval {
            self[CloudKit.SystemKeys.creationDate.rawValue] = NSDate(timeIntervalSince1970: creationDateValue / 1000)
        }
    }

    private func loadCKRecordFieldsDictionary(dictionary: [String: AnyObject]) {
        guard let fields = dictionary["fields"] as? [String: AnyObject] else {
            assertionFailure("fields key is expected")
            return
        }

        func valueFromCKFieldValueDictionary(dictionary: [String: AnyObject]) -> CKRecordValue? {

            func downloadAsset(downloadURL: NSURL) -> NSURL? {
                // TODO: map downloadURL to CKWAsset with synchonous request - this could be lazy resolve, but I don't have functionality to make it now
                // something like CKLazyAsset where temporaryURL is resolved on download, not earlier
                var resolvedTemporaryURL: NSURL? = nil

                let downloadSemaphore = dispatch_semaphore_create(0)
                let downloadSession = NSURLSession.sharedSession().downloadTaskWithURL(downloadURL, completionHandler: { (temporaryFileURL, response, error) -> Void in
                    resolvedTemporaryURL = temporaryFileURL
                    dispatch_semaphore_signal(downloadSemaphore)
                })
                downloadSession.resume()
                dispatch_semaphore_wait(downloadSemaphore, dispatch_time(DISPATCH_TIME_NOW, Int64(60 * Double(NSEC_PER_SEC))))
                return resolvedTemporaryURL
            }

            if let type = dictionary["type"] as? String,
                let value = dictionary["value"]
            {
                switch (type) {
                case "INT64":
                    return NSNumber(integer: value as? Int ?? 0)
                case "DOUBLE":
                    return NSNumber(double: value as? Double ?? 0)
                case "BYTES":
                    return NSData(base64EncodedString: value as? String ?? "", options: [])
                case "TIMESTAMP":
                    guard let miliseconds = value as? Double where miliseconds != 0 else {
                        return NSDate(timeIntervalSince1970: 0)
                    }
                    return NSDate(timeIntervalSince1970: miliseconds / 1000)
                case "REFERENCE":
                    if let valueDict = value as? [String: AnyObject],
                        let recordName = valueDict["recordName"] as? String,
                        let action = valueDict["action"] as? String
                    {
                        var zoneName = CKRecordZoneDefaultName
                        if let zoneIDDict = valueDict["zoneID"] as? [String: String] {
                            zoneName = zoneIDDict["zoneName"]!
                        }
                        return CKReference(recordID: CKRecordID(recordName: recordName, zoneID: CKRecordZoneID(zoneName: zoneName, ownerName: CKOwnerDefaultName)), action: CKWReferenceAction(rawValue: action)!.toCKReferenceAction())

                    }
                case "ASSETID":
                    if let valueDict = value as? [String: AnyObject],
                       let encodedURLString = (valueDict["downloadURL"] as? String)?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()),
                       let downloadURL = NSURL(string: encodedURLString),
                       let resolvedTemporaryURL = downloadAsset(downloadURL)
                    {
                        return CKWAsset(fileURL: resolvedTemporaryURL)
                    }
                case "ASSETID_LIST":
                    var assets: [CKAsset] = []
                    for valueDict in value as? [[String: AnyObject]] ?? [] {
                        if let encodedURLString = (valueDict["downloadURL"] as? String)?.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()),
                           let downloadURL = NSURL(string: encodedURLString),
                           let resolvedTemporaryURL = downloadAsset(downloadURL)
                        {
                            assets.append(CKWAsset(fileURL: resolvedTemporaryURL))
                        }
                    }
                    
                    return assets
                case "STRING":
                    return value as? String
                default:
                    return value as? String
                }
            }
            return nil
        }

        for field in fields {
            let name = field.0
            if let valueTypeMeta = field.1 as? [String: AnyObject] {
                self[name] = valueFromCKFieldValueDictionary(valueTypeMeta)
            }
        }
    }
}
