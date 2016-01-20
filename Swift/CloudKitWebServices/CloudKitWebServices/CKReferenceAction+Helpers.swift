//
//  CKReferenceAction+Helpers.swift
//  CloudKitWebServices
//
//  Created by Marcin Krzyzanowski on 07/11/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

import CloudKit

extension CKReferenceAction {

    init(reference: CKWReferenceAction) {
        switch (reference) {
            case .None, .Validate:
                self = .None
            case .DeleteSelf:
                self = .DeleteSelf
        }
    }

    func toCKWReferenceAction() -> CKWReferenceAction {
        switch (self) {
        case .None:
            return .None
        case .DeleteSelf:
            return .DeleteSelf
        }
    }
}