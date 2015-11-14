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

extension CKWRecord {
    func toCKRecordDictionary() -> [String: AnyObject] {
        var dict = [String: AnyObject]()

        var fields = [String: AnyObject]()
        for key in self.allKeys() {
            let value = self.valueForKey(key) as? CKRecordValue
            assert(value != nil, "no value")
            fields[key] = value?.toCKFieldDictionary()
        }
        dict["fields"] = fields
        dict["recordType"] = self.recordType
        dict["recordName"] = self.recordID.recordName
        return dict
    }

    func fromCKRecordFieldsDictionary(fields: [String: AnyObject]) {
        for field in fields {
            let name = field.0
            if let valueTypeMeta = field.1 as? [String: AnyObject] {
                self[name] = valueFromCKFieldValueDictionary(valueTypeMeta)
            }
        }
    }

    private func valueFromCKFieldValueDictionary(dictionary: [String: AnyObject]) -> CKRecordValue? {
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
                if let miliseconds = value as? Double where miliseconds != 0 {
                    return NSDate(timeIntervalSince1970: miliseconds / 1000)
                }
                return NSDate(timeIntervalSince1970: 0)
            case "REFERENCE":
                if let valueDict = value as? [String: AnyObject],
                   let recordName = valueDict["recordName"] as? String,
                   let action = valueDict["action"] as? String
                {
                    var zoneName = CKRecordZoneDefaultName
                    if let zoneIDDict = valueDict["zoneID"] as? [String: String] {
                        zoneName = zoneIDDict["zoneName"]!
                    }
                    return CKReference(recordID: CKRecordID(recordName: recordName, zoneID: CKRecordZoneID(zoneName: zoneName, ownerName: CKOwnerDefaultName)), action: CloudKit.CKWReferenceAction(rawValue: action)!.toCKReferenceAction())

                }
            case "STRING":
                return value as? String
            default:
                return value as? String
            }
        }
        return nil
    }
}
