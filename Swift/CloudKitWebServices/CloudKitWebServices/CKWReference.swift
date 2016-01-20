//
//  CKWReference.swift
//  CloudKitWebServices
//
//  Created by Marcin Krzyzanowski on 13/01/16.
//  Copyright © 2016 Marcin Krzyżanowski. All rights reserved.
//

import CloudKit

typealias CKWReference = CKReference

extension CKWReference: CKDictionaryRepresentable {
    func toCKDictionary() -> [String : AnyObject] {
        return ["recordName": self.recordID.recordName, "zone": self.recordID.zoneID.zoneName, "action": self.referenceAction.toCKWReferenceAction().rawValue]
    }
}