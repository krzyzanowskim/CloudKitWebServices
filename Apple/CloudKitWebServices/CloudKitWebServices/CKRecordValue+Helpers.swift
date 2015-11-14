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
        } else if let valueList = self as? [CKReference] {
            var list = [AnyObject]()
            for value in valueList {
                let referenceMeta = ["recordName": value.recordID.recordName, "zone": value.recordID.zoneID.zoneName, "action": value.referenceAction.toCKWReferenceAction().rawValue]
                list.append(referenceMeta)
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
        } else if let value = self as? CKWAsset, valueMeta = value.meta as? CKWAsset.UploadMeta {
            let assetMeta = ["receipt": valueMeta.receipt, "size": valueMeta.size, "fileChecksum": valueMeta.fileChecksum]
            field = ["type": "ASSETID", "value": assetMeta]
        }
        return field
    }
}
