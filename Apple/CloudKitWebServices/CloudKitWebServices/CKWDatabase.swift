//
//  CKWDatabase.swift
//  CloudKitWebServices
//
//  Created by Marcin Krzyzanowski on 07/11/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

import CloudKit

class CKWDatabase: NSObject {

    enum AccessType: String {
        case Public = "public"
        case Private = "private"
    }

    // MARK: - Properties

    var containerIdentifier: String {
        return container.containerIdentifier
    }

    private let type: AccessType
    private let container: CKWContainer
    private var sessionToken: String?

    private var urlSession: NSURLSession = {
        let sessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        sessionConfiguration.HTTPAdditionalHeaders = ["Content-Type": "application/json; charset=UTF-8"]
        return NSURLSession(configuration: sessionConfiguration)
    }()

    private var apiURL: NSURL {
        guard let webToken = container.config?.webTokenAuth.webToken, let environment = container.config?.environment.rawValue else {
            fatalError("Can't read web token")
        }

        let validQueryCharacterSet = NSCharacterSet(charactersInString: "+/=").invertedSet
        let safeAPIToken = webToken.stringByAddingPercentEncodingWithAllowedCharacters(validQueryCharacterSet)!

        var urlString = "https://api.apple-cloudkit.com/database/1/\(container.containerIdentifier)/\(environment)/\(type.rawValue)?ckAPIToken=\(safeAPIToken)"
        if let sessionToken = self.sessionToken {
            let safeSessionToken = sessionToken.stringByAddingPercentEncodingWithAllowedCharacters(validQueryCharacterSet) ?? ""
            urlString.appendContentsOf("&ckSession=\(safeSessionToken)")
        }
        let components = NSURLComponents(string: urlString)!
        return components.URL!
    }

    // MARK: - Functions

    init(container: CKWContainer, type: AccessType = .Public) {
        self.type = type
        self.container = container
    }

    func performQuery(query: CKQuery, inZoneWithID zoneID: CKRecordZoneID?, completionHandler: ([CKRecord]?, NSError?) -> Void) {
        guard let components = NSURLComponents(URL: apiURL, resolvingAgainstBaseURL: false), let basePath = components.path else {
            return
        }

        components.path = "\(basePath)/records/query"

//        let queryDictionary:[String: AnyObject] = ["recordType": query.recordType]
//        let parameters:[String: AnyObject] = ["zoneID": ["zoneName": zoneName], "query": queryDictionary]
//        let jsonData = try! JSON(parameters).rawData()

    }
}
