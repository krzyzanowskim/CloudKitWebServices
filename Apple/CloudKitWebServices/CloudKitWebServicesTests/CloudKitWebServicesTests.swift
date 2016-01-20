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

    func testCKWRecord() {
        let record = CKWRecord(recordType: "RecordType", recordID: CKRecordID(recordName: "RecordName", zoneID: CKRecordZoneID(zoneName: "ZoneName", ownerName: "OwnerName")))
        record["field1"] = NSData()
        record["field2"] = NSDate()
        record["field3"] = NSNumber(double: 2.0)
        record["field4"] = NSNumber(int: 2)
        let dictionary = record.toCKDictionary()
        XCTAssertEqual(dictionary["recordType"] as? String, "RecordType")
        XCTAssertEqual(dictionary["recordName"] as? String, "RecordName")

        let fields = dictionary["fields"] as! [String:AnyObject]
        XCTAssert(fields.count == 4)
        XCTAssert(fields["field1"]?["type"] == "BYTES")
        XCTAssert(fields["field2"]?["type"] == "TIMESTAMP")
        XCTAssert(fields["field3"]?["type"] == "DOUBLE")
        XCTAssert(fields["field4"]?["type"] == "INT64")
    }
}
