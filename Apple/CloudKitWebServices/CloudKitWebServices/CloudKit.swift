//
//  CloudKit.swift
//  CloudKitWebServices
//
//  Created by Marcin Krzyzanowski on 30/10/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

import Foundation
import CloudKit


class CloudKit {

    static let maximumNumberOfOperationsInRequest = 200
    static let maximumNumberOfOperationsInResponse = 100
    static let maximumRecordSize = 1024
    static let maximumAssetFileSize = 1024 * 15

    enum ServerErrorCode: ErrorType {
        case ACCESS_DENIED // 0
        case ATOMIC_ERROR
        case AUTHENTICATION_FAILED // 2
        case AUTHENTICATION_REQUIRED(NSURL)
        case BAD_REQUEST
        case CONFLICT
        case EXISTS
        case INTERNAL_ERROR
        case NOT_FOUND
        case QUOTA_EXCEEDED
        case THROTTLED
        case TRY_AGAIN_LATER(Double)
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

        init(rawValue: String, value: AnyObject? = nil) {
            switch (rawValue) {
            case "ACCESS_DENIED":
                self = .ACCESS_DENIED
            case "ATOMIC_ERROR":
                self = .ATOMIC_ERROR
            case "AUTHENTICATION_FAILED":
                self = .AUTHENTICATION_FAILED
            case "AUTHENTICATION_REQUIRED":
                self = .AUTHENTICATION_REQUIRED(value as! NSURL)
            case "BAD_REQUEST":
                self = .BAD_REQUEST
            case "CONFLICT":
                self = .CONFLICT
            case "EXISTS":
                self = .EXISTS
            case "INTERNAL_ERROR":
                self = .INTERNAL_ERROR
            case "NOT_FOUND":
                self = .NOT_FOUND
            case "QUOTA_EXCEEDED":
                self = .QUOTA_EXCEEDED
            case "THROTTLED":
                self = .THROTTLED
            case "TRY_AGAIN_LATER":
                self = .TRY_AGAIN_LATER(value as! Double)
            case "VALIDATING_REFERENCE_ERROR":
                self = .VALIDATING_REFERENCE_ERROR
            case "UNIQUE_FIELD_ERROR":
                self = .UNIQUE_FIELD_ERROR
            case "ZONE_NOT_FOUND":
                self = .ZONE_NOT_FOUND
            case "UNKNOWN_ERROR":
                self = .UNKNOWN_ERROR
            case "NETWORK_ERROR":
                self = .NETWORK_ERROR
            case "SERVICE_UNAVAILABLE":
                self = .SERVICE_UNAVAILABLE
            case "INVALID_ARGUMENTS":
                self = .INVALID_ARGUMENTS
            case "UNEXPECTED_SERVER_RESPONSE":
                self = .UNEXPECTED_SERVER_RESPONSE
            case "CONFIGURATION_ERROR":
                self = .CONFIGURATION_ERROR
            case "BAD_DATABASE":
                self = .BAD_DATABASE
            default:
                self = .UNKNOWN_ERROR
            }
        }
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

    /// System keys because CKRecord["modificationDate"] is protected and cannot be modified
    /// Please use this placeholder to work with system fields
    enum SystemKeys: String {
        case modificationDate = "___modTime"
        case creationDate = "___createTime"
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