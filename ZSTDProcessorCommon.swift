//
//  ZSTDProcessorCommon.swift
//
//  Created by Anatoli on 12/06/16.
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
 * Types of exceptions thrown by the wrapper.
 */
enum ZSTDError : Error {
    case libraryError(errMsg : String)
    case inputNotContiguous
    case decompressedSizeUnknown
    case invalidCompressionLevel(cl: Int32)
}

/**
 * Common functionality of a Swift wrapper around the ZSTD C library.  Only compression and
 * decompression of a buffer in memory is currently supported. Streaming mode and file 
 * compression/decompression are not yet supported, these can be added later.
 *
 * One of the tricks here is to minimize copying of the buffers being processed.  Also, the
 * Data instances provided as input must use contiguous storage.
 */
class ZSTDProcessorCommon
{
    let compCtx : OpaquePointer?
    let decompCtx : OpaquePointer?
    
    /**
     * Initializer.
     *
     * - parameter useContext : if true, create a context to speed up multiple operations.
     */
    init(useContext : Bool)
    {
        if (useContext)
        {
            compCtx = ZSTD_createCCtx()
            decompCtx = ZSTD_createDCtx()
        }
        else {
            compCtx = nil
            decompCtx = nil
        }
    }
    
    deinit {
        if (compCtx != nil) { ZSTD_freeCCtx(compCtx) }
        if (decompCtx != nil) { ZSTD_freeDCtx(decompCtx) }
    }
        
    /**
     * Compress a buffer. Input is sent to the C API without copying by using the 
     * Data.withUnsafeBytes() method.  The C API places the output straight into the newly-
     * created Data instance, which is possible because there are no other references
     * to the instance at this point, so calling withUnsafeMutableBytes() does not trigger
     * a copy-on-write.
     * 
     * - parameter dataIn : input Data
     * - parameter delegateFunction : a specific function/closure to be called
     * - returns: compressed frame
     */
    func compressBufferCommon(_ dataIn : Data,
                              _ delegateFunction : (UnsafeMutableRawPointer,
                                                    Int,
                                                    UnsafeRawPointer,
                                                    Int)->Int ) throws -> Data
    {
        guard dataIn.ZSTDIsContiguousData() else {
            throw ZSTDError.inputNotContiguous
        }

        var retVal = Data(count: ZSTD_compressBound(dataIn.count))
        
        try dataIn.withUnsafeBytes{ (pIn : UnsafePointer<UInt8>) in
            try retVal.withUnsafeMutableBytes{ (pOut : UnsafeMutablePointer<UInt8>) in
                let rc = delegateFunction(pOut, retVal.count, pIn, dataIn.count)
                if let errStr = getEngineErrorString(rc) {
                    throw ZSTDError.libraryError(errMsg: errStr)
                } else {
                    retVal.count = rc
                }
            }
        }
        return retVal
    }

    /**
     * Decompress a frame that resulted from a previous compression of a buffer by ZSTD.
     * The exact frame size must be known, which is available via an the 
     * ZSTD_getDecompressedSize() API call.
     *
     * @param dataIn: frame to be decompressed
     * @parem delegateFunction: closure/function to perform specific decompression work
     * @return a Data instance wrapping the decompressed buffer
     */
    func decompressFrameCommon(_ dataIn : Data,
                              _ delegateFunction : (UnsafeMutableRawPointer,
                                                    Int,
                                                    UnsafeRawPointer,
                                                    Int)->Int ) throws -> Data
    {
        guard dataIn.ZSTDIsContiguousData() else {
            throw ZSTDError.inputNotContiguous
        }
        
        var storedDSize : UInt64 = 0
        dataIn.withUnsafeBytes { (p : UnsafePointer<UInt8>) in
            storedDSize = ZSTD_getDecompressedSize(p, dataIn.count)
        }

        guard storedDSize != 0 else {
            throw ZSTDError.decompressedSizeUnknown
        }
        
        var retVal = Data(count: Int(storedDSize))
        
        try dataIn.withUnsafeBytes{ (pIn : UnsafePointer<UInt8>) in
            try retVal.withUnsafeMutableBytes{ (pOut : UnsafeMutablePointer<UInt8>) in
                let rc = delegateFunction(pOut, Int(storedDSize), pIn, dataIn.count)
                if let errStr = getEngineErrorString(rc) {
                    throw ZSTDError.libraryError(errMsg: errStr)
                }
            }
        }
        
        return retVal
    }
}

/**
 * A helper for internal use.
 */
func getEngineErrorString(_ rc : Int) -> String?
{
    if (ZSTD_isError(rc) != 0) {
        if let err = ZSTD_getErrorName(rc) {
            return String(bytesNoCopy: UnsafeMutableRawPointer(mutating: err), length: Int(strlen(err)), encoding: String.Encoding.ascii, freeWhenDone: false)
        }
    }
    return nil
}

/**
 * A helper for internal use.
 */
func isValidCompressionLevel(_ compressionLevel : Int32) -> Bool {
    return compressionLevel >= 1 && compressionLevel <= ZSTD_maxCLevel()
}
