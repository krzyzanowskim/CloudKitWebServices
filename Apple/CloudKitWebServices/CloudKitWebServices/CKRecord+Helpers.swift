//
//  CKRecord+Helpers.swift
//  CloudKitWebServices
//
//  Created by Marcin Krzyzanowski on 07/11/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

import CloudKit

extension CKRecord {
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
                return value as? NSNumber
            case "STRING":
                return value as? String
            default:
                break
            }
            if let value = value as? String {
                return value
            }
        }
        return nil
    }
}
