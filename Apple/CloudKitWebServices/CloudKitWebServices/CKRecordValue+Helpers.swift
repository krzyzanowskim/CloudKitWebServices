//
//  CKRecordValue+Helpers.swift
//  CloudKitWebServices
//
//  Created by Marcin Krzyzanowski on 07/11/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

import CloudKit

extension CKRecordValue {
    func toCKFieldDictionary() -> [String: AnyObject] {
        var field = [String: AnyObject]()
        if let value = self as? CKReference {
            let referenceMeta = ["recordName": value.recordID.recordName, "zone": value.recordID.zoneID.zoneName, "action": value.referenceAction.toCKWReferenceAction().rawValue]
            field = ["type": "REFERENCE", "value": referenceMeta]
        } else if let value = self as? NSNumber {
            field = ["type": "INT64", "value": value]
        } else if let value = self as? String {
            field = ["type": "STRING", "value": value]
        } else if let value = self as? CKWAsset, valueMeta = value.meta as? CKWAsset.UploadMeta {
            let assetMeta = ["receipt": valueMeta.receipt, "size": valueMeta.size, "fileChecksum": valueMeta.fileChecksum]
            field = ["type": "ASSETID", "value": assetMeta]
        }
        return field
    }
}