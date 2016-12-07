//
//  ZSTDDictionaryBuilder.swift
//  ZSTDSampleApp_1
//
//  Created by Anatoli on 12/06/16.
//  Copyright © 2016 Anatoli Peredera. All rights reserved.
//

import Foundation

/**
 * Exceptions thrown by the dictionary builder.
 */
enum ZDICTError : Error {
    case libraryError(errMsg : String)
    case fileError(fileName : String)
}

/**
 * Build a dictionary from files identified by an array of file names.
 *
 * The target dictionary size is 100th of the total sample size as 
 * recommended by documentation.
 *
 * - parameter  fromFiles : names of files to use to build a dictionary
 * - returns: Data instance containing the dictionary generated
 */
func buildDictionary(fromFiles : [String]) throws -> Data {
    var samples = Data()
    var totalSampleSize : Int = 0;
    var sampleSizes = [Int]()
    
    for fn in fromFiles {
        do {
            let data = try Data(contentsOf : URL(fileURLWithPath: fn))
            samples.append(data)
            totalSampleSize += data.count
            sampleSizes.append(data.count)
        }
        catch {
            throw ZDICTError.fileError(fileName: fn)
        }
    }
    var retVal = Data(count: totalSampleSize / 100)
    
    try samples.withUnsafeBytes{ (pSamples : UnsafePointer<UInt8>) in
        try retVal.withUnsafeMutableBytes{ (pDict : UnsafeMutablePointer<UInt8>) in
            let actualDictSize = ZDICT_trainFromBuffer(pDict, retVal.count, pSamples, &sampleSizes, UInt32(Int32(sampleSizes.count)))
            if ZDICT_isError(actualDictSize) != 0 {
                if let errStr = getDictionaryErrorString(actualDictSize) {
                    throw ZDICTError.libraryError(errMsg: errStr)
                } else {
                    throw ZDICTError.libraryError(errMsg: "Unknown")
                }
            }
            else {
                retVal.count = actualDictSize
            }
        }
    }
    
    return retVal
}

/**
 * A helper to obtain error string.
 */
func getDictionaryErrorString(_ rc : Int) -> String?
{
    if (ZDICT_isError(rc) != 0) {
        if let err = ZDICT_getErrorName(rc) {
            return String(bytesNoCopy: UnsafeMutableRawPointer(mutating: err), length: Int(strlen(err)), encoding: String.Encoding.ascii, freeWhenDone: false)
        }
    }
    return nil
}
