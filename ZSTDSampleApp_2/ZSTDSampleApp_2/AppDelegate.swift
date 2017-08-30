//
//  AppDelegate.swift
//  ZSTDSampleApp_2
//
//  Created by Anatoli on 2/24/17.
//  Copyright © 2017 Anatoli Peredera. All rights reserved.
//
/**
 * This is a quick and dirty Cocoa macOS app that does a few things with ZSTD when
 * it finishes loading.  Please disregard the empty user interface.
 *
 * Small hard-coded arrays are used here for demo purposes.
 */

import Cocoa
// To make the SwiftZSTD framework available for building and running the app
// please see https://developer.apple.com/library/content/technotes/tn2435/_index.html
import SwiftZSTD

func useZSTD() {
    if let dictData = getDictionary() {
        let origData = Data(bytes: [123, 231, 132, 100, 20, 10, 5, 2, 1])
        if let compData = compressData(origData, dictData) {
            if let decompData = decompressData(compData, dictData) {
                if decompData == origData {
                    print("Using a dictionary: decompressed data same as original!")
                } else {
                    print("Using a dictionary: data mismatch :(")
                }
            }
        }
    } else {
        print("Could not construct dictionary")
    }
}

func getDictionary() -> Data? {
    var samples = [Data]()
    samples.append(Data(bytes: Array(10...250)))
    samples.append(Data(bytes: Array(repeating: 123, count: 100_000)))
    samples.append(Data(bytes: [1,3,4,7,11]))
    samples.append(Data(bytes: [0,0,1,1,5,5]))

    do {
        return try buildDictionary(fromSamples: samples)
    } catch ZDICTError.libraryError(let errStr) {
        print("Library error while creating dictionary: \(errStr)")
    } catch ZDICTError.unknownError {
        print("Unknown library error while creating dictionary.")
    } catch {
        print("Unknown error creating dictionary.")
    }
    
    return nil
}

func compressData(_ dataIn: Data, _ dict: Data) -> Data? {
    // Note that we only check for the exceptions that can reasonably be 
    // expected when compressing, excluding things like unknown decompressed size.
    if let dictProc = DictionaryZSTDProcessor(withDictionary: dict, andCompressionLevel: 4) {
        do {
            return try dictProc.compressBufferUsingDict(dataIn)
        } catch ZSTDError.libraryError(let errStr) {
            print("Library error: \(errStr)")
        } catch ZSTDError.invalidCompressionLevel(let lvl){
            print("Invalid compression level: \(lvl)")
        } catch ZSTDError.inputNotContiguous {
            print("Input not contiguous.")
        } catch {
            print("Unknown error while compressing data.")
        }
        return nil
    } else {
        print("Could not create dictionary-based compressor.")
        return nil
    }
}

func decompressData(_ dataIn: Data, _ dict: Data) -> Data? {
    // We could have re-used the same DictionaryZSTDProcessor instance that was used
    // to compress the data.  Again, note that we only check for the exceptions that
    // can reasonably be expected when decompressing, excluding things like invalid
    // compression level.
    if let dictProc = DictionaryZSTDProcessor(withDictionary: dict, andCompressionLevel: 20) {
        do {
            return try dictProc.decompressFrameUsingDict(dataIn)
        } catch ZSTDError.libraryError(let errStr) {
            print("Library error: \(errStr)")
        } catch ZSTDError.decompressedSizeUnknown {
            print("Unknown decompressed size.")
        } catch {
            print("Unknown error while decompressing data.")
        }
        return nil
    } else {
        print("Could not create dictionary-based decompressor.")
        return nil
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        useZSTD()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

