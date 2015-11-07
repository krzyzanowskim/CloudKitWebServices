//
//  CKWAsset.swift
//  CloudKitWebServices
//
//  Created by Marcin Krzyzanowski on 07/11/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

import CloudKit

protocol CKAssetMeta {
    var size: NSNumber { get }
    var fileChecksum: String { get }
}

class CKWAsset: CKAsset {

    struct UploadMeta: CKAssetMeta {
        let receipt: String
        let size: NSNumber
        let fileChecksum: String
    }

    struct DownloadMeta: CKAssetMeta {
        let URL: NSURL
        let size: NSNumber
        let fileChecksum: String
    }

    var meta: CKAssetMeta?

    init(_ asset: CKAsset) {
        super.init(fileURL: asset.fileURL)
    }
}