//
//  CKDictionaryRepresentable.swift
//  CloudKitWebServices
//
//  Created by Marcin Krzyzanowski on 13/01/16.
//  Copyright © 2016 Marcin Krzyżanowski. All rights reserved.
//

protocol CKDictionaryRepresentable {
    func toCKDictionary() -> [String: AnyObject]
}