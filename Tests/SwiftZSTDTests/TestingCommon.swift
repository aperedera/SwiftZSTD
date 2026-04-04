import XCTest

    func checkPlatform() {
        #if os(macOS)
        print("TESTING ON macOS!")
        #elseif os(iOS)
        print("TESTING ON iOS!")
        #else
        XCTFail("UNSUPPORTED PLATFORM")
        #endif
    }
