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

    func testQueryRequest1() {
        let mockURLSession = FailableURLSession(responseData: NSData())

        let webTokenAuth = CloudKit.Config.WebTokenAuth(webToken: "693262c0b14349e9949c603233b2fe956ff9e253ba1999d7add5407d12688191")
        let containerConfig = CloudKit.Config.ContainerConfig(webTokenAuth: webTokenAuth, containerIdentifier: "iCloud.com.nibbleapps.FitMenCook", environment: .Development, apns: nil)
        let config = CloudKit.Config(containers: [containerConfig])
        let ck = CloudKit(config: config)

        let expectation = self.expectationWithDescription("query")

        if let database = ck.defaultContainer()?.publicCloudDatabase {
            database.urlSession = mockURLSession
            database.sessionToken = "39__25__ASEZ2XmlRNTwns0CLJfnPU8jQqYg9rij03pSelqusgwWNfcBpIV+B7J6rAk5Gov29Onh4Lvr43y9NH9khiGa8mRRV44yDiFshZm3jp30Qc931K8vd649+JAyTYJSbNAyXtsgk54skDWSahTQ21FB8DsEpRKmgPVvuqoVU3r/KKhWUCvAeR5G4PDn9v8yAE9gO/IB09Vj__QXBwbDoxOgEzfKCCKumwHVoULljMHI+H0hbdml0pQfl4MJdrvZynyqvfRAcuis1PrDKGnXWGkfgl9/O2cdH3++dX2rDV0yjV"

            let query = CKWQuery(recordType: "Tag")
            database.performQuery(query, completionHandler: { (records, error) -> Void in
                XCTAssert(error != nil, "Pass")
                XCTAssert(records.count == 0, "Pass")
                expectation.fulfill()
            })
        }

        self.waitForExpectationsWithTimeout(30, handler: nil)
    }

//    func testQuery() {
//        let webTokenAuth = CloudKit.Config.WebTokenAuth(webToken: "693262c0b14349e9949c603233b2fe956ff9e253ba1999d7add5407d12688191")
//        let containerConfig = CloudKit.Config.ContainerConfig(webTokenAuth: webTokenAuth, containerIdentifier: "iCloud.com.nibbleapps.FitMenCook", environment: .Development, apns: nil)
//        let config = CloudKit.Config(containers: [containerConfig])
//        let ck = CloudKit(config: config)
//
//        let expectation = self.expectationWithDescription("query")
//
//        if let database = ck.defaultContainer()?.publicCloudDatabase {
//            database.sessionToken = "39__25__ASEZ2XmlRNTwns0CLJfnPU8jQqYg9rij03pSelqusgwWNfcBpIV+B7J6rAk5Gov29Onh4Lvr43y9NH9khiGa8mRRV44yDiFshZm3jp30Qc931K8vd649+JAyTYJSbNAyXtsgk54skDWSahTQ21FB8DsEpRKmgPVvuqoVU3r/KKhWUCvAeR5G4PDn9v8yAE9gO/IB09Vj__QXBwbDoxOgEzfKCCKumwHVoULljMHI+H0hbdml0pQfl4MJdrvZynyqvfRAcuis1PrDKGnXWGkfgl9/O2cdH3++dX2rDV0yjV"
//
//            let query = CKWQuery(recordType: "Tag")
//            database.performQuery(query, completionHandler: { (records, error) -> Void in
//                XCTAssert(error == nil, "Pass")
//                XCTAssert(records.count > 0, "Pass")
//                expectation.fulfill()
//            })
//        }
//
//        self.waitForExpectationsWithTimeout(30, handler: nil)
//    }

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
