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
}