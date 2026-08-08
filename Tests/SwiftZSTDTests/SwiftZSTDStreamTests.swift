//
//  SwiftZSTDBasicTests.swift
//
//  Created by Anatoli on 2/11/25.
//

#if !os(Linux) && !os(Windows)

import XCTest
@testable import SwiftZSTD

class SwiftZSTDStreamTests: XCTestCase {
    
    func testCompressDecompress() {
        checkPlatform()
        
        let origChunk1 = Data([123, 231, 132, 100, 20, 10, 5, 2, 1, 2, 20, 200, 100, 50, 25, 12])
        let origChunk2 = Data([123, 131, 232, 100, 20, 10, 15, 22, 1])
        
        var origData = origChunk1
        origData.append(origChunk2)
        
        let streamProcessor = ZSTDStream()
        var compressedData = Data()
        try? streamProcessor.startCompression(compressionLevel: 4)
        try? compressedData.append(streamProcessor.compressionProcess(dataIn: origChunk1))
        try? compressedData.append(streamProcessor.compressionFinalize(dataIn: origChunk2))
        
        try? streamProcessor.startDecompression()
        var isDone : Bool = false
        
        let splitPoint = compressedData.count / 2
        let compressedData1 = compressedData.subdata(in: 0..<splitPoint )
        let compressedData2 = compressedData.subdata(in: splitPoint..<compressedData.count )
        var decompressedData = try? streamProcessor.decompressionProcess(dataIn: compressedData1, isDone: &isDone)
        if isDone {
            XCTFail("Stream decompression ended prematurely")
        }
        let decompressedData2 = try? streamProcessor.decompressionProcess(dataIn: compressedData2, isDone: &isDone)
        if !isDone {
            XCTFail("Stream decompression was not successful")
        } else {
            decompressedData!.append(decompressedData2!)
            XCTAssertEqual(decompressedData, origData,
                           "Stream-decompressed data is different from original (not using dictionary)")
        }
    }

}
#endif
