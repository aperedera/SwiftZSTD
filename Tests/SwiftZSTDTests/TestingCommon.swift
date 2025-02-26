    func checkPlatform() {
        #if os(OSX)
        print("TESTING ON macOS!")
        #elseif os(iOS)
        print("TESTING ON iOS!")
        #else
        XCTFail("BAD PLATFORM")
        #endif
    }