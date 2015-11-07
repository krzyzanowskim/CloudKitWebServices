//
//  CKWQuery.swift
//  CloudKitWebServices
//
//  Created by Marcin Krzyzanowski on 07/11/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

import CloudKit

struct CKWQuery {

    struct Filter {
        let comparator: String
        let fieldName: String
        let fieldValue: CKRecordValue

        func toCKFilterDictionary() -> [String: AnyObject] {
            return ["comparator": comparator, "fieldName": fieldName, "fieldValue": fieldValue.toCKFieldDictionary()]
        }
    }

    struct Sort {
        let fieldName: String
        let ascending: Bool
        // let relativeLocation

        init (fieldName: String, ascending: Bool = true) {
            self.fieldName = fieldName
            self.ascending = ascending
        }

        func toCKSortDescriptorDictionary() -> [String: AnyObject] {
            return ["fieldName": fieldName, "ascending": ascending]
        }
    }

    // MARK: Properties

    let recordType: String
    var filterBy: [Filter]?
    var sortBy: [Sort]?

    // MARK: Functions

    init(recordType: String, filterBy: [Filter]? = nil, sortBy: [Sort]? = nil) {
        self.recordType = recordType
        self.filterBy = filterBy
        self.sortBy = sortBy
    }

    func toCKQueryDictionary() -> [String: AnyObject] {
        var dict:[String: AnyObject] = ["recordType": recordType]

        if let filterBy = filterBy {
            var filterDictArray = [[String: AnyObject]]()
            for filter in filterBy {
                filterDictArray.append(filter.toCKFilterDictionary())
            }
            dict["filterBy"] = filterDictArray
        }

        if let sortBy = sortBy {
            var sortDictArray = [[String: AnyObject]]()
            for sort in sortBy {
                sortDictArray.append(sort.toCKSortDescriptorDictionary())
            }
            dict["filterBy"] = sortDictArray
        }

        return dict
    }
}
