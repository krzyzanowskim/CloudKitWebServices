//
//  CKWReferenceAction.swift
//  CloudKitWebServices
//
//  Created by Marcin Krzyzanowski on 15/11/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

import CloudKit

enum CKWReferenceAction: String {
    case Validate = "VALIDATE"
    case None = "NONE"
    case DeleteSelf = "DELETE_SELF"

    func toCKReferenceAction() -> CKReferenceAction {
        switch (self) {
        case .Validate, .None:
            return CKReferenceAction.None
        case .DeleteSelf:
            return CKReferenceAction.DeleteSelf
        }
    }
}
