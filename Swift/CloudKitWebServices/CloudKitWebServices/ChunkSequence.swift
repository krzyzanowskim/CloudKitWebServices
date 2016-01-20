//
//  ChunkSequence.swift
//  CloudKitWebServices
//
//  Created by Marcin Krzyzanowski on 11/11/15.
//  Copyright © 2015 Marcin Krzyżanowski. All rights reserved.
//

struct ChunkSequence<Element>: SequenceType {
    let chunkSize: Array<Element>.Index
    let collection: Array<Element>

    func generate() -> AnyGenerator<ArraySlice<Element>> {
        var offset:Array<Element>.Index = collection.startIndex
        return anyGenerator {
            let result = self.collection[offset..<offset.advancedBy(self.chunkSize, limit: self.collection.endIndex)]
            offset += result.count
            return result.count > 0 ? result : nil
        }
    }
}

extension Array {
    func slice(every every: Index) -> ChunkSequence<Element> {
        return ChunkSequence(chunkSize: every, collection: self)
    }
}