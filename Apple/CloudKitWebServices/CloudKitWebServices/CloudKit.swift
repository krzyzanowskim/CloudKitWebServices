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

    static let maximumNumberOfOperationsInRequest = 200
    static let maximumNumberOfOperationsInResponse = 100
    static let maximumRecordSize = 1024
    static let maximumAssetFileSize = 1024 * 15

    enum ServerErrorCode: String, ErrorType {
        case ACCESS_DENIED // 0
        case ATOMIC_ERROR
        case AUTHENTICATION_FAILED // 2
        case AUTHENTICATION_REQUIRED
        case BAD_REQUEST
        case CONFLICT
        case EXISTS
        case INTERNAL_ERROR
        case NOT_FOUND
        case QUOTA_EXCEEDED
        case THROTTLED
        case TRY_AGAIN_LATER
        case VALIDATING_REFERENCE_ERROR
        case UNIQUE_FIELD_ERROR
        case ZONE_NOT_FOUND
        case UNKNOWN_ERROR
        case NETWORK_ERROR
        case SERVICE_UNAVAILABLE
        case INVALID_ARGUMENTS
        case UNEXPECTED_SERVER_RESPONSE
        case CONFIGURATION_ERROR
        case BAD_DATABASE
    }

    enum Environment: String {
        case Production = "production"
        case Development = "development"
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