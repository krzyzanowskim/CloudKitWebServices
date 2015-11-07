//
//  CloudKitWebServicesTests.swift
//  CloudKitWebServicesTests
//
//  Created by Marcin Krzyzanowski on 30/10/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

import XCTest
import CloudKit
@testable import CloudKitWebServices

class CloudKitWebServicesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSetup() {
        let webTokenAuth = CloudKit.Config.WebTokenAuth(webToken: "1234567890")
        let containerConfig = CloudKit.Config.ContainerConfig(webTokenAuth: webTokenAuth, containerIdentifier: "iCloud.blabla.bla", environment: .Production, apns: nil)
        let config = CloudKit.Config(containers: [containerConfig])
        let ck = CloudKit(config: config)

        XCTAssert(ck.config.containers.count == 1)
        XCTAssert(ck.config.containers.first!.webTokenAuth.webToken == "1234567890")
        XCTAssert(ck.config.containers.first!.webTokenAuth.persist == false)
    }
}
