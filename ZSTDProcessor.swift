//
//  ZSTDProcessor.swift
//
//  Created by Anatoli on 11/21/16.
//  Copyright © 2016 Anatoli Peredera. All rights reserved.
//

import Foundation

/**
 * An extension providing a method to determine if the bytes of a Data are stored
 * in contiguous memory.
 */
extension Data
{
    func ZSTDIsContiguousData() -> Bool {
        var retVal : Bool = false
        self.enumerateBytes{(pBuf: UnsafeBufferPointer<UInt8>, idx: Data.Index, flag: inout Bool) -> Void in
            if (pBuf.count == self.count) { retVal = true }
        }
        return retVal
    }
}

/**
 * A Swift wrapper around (a very limited subset of) the ZSTD C library.  Only compression and
 * decompression of a buffer in memory is currently supported, and even that without using 
 * contexts and dictionaries.  Streaming mode and file compression/decompression are not 
 * yet supported, these can be added later.
 *
 * One of the tricks here is to minimize copying of the buffers being processed.  Also, the
 * Data instances provided as input must use contiguous storage.
 */
class ZSTDProcessor
{
    /**
     * A struct holding a buffer compressed by ZSTD.  The exact decompressed size
     * of the frame is needed for decompression by the simple API, so it is stored
     * here in addition to the wrapped Data.  Decompressed size can also be 
     * determined in some cases by an API call, which is used as an extra error check.
     */
    struct ZSTDCompressedFrame
    {
        var data : Data
        var decompressedSize : Int
    }
    
    /**
     * The last error string, empty if no error.
     */
    var lastError = ""
    
    /**
     * Compress a buffer. Input is sent to the C API without copying by using the 
     * Data.withUnsafeBytes() method.  The C API places the output straight into the newly-
     * created Data instance, which is possible because there are no other references
     * to the instance at this point, so calling withUnsafeMutableBytes() does not trigger
     * a copy-on-write.
     * 
     * @param dataIn : input Data
     * @param compressionLevel : must be 1-22, levels >= 20 to be used with caution
     * @return compressed frame
     */
    func CompressBuffer(_ dataIn : Data, compressionLevel : Int32) -> ZSTDCompressedFrame?
    {
        lastError = ""
        
        var retVal : ZSTDCompressedFrame? = nil
        
        guard dataIn.ZSTDIsContiguousData() else {
            lastError = "Input to CompressBuffer() non-contiguous"
            return retVal
        }
        
        guard compressionLevel >= 1 && compressionLevel <= ZSTD_maxCLevel() else {
            lastError = "Compression level \(compressionLevel) is invalid"
            return retVal
        }
        
        // Determine the max size of compressed frame and set the size of dataOut accordingly
        var dataOut = Data(count: ZSTD_compressBound(dataIn.count))
        
        dataIn.withUnsafeBytes{ (pIn : UnsafePointer<UInt8>) in
            dataOut.withUnsafeMutableBytes{ (pOut : UnsafeMutablePointer<UInt8>) in
                let actualCompressedSize = ZSTD_compress(pOut, dataOut.count, pIn, dataIn.count, compressionLevel)
                if (!isError(actualCompressedSize)) {
                    dataOut.count = actualCompressedSize
                    retVal = ZSTDCompressedFrame(data: dataOut, decompressedSize: dataIn.count)
                }
            }
        }
        return retVal
    }
    
    /**
     * Decompress a frame that resulted from a previous compression of a buffer by ZSTD.
     * The exact frame size must be known, which is stored in ZSTDCompressedFrame and 
     * may also be available via an the ZSTD_getDecompressedSize() API call.
     *
     * @param dataIn: frame to be decompressed
     * @return a Data instance wrapping the decompressed buffer
     */
    func DecompressFrame(_ dataIn : ZSTDCompressedFrame) -> Data?
    {
        lastError = ""
        
        var retVal : Data? = nil

        guard dataIn.data.ZSTDIsContiguousData() else {
            lastError = "Input to DecompressFrame() non-contiguous"
            return retVal
        }
        
        var dataOut = Data(count: dataIn.decompressedSize)
        
        dataIn.data.withUnsafeBytes{ (pIn : UnsafePointer<UInt8>) in
            // Check reported decompressed size
            let decompressedSize1 = ZSTD_getDecompressedSize(pIn, dataIn.data.count)
            if (decompressedSize1 != 0 && decompressedSize1 == UInt64(dataIn.decompressedSize))
            {
                dataOut.withUnsafeMutableBytes{ (pOut : UnsafeMutablePointer<UInt8>) in
                    let rc = ZSTD_decompress(pOut, dataIn.decompressedSize, pIn, dataIn.data.count)
                    if (!isError(rc) && rc == dataIn.decompressedSize)
                    {
                        retVal = Data(bytesNoCopy: UnsafeMutableRawPointer(pOut), count: dataIn.decompressedSize, deallocator: .none)
                    }
                }
            }
            else { lastError = "Unexpected decompressed size reported by the library" }
        }
        
        return retVal
    }
    
    /**
     * A helper for internal use.
     */
    func isError(_ rc : Int) -> Bool
    {
        if (ZSTD_isError(rc) != 0) {
            if let err = ZSTD_getErrorName(rc) {
                if let _s = String(bytesNoCopy: UnsafeMutableRawPointer(mutating: err), length: Int(strlen(err)), encoding: String.Encoding.ascii, freeWhenDone: false) {
                    lastError = _s
                }
                else { lastError = "Unknown" }
            }
            return true
        }
        else { return false }
    }
}
