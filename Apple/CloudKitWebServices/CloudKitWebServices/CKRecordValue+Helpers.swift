//
//  CKRecordValue+Helpers.swift
//  CloudKitWebServices
//
//  Created by Marcin Krzyzanowski on 07/11/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//
//  TODO: 
//  - Location
//  - Lists... [DOUBLE], [BYTES], ... etc
//

import CloudKit

extension CKRecordValue {
    func toCKFieldDictionary() -> [String: AnyObject] {
        var field = [String: AnyObject]()
        if let value = self as? CKReference {
            let referenceMeta = ["recordName": value.recordID.recordName, "zone": value.recordID.zoneID.zoneName, "action": value.referenceAction.toCKWReferenceAction().rawValue]
            field = ["type": "REFERENCE", "value": referenceMeta]
        } else if let valueList = self as? [CKReference] where !valueList.isEmpty {
            let list = valueList.map { value in
                return ["recordName": value.recordID.recordName, "zone": value.recordID.zoneID.zoneName, "action": value.referenceAction.toCKWReferenceAction().rawValue]
            }
            field = ["type": "REFERENCE_LIST", "value": list]
        } else if let value = self as? NSNumber where value.isReal() {
            field = ["type": "DOUBLE", "value": value]
        } else if let value = self as? NSNumber where !value.isReal() {
            field = ["type": "INT64", "value": value]
        } else if let value = self as? NSData {
            field = ["type": "BYTES", "value": value.base64EncodedStringWithOptions([])]
        } else if let value = self as? NSDate {
            field = ["type": "TIMESTAMP", "value": value.timeIntervalSince1970 * 1000]
        } else if let value = self as? String {
            field = ["type": "STRING", "value": value]
        } else if let value = self as? CKWAsset, valueInfo = value.info as? CKWAsset.Info {
            field = ["type": "ASSETID", "value": valueInfo.toCKDictionary()]
        } else if let valueList = self as? [CKWAsset] where !valueList.isEmpty {
            let fields = valueList.flatMap { value -> [String:AnyObject]? in
                return value.toCKFieldDictionary()
            }
            field = ["type": "ASSETID_LIST", "value": fields]
        }
        return field
    }
}
