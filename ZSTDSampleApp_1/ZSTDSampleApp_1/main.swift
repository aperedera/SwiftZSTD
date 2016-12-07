//
//  main.swift
//  ZSTDSampleApp_1
//
//  Created by Anatoli on 12/06/16.
//  Copyright © 2016 Anatoli Peredera. All rights reserved.
//

import Foundation

/**
 * This is a simple MacOS command line program using the wrapper.
 * Please insert valid file names instead of placeholders.  
 * Modify the program appropriately if you don't want to use a dictionary.
 */

let dictData = try? Data(contentsOf: URL(fileURLWithPath: "Path to your dictionary file"))

//var processor = ZSTDProcessor(useContext: true)
var processor = DictionaryZSTDProcessor(withDictionary: dictData!, andCompressionLevel: 4)

// Don't use files that are too large; < 100 MB is OK.
// The compression param is useless now, but would be needed for no-dictionary case.
func testFile(_ fn : String, usingProcessor : DictionaryZSTDProcessor, withCompressionLevel cl : Int32) -> Void {
    let testURL = URL(fileURLWithPath: fn)

    if var fileData = try? Data(contentsOf: testURL) {
        print("Size of original data is \(fileData.count)")
        do {
            let compressedData = try processor!.compressBufferUsingDict(fileData)
            print("Size of compressedData is \(compressedData.count)")
            let decompressedData = try processor!.decompressFrameUsingDict(compressedData)
            print("Size of decompressedData is \(decompressedData.count)")
            if (decompressedData == fileData) {print("Decompressed data same as original!!!") }
            else { print ("Data discrepancy :(") }
        }
        catch ZSTDError.libraryError(let errStr) {
            print("Error in the library: \(errStr)")
        }
        catch {
            switch error {
            case ZSTDError.inputNotContiguous:
                print("Non-contiguous input")
            default:
                print("Unknown exception")
            }
        }
    }
    else { print("ERROR creating data") }
}

let fileNames : [String] = [
    "file1",
    "file2",
    "file3"
]

for fn in fileNames {
    let fileName = "/directory containing the files/" + fn
    testFile(fileName, usingProcessor : processor!, withCompressionLevel : 4)
}
