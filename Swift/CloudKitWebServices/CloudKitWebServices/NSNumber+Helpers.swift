//
//  NSNumber+Helpers.swift
//  CloudKitWebServices
//
//  Created by Marcin Krzyzanowski on 14/11/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

import Foundation

extension NSNumber {

    func isDouble() -> Bool {
        guard let encoding = String.fromCString(self.objCType) else {
            return false
        }

        return encoding == "d"
    }

    func isFloat() -> Bool {
        guard let encoding = String.fromCString(self.objCType) else {
            return false
        }

        return encoding == "f"
    }

    func isBool() -> Bool {
        guard let encoding = String.fromCString(self.objCType) else {
            return false
        }

        return encoding == "B"
    }

    func isReal() -> Bool {
        return isDouble() || isFloat()
    }
}