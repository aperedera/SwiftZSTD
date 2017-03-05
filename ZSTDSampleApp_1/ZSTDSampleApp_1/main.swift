//
//  main.swift
//  ZSTDSampleApp_1
//
//  Created by Anatoli on 12/06/16.
//  Copyright © 2016 Anatoli Peredera. All rights reserved.
//
/**
 * This is a simple MacOS command line program using the wrapper without a dictionary.
 * This example uses small hard-coded byte arrays; in the real world one would use larger
 * data items, e.g. those read from files.
 */

import Foundation

var processor = ZSTDProcessor(useContext: true)

let origData = Data(bytes: [3, 4, 12, 244, 32, 7, 10, 12, 13, 111, 222, 133])

do {
    let compressedData = try processor.compressBuffer(origData, compressionLevel: 4)
    let decompressedData = try processor.decompressFrame(compressedData)
    if (decompressedData == origData) {
        print("Decompressed data is the same as original!")
    } else {
        print("Decompressed data is different from original.. :(")
    }
} catch ZSTDError.libraryError(let errStr) {
    print("Library error: \(errStr)")
} catch ZSTDError.invalidCompressionLevel(let lvl){
    print("Invalid compression level: \(lvl)")
} catch ZSTDError.inputNotContiguous {
    print("Input not contiguous.")
} catch ZSTDError.decompressedSizeUnknown {
    print("Unknown decompressed size.")
}
