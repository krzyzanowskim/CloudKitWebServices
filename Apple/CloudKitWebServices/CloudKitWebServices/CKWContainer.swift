//
//  CKWContainer.swift
//  CloudKitWebServices
//
//  Created by Marcin Krzyzanowski on 07/11/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

import CloudKit

class CKWContainer: NSObject {

    weak var cloudKit: CloudKit?
    let containerIdentifier: String
    var config: CloudKit.Config.ContainerConfig? {
        return cloudKit?.configForContainer(containerIdentifier)
    }

    lazy var publicCloudDatabase:CKWDatabase = {
        return CKWDatabase(container: self, type: .Public)
    }()

    lazy var privateCloudDatabase:CKWDatabase = {
        return CKWDatabase(container: self, type: .Public)
    }()

    init(cloudKit: CloudKit, identifier containerIdentifier: String) {
        self.cloudKit = cloudKit
        self.containerIdentifier = containerIdentifier
    }

    func toCKContainer() -> CKContainer {
        return CKContainer(identifier: containerIdentifier)
    }
}
