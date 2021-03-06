//
//  CKWAsset.swift
//  CloudKitWebServices
//
//  Created by Marcin Krzyzanowski on 07/11/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

import CloudKit

protocol CKAssetInfoCommon: CKDictionaryRepresentable {
    var fileChecksum: String { get }
    var size: NSNumber { get }
    var receipt: String { get }
}

extension CKAssetInfoCommon {
    func toCKDictionary() -> [String: AnyObject] {
        return ["receipt": self.receipt,
                "size": self.size,
                "fileChecksum": self.fileChecksum]
    }
}

protocol CKAssetInfoPrivate: CKDictionaryRepresentable {
    var wrappingKey: String { get }
    var referenceChecksum: String { get }
}

extension CKAssetInfoPrivate {
    func toCKDictionary() -> [String: AnyObject] {
        return ["wrappingKey": self.wrappingKey,
                "referenceChecksum": self.referenceChecksum]
    }
}

protocol CKAssetDownloadInfo {
    var downloadURL: NSURL? { get }
}

class CKWAsset: CKAsset {

    struct Info: CKAssetInfoCommon, CKAssetInfoPrivate, CKAssetDownloadInfo, CKDictionaryRepresentable {
        let fileChecksum: String
        let size: NSNumber
        let receipt: String

        let wrappingKey: String
        let referenceChecksum: String

        // This key is present only when fetching the enclosing record
        let downloadURL: NSURL?

        func toCKDictionary() -> [String: AnyObject] {
            return (self as CKAssetInfoCommon).toCKDictionary() + (self as CKAssetInfoPrivate).toCKDictionary()
        }
    }

    var info: CKAssetInfoCommon?

    required override init(fileURL: NSURL) {
        super.init(fileURL: fileURL)
    }

    convenience init(_ asset: CKAsset) {
        self.init(fileURL: asset.fileURL)
    }
}

private func + <K,V>(left: Dictionary<K,V>, right: Dictionary<K,V>) -> Dictionary<K,V>
{
    var map = Dictionary<K,V>()
    for (k, v) in left {
        map[k] = v
    }
    for (k, v) in right {
        map[k] = v
    }
    return map
}