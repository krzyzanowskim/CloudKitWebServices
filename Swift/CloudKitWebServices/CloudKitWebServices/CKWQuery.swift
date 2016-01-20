//
//  CKWQuery.swift
//  CloudKitWebServices
//
//  Created by Marcin Krzyzanowski on 07/11/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

import CloudKit

struct CKWQuery: CKDictionaryRepresentable {

    enum Comparator: String {
        case EQUALS
        case NOT_EQUALS
        case LESS_THAN
        case LESS_THAN_OR_EQUALS
        case GREATER_THAN
        case GREATER_THAN_OR_EQUALS
        case NEAR
        case CONTAINS_ALL_TOKENS
        case IN
        case NOT_IN
        case CONTAINS_ANY_TOKENS
        case LIST_CONTAINS
        case NOT_LIST_CONTAINS
        case NOT_LIST_CONTAINS_ANY
        case BEGINS_WITH
        case NOT_BEGINS_WITH
        case LIST_MEMBER_BEGINS_WITH
        case NOT_LIST_MEMBER_BEGINS_WITH
        case LIST_CONTAINS_ALL
        case NOT_LIST_CONTAINS_ALL
    }

    struct Filter: CKDictionaryRepresentable {
        let comparator: Comparator
        let fieldName: String
        let fieldValue: CKRecordValue

        init(comparator: Comparator, fieldName: String, fieldValue: CKRecordValue) {
            self.comparator = comparator
            self.fieldName = fieldName
            self.fieldValue = fieldValue
        }

        init(comparator: Comparator, fieldName: CloudKit.SystemKeys, fieldValue: CKRecordValue) {
            self.init(comparator: comparator, fieldName: fieldName.rawValue, fieldValue: fieldValue)
        }

        func toCKDictionary() -> [String : AnyObject] {
            return ["comparator": comparator.rawValue, "fieldName": fieldName, "fieldValue": fieldValue.toCKDictionary()]
        }
    }

    struct Sort: CKDictionaryRepresentable {
        let fieldName: String
        let ascending: Bool
        // let relativeLocation

        init (fieldName: String, ascending: Bool = true) {
            self.fieldName = fieldName
            self.ascending = ascending
        }

        func toCKDictionary() -> [String: AnyObject] {
            return ["fieldName": fieldName, "ascending": ascending]
        }
    }

    // MARK: Properties

    let recordType: String
    var filterBy: [Filter]
    var sortBy: [Sort]

    // MARK: Functions

    init(recordType: String, filterBy: [Filter] = [], sortBy: [Sort] = []) {
        self.recordType = recordType
        self.filterBy = filterBy
        self.sortBy = sortBy
    }

    func toCKDictionary() -> [String: AnyObject] {
        var dict:[String: AnyObject] = ["recordType": recordType]

        if filterBy.count > 0 {
            dict["filterBy"] = filterBy.map { filter in
                return filter.toCKDictionary()
            }
        }

        if sortBy.count > 0 {
            dict["sortBy"] = sortBy.map { sort in
                return sort.toCKDictionary()
            }
        }

        return dict
    }
}
