//
//  CKRecord+Helpers.swift
//  CloudKitWebServices
//
//  Created by Marcin Krzyzanowski on 07/11/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

import CloudKit

extension CKRecord {
    func toCKDictionary() -> [String: AnyObject] {
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
}