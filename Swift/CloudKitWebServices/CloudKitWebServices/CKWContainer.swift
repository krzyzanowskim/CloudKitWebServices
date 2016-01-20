//
//  CKWContainer.swift
//  CloudKitWebServices
//
//  Created by Marcin Krzyzanowski on 07/11/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//
//  CKWContainer is bridgeable to CKContainer, but it is not the same obeject becase CKContainer require
//  CloudKit provisioning installed for the app to be instanteniated. If the app has this setup already
//  it may use toCKContainer() go obtain CKContainer instance out of CKWContainers
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

    convenience init?(cloudKit: CloudKit, container: CKContainer) {
        guard let containerIdentifier = container.containerIdentifier else {
            return nil
        }

        self.init(cloudKit: cloudKit, identifier: containerIdentifier)
    }

    func toCKContainer() -> CKContainer {
        return CKContainer(identifier: containerIdentifier)
    }
}
