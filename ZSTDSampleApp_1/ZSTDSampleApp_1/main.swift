//
//  main.swift
//  ZSTDSampleApp_1
//
//  Created by Anatoli on 11/21/16.
//  Copyright © 2016 Anatoli Peredera. All rights reserved.
//

import Foundation

/**
 * This is a simple MacOS command line program using the wrapper.
 */
var processor = ZSTDProcessor()

// Don't use files that are too large; a few MB is OK.
var testURL = URL(fileURLWithPath: "Full path to a file")

if var fileData = try? Data(contentsOf: testURL) {
    print("Size of original data is \(fileData.count)")
    if let compressedData = processor.CompressBuffer(fileData, compressionLevel: 4) {
        print("Size of compressedData is \(compressedData.data.count)")
        
        if let decompressedData = processor.DecompressFrame(compressedData) {
            print("Size of decompressedData is \(decompressedData.count)")
            if (decompressedData == fileData) {print("Decompressed data same as original!!!") }
            else { print ("Data discrepancy :(") }
        }
        else { print("Decompression error: \(processor.lastError)") }
    }
    else { print("Compression error: \(processor.lastError)") }
}
else { print("ERROR creating data") }

