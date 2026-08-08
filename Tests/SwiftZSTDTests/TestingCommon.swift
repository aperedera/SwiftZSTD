import XCTest

func checkPlatform() {
    #if os(macOS)
        print("TESTING ON macOS!")
    #elseif os(iOS)
        print("TESTING ON iOS!")
    #elseif os(Linux)
        print("TESTING ON Linux!")
    #else
        XCTFail("UNSUPPORTED PLATFORM")
    #endif
}
