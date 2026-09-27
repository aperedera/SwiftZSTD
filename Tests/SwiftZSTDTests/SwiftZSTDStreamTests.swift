//
//  SwiftZSTDBasicTests.swift
//
//  Created by Anatoli on 2/11/25.
//

#if !os(Linux) && !os(Windows)

import XCTest
@testable import SwiftZSTD

class SwiftZSTDStreamTests: XCTestCase {
    func testCompressDecompressOld() {
        implCompressDecompress(useDeprecated: true, useMultiframe: false)
    }

    func testCompressDecompress() {
        implCompressDecompress(useDeprecated: false, useMultiframe: false)
    }

    func testCompressDecompressMulti() {
        implCompressDecompress(useDeprecated: false, useMultiframe: true)
    }

    func testCompressDecompressOldTwice() {
        implCompressDecompress(useDeprecated: true, useMultiframe: false, twice: true)
    }

    func testCompressDecompressTwice() {
        implCompressDecompress(useDeprecated: false, useMultiframe: false, twice: true)
    }

    func testCompressDecompressMultiTwice() {
        implCompressDecompress(useDeprecated: false, useMultiframe: true, twice: true)
    }

    fileprivate func implCompressDecompress(useDeprecated : Bool, useMultiframe : Bool, twice : Bool = false) {
        
        checkPlatform()
        let origChunk1 = Data([123, 231, 132, 100, 20, 10, 5, 2, 1, 2, 20, 200, 100, 50, 25, 12])
        let origChunk2 = Data([123, 131, 232, 100, 20, 10, 15, 22, 1])
        
        var origData = origChunk1
        origData.append(origChunk2)
        if useMultiframe {
            origData.append(origChunk2)
            origData.append(origChunk1)
        }
        
        let streamProcessor = ZSTDStream()
        let iterCount = twice ? 2 : 1
        for _ in 0..<iterCount {
            var compressedData = Data()
            try? streamProcessor.startCompression(compressionLevel: 4)
            try? compressedData.append(streamProcessor.compressionProcess(dataIn: origChunk1))
            try? compressedData.append(streamProcessor.compressionFinalize(dataIn: origChunk2))
            if useMultiframe {
                try? streamProcessor.startCompression(compressionLevel: 4)
                try? compressedData.append(streamProcessor.compressionProcess(dataIn: origChunk2))
                try? compressedData.append(streamProcessor.compressionFinalize(dataIn: origChunk1))
            }

            try? streamProcessor.startDecompression()

            let splitPoint = compressedData.count / 2
            let compressedData1 = compressedData.subdata(in: 0..<splitPoint )
            let compressedData2 = compressedData.subdata(in: splitPoint..<compressedData.count )
            if useDeprecated {
                if !useMultiframe {
                    var doneFlag = false
                    var decompressedData = try? streamProcessor.decompressionProcess(dataIn: compressedData1, isDone: &doneFlag)
                    if doneFlag {
                        XCTFail("Stream decompression ended prematurely")
                    }
                    let decompressedData2 = try? streamProcessor.decompressionProcess(dataIn: compressedData2, isDone: &doneFlag)
                    if !doneFlag {
                        XCTFail("Stream decompression was not successful")
                    }
                    decompressedData!.append(decompressedData2!)
                    XCTAssertEqual(decompressedData, origData,
                                "Stream-decompressed data is different from original (not using dictionary)")
                } // else is N/A: deprecated API is not expected to work w/ multi-frame input
            } else {
                var decompressedData = try? streamProcessor.decompressionProcess(dataIn: compressedData1)
                let decompressedData2 = try? streamProcessor.decompressionFinalize(dataIn: compressedData2)
                decompressedData!.append(decompressedData2!)
                XCTAssertEqual(decompressedData, origData,
                            "Stream-decompressed data is different from original (not using dictionary)")
            }
        }
    }
}
#endif
