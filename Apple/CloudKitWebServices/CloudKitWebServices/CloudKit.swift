//
//  CloudKit.swift
//  CloudKitWebServices
//
//  Created by Marcin Krzyzanowski on 30/10/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

import Foundation
import CloudKit

typealias CKWRecord = CKRecord

class CloudKit {

    enum Error: ErrorType {
    }

    enum Environment: String {
        case Production = "production"
        case Development = "development"
    }

    enum CKWReferenceAction: String {
        case Validate = "VALIDATE"
        case None = "NONE"
        case DeleteSelf = "DELETE_SELF"

        func toCKReferenceAction() -> CKReferenceAction {
            switch (self) {
            case .Validate, .None:
                return CKReferenceAction.None
            case .DeleteSelf:
                return CKReferenceAction.DeleteSelf
            }
        }
    }

    struct Config {

        struct APNSConfig {
            let environment: Environment
            let token: String
            let webcourierURL: NSURL
        }

        struct WebTokenAuth {
            let webToken: String
            let persist: Bool

            init(webToken: String, persist: Bool = false) {
                self.webToken = webToken
                self.persist = persist
            }
        }

        struct ContainerConfig {
            let webTokenAuth: WebTokenAuth
            let containerIdentifier: String
            let environment: Environment
            let apns: APNSConfig?
        }

        let containers: [ContainerConfig]
    }

    // MARK: Properties

    let config: Config
    

    // MARK: Functions

    init(config: Config) {
        self.config = config
    }

    func configForContainer(identifier: String) -> Config.ContainerConfig? {
        guard let keyIdx = config.containers.indexOf({ $0.containerIdentifier == identifier}) else {
            return nil
        }
        
        return config.containers[keyIdx]
    }

    func defaultContainer() -> CKWContainer? {
        return getContainer(config.containers.first?.containerIdentifier)
    }

    func getContainer(identifier: String?) -> CKWContainer? {
        guard let containerConfig = config.containers.first where containerConfig.containerIdentifier == identifier else {
            return nil
        }

        return CKWContainer(cloudKit: self, identifier: containerConfig.containerIdentifier)
    }

    func getAllContainers() -> [CKWContainer] {
        return config.containers.map({ getContainer($0.containerIdentifier)! })
    }
}